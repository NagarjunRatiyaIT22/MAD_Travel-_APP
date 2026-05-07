import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'notification_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  StreamSubscription? _subscription;
  bool _wasOffline = false;

  void initialize(BuildContext context) {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isOffline = results.isEmpty || results.contains(ConnectivityResult.none);
      
      if (isOffline) {
        _wasOffline = true;
      } else if (_wasOffline) {
        // Internet came back, simulate sync
        _wasOffline = false;
        _simulateSync(context);
      }
    });
  }

  void _simulateSync(BuildContext context) async {
    NotificationService.showSnackBar(context, 'Back online. Syncing data...');
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (context.mounted) {
      NotificationService.showSnackBar(context, 'Sync complete! ✅');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
