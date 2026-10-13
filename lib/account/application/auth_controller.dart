import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../../core/data/device_store.dart';
import '../data/legacy_data.dart';

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

  /// Opened from a password reset link: new password first, nothing else.
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

  /// 'email', 'password' or null for the whole form.
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
    final session = _auth.currentSession;
    // Notes the owner of the old records before anything else can change the
    // session (only an anonymous session restored from disk can tell).
    final restored = session?.user;
    await _legacy.recordOwner(
        restored != null && restored.isAnonymous ? restored.id : null);

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
            notice: 'Esse link expirou ou já foi usado. Peça outro e abra-o '
                'neste aparelho. Se você confirmou o e-mail em outro aparelho, '
                'é só entrar com e-mail e senha.'));
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
      final converting = conversion?['uid'] == user.id;
      emit(AccessState(
        status: converting ? AccessStatus.emailPending : AccessStatus.legacyAnonymous,
        userId: user.id,
        pendingEmail: converting ? conversion!['email'] as String? : null,
        converting: converting,
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
      final sameEmail = recovery['email'] == null || recovery['email'] == user.email;
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
        data: {'display_name': name.trim()},
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
      throw const AuthFailure('Não há uma sessão antiga para converter.');
    }
    try {
      await _auth.updateUser(
        UserAttributes(email: email.trim(), data: {'display_name': name.trim()}),
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
      throw AuthFailure('Aguarde $resendWaitSeconds s para pedir outro e-mail.');
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

  Future<void> sendPasswordReset(String email) async {
    _requireCloud();
    try {
      await _device.setString(
          _recoveryKey,
          jsonEncode({
            'email': email.trim(),
            'at': DateTime.now().toUtc().toIso8601String(),
          }));
      await _auth.resetPasswordForEmail(email.trim(), redirectTo: redirectUrl);
    } on AuthException catch (e) {
      throw _map(e);
    }
  }

  /// New password after a reset link, or the first password of a converted
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
  /// link session must not open the product by the back door).
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
    if (email == null) throw const AuthFailure('Entre novamente para continuar.');
    try {
      final res = await _auth.signInWithPassword(email: email, password: password);
      if (res.user?.id != state.userId) {
        throw const AuthFailure('Conta diferente da sessão atual.');
      }
    } on AuthException catch (e) {
      throw _map(e);
    }
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
      throw const AuthFailure(
          'Sem conexão com o servidor agora. Tente de novo em instantes.');
    }
  }

  AuthFailure _map(AuthException e) {
    if (e is AuthRetryableFetchException) {
      return const AuthFailure('Sem conexão. Confira a internet e tente de novo.');
    }
    final code = e.code ?? '';
    return switch (code) {
      'invalid_credentials' =>
        const AuthFailure('E-mail ou senha incorretos.', field: 'password'),
      'email_not_confirmed' => const AuthFailure(
          'Confirme seu e-mail antes de entrar. Procure o link na sua caixa de '
          'entrada (e no spam).'),
      'user_already_exists' || 'email_exists' => const AuthFailure(
          'Já existe uma conta com esse e-mail. Entre com ela ou recupere a senha.',
          field: 'email'),
      'weak_password' => const AuthFailure(
          'Senha fraca. Use pelo menos 8 caracteres, misturando letras e números.',
          field: 'password'),
      'same_password' => const AuthFailure(
          'A nova senha precisa ser diferente da atual.',
          field: 'password'),
      'over_email_send_rate_limit' || 'over_request_rate_limit' => const AuthFailure(
          'Muitas tentativas. Espere alguns minutos e tente de novo.'),
      'email_address_invalid' || 'validation_failed' =>
        const AuthFailure('Confira o e-mail digitado.', field: 'email'),
      'reauthentication_needed' || 'reauthentication_not_valid' => const AuthFailure(
          'Por segurança, confirme com o código enviado ao seu e-mail.'),
      'signup_disabled' => const AuthFailure(
          'Cadastro desativado no servidor no momento.'),
      'manual_linking_disabled' => const AuthFailure(
          'A conversão da conta antiga não está liberada no servidor ainda. Você '
          'pode criar uma conta nova e importar os registros depois.'),
      'session_not_found' || 'refresh_token_not_found' =>
        const AuthFailure('Sua sessão terminou. Entre novamente.'),
      _ => (e.statusCode == '429')
          ? const AuthFailure('Muitas tentativas. Espere alguns minutos.')
          : const AuthFailure('Não foi possível concluir agora. Tente de novo.'),
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
