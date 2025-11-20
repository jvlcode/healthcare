import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthcare/services/auth_service.dart';

class ReachabilityController extends ChangeNotifier {
  bool _isServerReachable = true;
  bool get isServerReachable => _isServerReachable;

  final AuthService _authService = AuthService();

  // 🔥 Broadcast reachability changes to ALL screens
  final StreamController<bool> _reachabilityStream =
      StreamController<bool>.broadcast();

  Stream<bool> get reachabilityStream => _reachabilityStream.stream;

  void updateReachability(bool reachable) {
    if (_isServerReachable != reachable) {
      _isServerReachable = reachable;

      // Notify ALL listeners (all screens)
      _reachabilityStream.add(reachable);
    }

    notifyListeners();
  }

  Future<void> checkServer() async {
    final reachable = await _authService.isServerReachable();
    updateReachability(reachable);
  }

  @override
  void dispose() {
    _reachabilityStream.close();
    super.dispose();
  }

  void startMonitoring({Duration interval = const Duration(seconds: 10)}) {
    Timer.periodic(interval, (timer) async {
      await checkServer();
    });
  }
}
