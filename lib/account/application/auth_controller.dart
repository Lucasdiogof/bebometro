import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../../core/data/device_store.dart';
import '../data/legacy_data.dart';
import '../../l10n/l10n.dart';

enum AccessStatus {
  /// Restoring the session from disk.
  initializing,

  /// No session: sign in or create an account.
  signedOut,

  /// An anonymous session from before accounts became mandatory. The product
  /// is closed until the person converts it or signs in to another account.
  legacyAnonymous,

  /// Account created (or anonymous conversion asked); waiting for the e-mail
  /// link.
  emailPending,

  /// Anonymous user converted (e-mail confirmed): a password must be set.
  needsPassword,

  /// Permanent account. Works offline.
  authenticated,

  /// Opened with the code sent for a password reset: new password first,
  /// nothing else.
  passwordRecovery,

  /// The server rejected the stored session (revoked/expired refresh). Local
  /// data of that account is kept; signing in again resumes it.
  reauthRequired,
}

class AccessState {
  const AccessState({
    required this.status,
    this.userId,
    this.email,
    this.displayName,
    this.emailConfirmed = false,
    this.pendingEmail,
    this.converting = false,
    this.cloudUnavailable = false,
    this.notice,
  });

  final AccessStatus status;

  /// The user whose data space is (or would be) open.
  final String? userId;
  final String? email;
  final String? displayName;
  final bool emailConfirmed;

  /// Address that must receive the confirmation link.
  final String? pendingEmail;

  /// The pending e-mail belongs to an anonymous conversion (same user id).
  final bool converting;

  /// The cloud could not be reached at start-up (temporary connection
  /// failure or bad configuration). Signed-in people keep working locally.
  final bool cloudUnavailable;

  /// One-shot message for the person (link expired, account created, ...).
  final String? notice;

  bool get canUseProduct => status == AccessStatus.authenticated;

  AccessState copyWith({String? notice, bool clearNotice = false}) => AccessState(
        status: status,
        userId: userId,
        email: email,
        displayName: displayName,
        emailConfirmed: emailConfirmed,
        pendingEmail: pendingEmail,
        converting: converting,
        cloudUnavailable: cloudUnavailable,
        notice: clearNotice ? null : (notice ?? this.notice),
      );
}

/// Readable outcome of an auth call for the forms.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.field});

  final String message;

  /// 'email', 'password', 'code' (a code sent by e-mail is required) or null
  /// for the whole form.
  final String? field;
}

/// Single source of truth for "who is using the app". The [AccessGate]
/// widget is the only place that turns this state into navigation.
///
/// Never signs in anonymously. A network error is never a logout: only a
/// `signedOut` event that the person did not ask for (the SDK emits it when
/// the server refuses the stored session) leads to [AccessStatus.reauthRequired],
/// and nothing local is deleted.
class AuthController extends Cubit<AccessState> {
  AuthController(this._device, this._legacy, {required this.cloudEnabled})
      : super(const AccessState(status: AccessStatus.initializing));

  final DeviceStore _device;
  final LegacyData _legacy;
  final bool cloudEnabled;
  StreamSubscription<AuthState>? _sub;
  Future<void> _queue = Future.value();

  /// A failing step never blocks the next ones.
  Future<void> _enqueue(Future<void> Function() step) => _queue = _queue
      .then((_) => step())
      .catchError((Object e) => _log('auth step failed: ${e.runtimeType}'));
  DateTime? _lastResend;
  DateTime? _lastRecoverySend;

  static const _lastUidKey = 'auth.last_uid';
  static const _lastEmailKey = 'auth.last_email';
  static const _pendingEmailKey = 'auth.pending_email';
  static const _conversionKey = 'auth.conversion';
  static const _recoveryKey = 'auth.recovery';
  static const _signingOutKey = 'auth.signing_out';

  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Where the e-mail links send the person back (registered in Supabase).
  static String get redirectUrl => kIsWeb ? Uri.base.origin : Env.authRedirectUrl;

