import 'dart:convert';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'notification_service.dart';

class TipsService {
  TipsService._();
  static final instance = TipsService._();

  List<String> _tips = [];

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/tips.json');
    final list = (jsonDecode(raw) as List).map((e) => e.toString()).toList();
    _tips = list;
  }

  String randomTip() {
    if (_tips.isEmpty) return 'Stay safe online: enable MFA everywhere.';
    final rng = Random();
    return _tips[rng.nextInt(_tips.length)];
  }

  Future<void> scheduleDailyTip() async {
    // Daily every 24h
    await AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      4242,
      _alarmCallback,
      exact: true,
      wakeup: true,
    );
  }
}

@pragma('vm:entry-point')
Future<void> _alarmCallback() async {
  final tip = TipsService.instance.randomTip();
  await NotificationService.instance.initialize();
  await NotificationService.instance.showNotification(
    id: 202,
    title: 'CyberAI Daily Tip',
    body: tip,
  );
}