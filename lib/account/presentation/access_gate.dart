import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/sync/sync_cubit.dart';
import '../../core/widgets/state_views.dart';
import '../../shell/main_shell.dart';
import '../../tracking/application/tracking_coordinator.dart';
import '../../tracking/application/tracking_links.dart';
import '../application/auth_controller.dart';
import 'auth_pages.dart';

/// The ONLY place that decides what can be opened. Every screen of the
/// product lives under [_AccountHome], which only exists for a permanent
/// account whose data space is open. Without one, only the screens needed to
/// sign in, create an account and recover access are reachable.
///
/// When the person or the account changes, the navigation goes back to the
/// root, so no screen of the previous session stays on the stack.
class AccessGate extends StatefulWidget {
  const AccessGate({super.key});

  @override
  State<AccessGate> createState() => _AccessGateState();
}

class _AccessGateState extends State<AccessGate> {
  /// Account whose scope is open and ready.
  String? _readyFor;
  String? _opening;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _react(context.read<AuthController>().state);
    });
  }

  Future<void> _react(AccessState s) async {
    final uid = s.status == AccessStatus.authenticated ? s.userId : null;
    if (uid == _readyFor && uid != null) return;
    // Anything open belongs to the previous state.
    AppNavigator.key.currentState?.popUntil((r) => r.isFirst);
    // A snackbar (e.g. "Undo") of the previous session must not survive it:
    // it would sit over the sign-in button and undo nothing meaningful.
    if (mounted) ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    if (uid == null) {
      if (_readyFor != null || AccountScope.isOpen) {
        setState(() => _readyFor = null);
        await AccountScope.close();
      }
      return;
    }
    if (_opening == uid) return;
    _opening = uid;
    setState(() => _readyFor = null);
    await AccountScope.open(uid);
    if (!mounted) return;
    // A newer state may have arrived while opening.
    final now = context.read<AuthController>().state;
    if (now.status == AccessStatus.authenticated && now.userId == uid) {
      setState(() => _readyFor = uid);
    } else {
      await AccountScope.close();
    }
    _opening = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthController, AccessState>(
      listenWhen: (a, b) => a.status != b.status || a.userId != b.userId,
      listener: (context, s) => _react(s),
      builder: (context, s) {
        switch (s.status) {
          case AccessStatus.initializing:
            return const Scaffold(body: LoadingView());
          case AccessStatus.signedOut:
            return const SignInPage();
          case AccessStatus.reauthRequired:
            return const SignInPage(reauth: true);
          case AccessStatus.passwordRecovery:
            return const NewPasswordPage();
          case AccessStatus.authenticated:
            final uid = s.userId!;
            if (_readyFor != uid) return const Scaffold(body: LoadingView());
            return _AccountHome(key: ValueKey(uid));
        }
      },
    );
  }
}

/// The product for one account. Rebuilt from scratch (new key) when the
/// account changes, so nothing of the previous one survives in memory.
class _AccountHome extends StatefulWidget {
  const _AccountHome({super.key});

  @override
  State<_AccountHome> createState() => _AccountHomeState();
}

class _AccountHomeState extends State<_AccountHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !AccountScope.isOpen) return;
      getIt<TrackingCoordinator>().start();
      getIt<TrackingLinks>().start();
    });
  }

  /// Straight to the home: the cloud is read in the background (the sync
  /// started with the account scope) and the screens update as rows arrive.
  @override
  Widget build(BuildContext context) =>
      BlocProvider.value(value: getIt<SyncCubit>(), child: const MainShell());
}
