import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class KnowledgeBaseService {
  KnowledgeBaseService._();
  static final instance = KnowledgeBaseService._();

  Map<String, String> _qa = {};

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/knowledge_base.json');
    final data = jsonDecode(raw) as List<dynamic>;
    _qa = {
      for (final item in data)
        (item['q'] as String).trim().toLowerCase(): (item['a'] as String).trim()
    };
  }

  String? findAnswer(String message) {
    if (_qa.isEmpty) return null;
    final key = message.trim().toLowerCase();
    if (_qa.containsKey(key)) return _qa[key];

    // simple contains match
    for (final entry in _qa.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return null;
  }
}