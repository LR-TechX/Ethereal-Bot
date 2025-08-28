import 'dart:convert';

import 'package:hive/hive.dart';

class MemoryService {
  MemoryService._();
  static final instance = MemoryService._();

  static const String memoryBox = 'memory_box'; // map Q -> A
  static const String unansweredBox = 'unanswered_box'; // list of Q
  static const String chatHistoryBox = 'chat_history_box'; // list json

  Future<void> init() async {
    await Hive.openBox<String>(memoryBox);
    await Hive.openBox<String>(unansweredBox);
    await Hive.openBox<String>(chatHistoryBox);
  }

  Future<void> saveMemory(String question, String answer) async {
    final box = Hive.box<String>(memoryBox);
    await box.put(_normalize(question), answer);
  }

  String? getFromMemory(String question) {
    final box = Hive.box<String>(memoryBox);
    return box.get(_normalize(question));
  }

  Future<void> addUnanswered(String question) async {
    final box = Hive.box<String>(unansweredBox);
    await box.add(question);
  }

  Future<List<String>> getUnanswered() async {
    final box = Hive.box<String>(unansweredBox);
    return box.values.toList();
  }

  Future<void> clearMemory() async {
    await Hive.box<String>(memoryBox).clear();
  }

  Future<String> exportMemoryJson() async {
    final box = Hive.box<String>(memoryBox);
    final map = <String, String>{};
    for (final key in box.keys) {
      final k = key as String;
      map[k] = box.get(k)!;
    }
    return jsonEncode(map);
  }

  String _normalize(String text) => text.trim().toLowerCase();
}