  Future<void> start() async {
    if (!cloudEnabled) {
      // Configuration or start-up failure: a known account keeps working on
      // its local data; nobody new can sign in until the cloud is back.
      final uid = _device.getString(_lastUidKey);
      emit(uid != null
          ? AccessState(
              status: AccessStatus.authenticated,
              userId: uid,
              email: _device.getString(_lastEmailKey),
              cloudUnavailable: true,
            )
          : const AccessState(
              status: AccessStatus.signedOut, cloudUnavailable: true));
      return;
    }
    var session = _auth.currentSession;
    // The app never keeps anonymous sessions any more (it has no old data to
    // keep): one left on the device by a test build is dropped locally, so
    // the person lands on the normal sign-in / create-account screen.
    if (session?.user.isAnonymous == true) {
      try {
        await _auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
      session = _auth.currentSession;
    }

    // The SDK replays every event of this run (ReplaySubject), including a
    // passwordRecovery produced by the link that opened a cold app. Events
    // are handled one after the other, never interleaved.
    _sub = _auth.onAuthStateChange.listen(
      (data) => _enqueue(() => _onAuthEvent(data)),
      onError: (Object e) {
        // Network trouble while refreshing is not a logout and not a link
        // problem: the session stays and the SDK retries.
        if (e is AuthRetryableFetchException) return;
        if (e is AuthException &&
            const {
              'session_expired',
              'refresh_token_not_found',
              'refresh_token_already_used',
            }.contains(e.code)) {
          return; // the signedOut event that follows handles it
        }
        // Otherwise: a link that expired, was already used or was opened on
        // another device (PKCE needs the device that asked for it). Never
        // logged with the URL.
        _log('auth link error: ${e.runtimeType}');
        emit(state.copyWith(
            notice: tr.authLinkInvalid));
      },
    );
    await _enqueue(() => _apply(session));
  }

  Future<void> _onAuthEvent(AuthState data) async {
    switch (data.event) {
      case AuthChangeEvent.passwordRecovery:
        final email = data.session?.user.email;
        await _device.setString(
            _recoveryKey,
            jsonEncode({
              'email': email,
              'at': DateTime.now().toUtc().toIso8601String(),
            }));
        await _apply(data.session);
      case AuthChangeEvent.signedOut:
        final asked = _device.getString(_signingOutKey) == '1' ||
            data.signOutReason == SignOutReason.userInitiated;
        await _device.remove(_signingOutKey);
        final last = _device.getString(_lastUidKey);
        if (!asked && last != null && state.status == AccessStatus.authenticated) {
          emit(AccessState(
            status: AccessStatus.reauthRequired,
            userId: last,
            email: _device.getString(_lastEmailKey),
          ));
        } else {
          await _apply(null);
        }
      default:
        await _apply(data.session);
    }
  }

  /// Turns the current session into a state. Pure reading plus the small
  /// device markers; no network.
  Future<void> _apply(Session? session) async {
    if (isClosed) return;
    final user = session?.user;
    if (user == null) {
      final pending = _device.getString(_pendingEmailKey);
      emit(AccessState(
        status: pending != null ? AccessStatus.emailPending : AccessStatus.signedOut,
        pendingEmail: pending,
        email: _device.getString(_lastEmailKey),
        notice: state.notice,
      ));
      return;
    }
    final name = user.userMetadata?['display_name'] as String?;
    final confirmed = user.emailConfirmedAt != null;
    final conversion = _jsonKey(_conversionKey);

    if (user.isAnonymous) {
      emit(AccessState(
        status: AccessStatus.signedOut,
        email: _device.getString(_lastEmailKey),
        notice: state.notice,
      ));
      return;
    }

    if (conversion?['uid'] == user.id && confirmed) {
      // E-mail of the converted anonymous user confirmed: password next.
      emit(AccessState(
        status: AccessStatus.needsPassword,
        userId: user.id,
        email: user.email,
        displayName: name,
        emailConfirmed: true,
      ));
      return;
    }

    final recovery = _jsonKey(_recoveryKey);
    if (recovery != null) {
      final at = DateTime.tryParse(recovery['at'] as String? ?? '');
      final fresh = at != null &&
          DateTime.now().toUtc().difference(at) < const Duration(hours: 2);
      final sameEmail = recovery['email'] == null ||
          (recovery['email'] as String).toLowerCase() ==
              (user.email ?? '').toLowerCase();
      if (fresh && sameEmail) {
        emit(AccessState(
          status: AccessStatus.passwordRecovery,
          userId: user.id,
          email: user.email,
          displayName: name,
          emailConfirmed: confirmed,
        ));
        return;
      }
      await _device.remove(_recoveryKey);
    }

    await _device.remove(_pendingEmailKey);
    await _device.setString(_lastUidKey, user.id);
    if (user.email != null) await _device.setString(_lastEmailKey, user.email!);
    emit(AccessState(
      status: AccessStatus.authenticated,
      userId: user.id,
      email: user.email,
      displayName: name,
      emailConfirmed: confirmed,
      notice: state.notice,
    ));
  }

  Map<String, dynamic>? _jsonKey(String key) {
    final raw = _device.getString(key);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  void clearNotice() {
    if (state.notice != null) emit(state.copyWith(clearNotice: true));
  }

  // ------------------------------------------------------------------ calls

  Future<void> signIn(String email, String password) async {
    _requireCloud();
    try {
      await _auth.signInWithPassword(email: email.trim(), password: password);
      // The listener applies the new session.
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Creates the account. With e-mail confirmation on (the expected setup)
  /// there is no session yet: the state becomes "check your e-mail".
  Future<void> signUp(String name, String email, String password) async {
    _requireCloud();
    try {
      final res = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {'display_name': name.trim(), 'language': trLanguage},
        emailRedirectTo: redirectUrl,
      );
      if (res.session == null) {
        await _device.setString(_pendingEmailKey, email.trim());
        _lastResend = DateTime.now();
        emit(AccessState(
          status: AccessStatus.emailPending,
          pendingEmail: email.trim(),
        ));
      }
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Case A: keeps the anonymous user (same id, same records) and links an
  /// e-mail to it. The password can only be set after the e-mail is
  /// confirmed (Supabase rule), so it is asked in [setPassword] later.
  Future<void> convertAnonymous(String name, String email) async {
    _requireCloud();
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw AuthFailure(tr.authNoOldSession);
    }
    try {
      await _auth.updateUser(
        UserAttributes(
            email: email.trim(),
            data: {'display_name': name.trim(), 'language': trLanguage}),
        emailRedirectTo: redirectUrl,
      );
      await _device.setString(
          _conversionKey, jsonEncode({'uid': user.id, 'email': email.trim()}));
      _lastResend = DateTime.now();
      await _apply(_auth.currentSession);
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Gives up a pending conversion (the anonymous session stays).
  Future<void> cancelConversion() async {
    await _device.remove(_conversionKey);
    await _apply(cloudEnabled ? _auth.currentSession : null);
  }

  /// Leaves the "check your e-mail" screen without a confirmed account.
  Future<void> forgetPendingEmail() async {
    await _device.remove(_pendingEmailKey);
    await _apply(cloudEnabled ? _auth.currentSession : null);
  }

  /// Seconds before another confirmation e-mail may be asked (local guard;
  /// the server also limits).
  int get resendWaitSeconds {
    final last = _lastResend;
    if (last == null) return 0;
    final left = 60 - DateTime.now().difference(last).inSeconds;
    return left > 0 ? left : 0;
  }

  Future<void> resendConfirmation() async {
    _requireCloud();
    final email = state.pendingEmail;
    if (email == null) return;
    if (resendWaitSeconds > 0) {
      throw AuthFailure(tr.authResendWait(resendWaitSeconds));
    }
    try {
      await _auth.resend(
        type: state.converting ? OtpType.emailChange : OtpType.signup,
        email: email,
        emailRedirectTo: redirectUrl,
      );
      _lastResend = DateTime.now();
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Seconds before another recovery code may be asked (local guard; the
  /// server also limits).
  int get recoveryWaitSeconds {
    final last = _lastRecoverySend;
    if (last == null) return 0;
    final left = 60 - DateTime.now().difference(last).inSeconds;
    return left > 0 ? left : 0;
  }

  /// Asks for the 6-digit recovery code (e-mail template without a link).
  /// No redirect, no PKCE: the code is typed in [verifyRecoveryCode], on any
  /// device.
  Future<void> sendPasswordReset(String email) async {
    _requireCloud();
    if (recoveryWaitSeconds > 0) {
      throw AuthFailure(tr.authResendWait(recoveryWaitSeconds));
    }
    try {
      await _auth.resetPasswordForEmail(email.trim());
      _lastRecoverySend = DateTime.now();
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Exchanges the code for a session and opens the new-password screen.
  /// The marker is written first so the session that [verifyOTP] opens is
  /// read as a recovery and never as a normal sign-in.
  Future<void> verifyRecoveryCode(String email, String code) async {
    _requireCloud();
    await _device.setString(
        _recoveryKey,
        jsonEncode({
          'email': email.trim().toLowerCase(),
          'at': DateTime.now().toUtc().toIso8601String(),
        }));
    try {
      await _auth.verifyOTP(
        type: OtpType.recovery,
        email: email.trim(),
        token: code.trim(),
      );
      // The listener applies the session (passwordRecovery).
    } on AuthException catch (e) {
      await _device.remove(_recoveryKey);
      throw _map(e);
    }
  }

  /// New password after the recovery code, or the first password of a converted
  /// anonymous user.
  Future<void> setPassword(String password) async {
    _requireCloud();
    try {
      await _auth.updateUser(UserAttributes(password: password));
      await _device.remove(_recoveryKey);
      await _device.remove(_conversionKey);
      await _apply(_auth.currentSession);
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Leaves the reset screen without changing the password (signs out: the
  /// recovery session must not open the product by the back door).
  Future<void> cancelRecovery() async {
    await _device.remove(_recoveryKey);
    await signOut();
  }

  /// Changes the password of a signed-in person. When the project requires
  /// it, a code sent by e-mail ([reauthenticate]) must come with it.
  Future<void> changePassword(String password, {String? nonce}) async {
    _requireCloud();
    try {
      await _auth.updateUser(UserAttributes(password: password, nonce: nonce));
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Sends the code required by "secure password change".
  Future<void> reauthenticate() async {
    _requireCloud();
    try {
      await _auth.reauthenticate();
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Confirms the password of the signed-in person (before deleting the
  /// account). Does not change the session's user.
  Future<void> verifyPassword(String password) async {
    _requireCloud();
    final email = _auth.currentUser?.email;
    if (email == null) throw AuthFailure(tr.authSignInAgainToContinue);
    try {
      final res = await _auth.signInWithPassword(email: email, password: password);
      if (res.user?.id != state.userId) {
        throw AuthFailure(tr.authDifferentAccount);
      }
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Records the app language in the account (user_metadata.language) so the
  /// e-mail templates can answer in it. Best effort and silent: the e-mails
  /// fall back to Portuguese when it was never recorded.
  Future<void> syncLanguage() async {
    final user = _auth.currentUser;
    if (!cloudEnabled || user == null || user.isAnonymous) return;
    if (user.userMetadata?['language'] == trLanguage) return;
    try {
      await _auth.updateUser(UserAttributes(data: {'language': trLanguage}));
    } catch (_) {}
  }

  Future<void> updateName(String name) async {
    _requireCloud();
    try {
      await _auth.updateUser(UserAttributes(data: {'display_name': name.trim()}));
      await _apply(_auth.currentSession);
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// Ends the session on this device. Local data of the account stays in its
  /// own space and only comes back when the same account signs in.
  Future<void> signOut() async {
    await _device.setString(_signingOutKey, '1');
    try {
      if (cloudEnabled) await _auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      // Offline: the local session is cleared anyway by the SDK.
    }
    await _device.remove(_lastUidKey);
    await _apply(null);
  }

  /// After the server deleted the account.
  Future<void> forgetAccount() async {
    await _device.remove(_lastEmailKey);
    await signOut();
  }

  void _requireCloud() {
    if (!cloudEnabled) {
      throw AuthFailure(tr.authServerUnreachable);
    }
  }

  AuthFailure _map(AuthException e) {
    if (e is AuthRetryableFetchException) {
      return AuthFailure(tr.authNoConnection);
    }
    final code = e.code ?? '';
    return switch (code) {
      'invalid_credentials' =>
        AuthFailure(tr.authWrongCredentials, field: 'password'),
      'email_not_confirmed' => AuthFailure(tr.authEmailNotConfirmed),
      'user_already_exists' || 'email_exists' => AuthFailure(tr.authEmailExists,
          field: 'email'),
      'weak_password' => AuthFailure(tr.authWeakPassword,
          field: 'password'),
      'same_password' => AuthFailure(tr.authSamePassword,
          field: 'password'),
      'over_email_send_rate_limit' || 'over_request_rate_limit' => AuthFailure(tr.authTooManyAttempts),
      'email_address_invalid' || 'validation_failed' =>
        AuthFailure(tr.authCheckEmail, field: 'email'),
      'otp_expired' || 'invalid_otp' => AuthFailure(tr.authCodeInvalid, field: 'code'),
      'reauthentication_needed' || 'reauthentication_not_valid' => AuthFailure(tr.authNeedsCode, field: 'code'),
      'signup_disabled' => AuthFailure(tr.authSignupDisabled),
      'manual_linking_disabled' => AuthFailure(tr.authLinkingDisabled),
      'session_not_found' || 'refresh_token_not_found' =>
        AuthFailure(tr.authSessionEnded),
      _ => (e.statusCode == '429')
          ? AuthFailure(tr.authTooManyShort)
          : AuthFailure(tr.authGenericError),
    };
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[auth] $message');
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
