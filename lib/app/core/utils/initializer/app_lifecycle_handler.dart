import 'package:flutter/material.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  final void Function(AppLifecycleState state)? onStateChanged;
  final VoidCallback? onResumed;
  final VoidCallback? onPaused;
  final VoidCallback? onInactive;
  final VoidCallback? onDetached;

  AppLifecycleState? _previousState;

  AppLifecycleHandler({
    this.onStateChanged,
    this.onResumed,
    this.onPaused,
    this.onInactive,
    this.onDetached,
  });

  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_previousState == state) return;
    _previousState = state;

    debugPrint("📱 App lifecycle: $state");
    onStateChanged?.call(state);

    switch (state) {
      case AppLifecycleState.resumed:
        onResumed?.call();
        break;
      case AppLifecycleState.paused:
        onPaused?.call();
        break;
      case AppLifecycleState.inactive:
        onInactive?.call();
        break;
      case AppLifecycleState.detached:
        onDetached?.call();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
