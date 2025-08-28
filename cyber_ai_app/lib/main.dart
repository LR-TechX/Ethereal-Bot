import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'core/services/notification_service.dart';

Future<void> _ensurePermissions() async {
  if (Platform.isAndroid) {
    await Permission.notification.request();
    await Permission.location.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await _ensurePermissions();

  // Init local notifications
  await NotificationService.instance.initialize();

  // Init alarm manager for scheduled tips
  try {
    await AndroidAlarmManager.initialize();
  } catch (_) {}

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CyberAIApp());
}