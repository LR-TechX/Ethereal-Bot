import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/settings_model.dart';
import 'knowledge_base_service.dart';
import 'memory_service.dart';

class ChatService {
  ChatService._();
  static final instance = ChatService._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 12),
    contentType: 'application/json',
  ));

  Future<String> getReply({
    required String message,
    required AppSettings settings,
  }) async {
    final kb = KnowledgeBaseService.instance.findAnswer(message);
    if (kb != null) {
      return kb;
    }

    final inMem = MemoryService.instance.getFromMemory(message);
    if (inMem != null) {
      return inMem;
    }

    if (settings.useOnlineIntelligence && settings.proxyUrl.isNotEmpty) {
      try {
        final trimmedBase = settings.proxyUrl.replaceAll(RegExp(r'/+$'), '');
        final url = '$trimmedBase/chat';
        final resp = await _dio.post(url, data: jsonEncode({
          'message': message,
        }));
        final data = resp.data is Map<String, dynamic> ? resp.data as Map<String, dynamic> : jsonDecode(resp.data as String) as Map<String, dynamic>;
        final answer = (data['answer'] as String?)?.trim();
        if (answer != null && answer.isNotEmpty) {
          await MemoryService.instance.saveMemory(message, answer);
          return answer;
        }
      } catch (_) {
        // fallthrough to learning
      }
    }

    await MemoryService.instance.addUnanswered(message);
    return "I'm learning… I'll get better with more information.";
  }
}