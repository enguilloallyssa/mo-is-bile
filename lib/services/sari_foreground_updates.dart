import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'sari_live_data.dart';

/// Foreground-only unread counters from GET /api/v1/updates.
/// This is polling, NOT FCM push and not a background service.
class SariForegroundUpdates extends ChangeNotifier with WidgetsBindingObserver {
  SariForegroundUpdates._();
  static final SariForegroundUpdates instance = SariForegroundUpdates._();

  Timer? _timer;
  bool _active = false;
  bool _requesting = false;
  bool loaded = false;
  String? role;
  int unreadNotifications = 0;
  int unreadMessages = 0;
  int latestNotificationId = 0;
  int latestMessageId = 0;

  void start() {
    if (_active) return;
    _active = true;
    WidgetsBinding.instance.addObserver(this);
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 40), (_) => refresh());
  }

  void stop() {
    if (!_active) return;
    _active = false;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    loaded = false;
    role = null;
    unreadNotifications = 0;
    unreadMessages = 0;
    latestNotificationId = 0;
    latestMessageId = 0;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_active) return;
    if (state == AppLifecycleState.resumed) {
      _timer ??= Timer.periodic(const Duration(seconds: 40), (_) => refresh());
      refresh();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  Future<void> refresh() async {
    if (!_active || _requesting) return;
    _requesting = true;
    try {
      if (!await SariLiveData.instance.hasAccessToken()) return;
      final response = await SariLiveData.instance.mobileUpdates();
      if (!_active) return;
      final raw = response['data'];
      if (raw is! Map) return;
      role = raw['role']?.toString();
      unreadNotifications = _int(raw['unread_notifications']);
      unreadMessages = _int(raw['unread_messages']);
      latestNotificationId = _int(raw['latest_notification_id']);
      latestMessageId = _int(raw['latest_message_id']);
      loaded = true;
      notifyListeners();
    } catch (_) {
      // No synthetic data, and no logout on a transient network failure.
    } finally {
      _requesting = false;
    }
  }
}
