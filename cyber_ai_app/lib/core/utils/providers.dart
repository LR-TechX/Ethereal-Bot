import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../models/settings_model.dart';
import '../services/chat_service.dart';
import '../services/knowledge_base_service.dart';
import '../services/memory_service.dart';
import '../services/tips_service.dart';
import '../services/wifi_scanner_service.dart';

final settingsProvider = StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController();
});

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController() : super(AppSettings.defaults) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox<String>('settings_box');
    final raw = box.get('settings');
    if (raw != null) {
      state = AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    await KnowledgeBaseService.instance.load();
    await MemoryService.instance.init();
    await TipsService.instance.load();
    await TipsService.instance.scheduleDailyTip();
  }

  Future<void> update(AppSettings newState) async {
    state = newState;
    final box = Hive.box<String>('settings_box');
    await box.put('settings', jsonEncode(state.toJson()));
  }
}

final chatProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  return ChatController(ref.read);
});

class ChatController extends StateNotifier<List<ChatMessage>> {
  final Reader read;
  ChatController(this.read) : super(const []);

  Future<void> send(String message) async {
    final id = const Uuid().v4();
    final user = ChatMessage.user(id, message);
    state = [...state, user];

    final settings = read(settingsProvider);
    final reply = await ChatService.instance.getReply(message: message, settings: settings);
    final bot = ChatMessage.bot(const Uuid().v4(), reply);
    state = [...state, bot];
  }
}

final wifiScannerProvider = FutureProvider<WifiScannerResult>((ref) async {
  return WifiScannerService.instance.scan();
});

final tipsProvider = Provider<String>((ref) {
  return TipsService.instance.randomTip();
});