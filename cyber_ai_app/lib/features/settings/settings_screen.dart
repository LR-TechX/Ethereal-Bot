import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/settings_model.dart';
import '../../core/services/memory_service.dart';
import '../../core/utils/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _proxyController;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _proxyController = TextEditingController(text: s.proxyUrl);
  }

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Use Online Intelligence'),
            subtitle: const Text('Enable proxy fallback for answers'),
            value: settings.useOnlineIntelligence,
            onChanged: (v) {
              ref.read(settingsProvider.notifier).update(settings.copyWith(useOnlineIntelligence: v));
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _proxyController,
            decoration: const InputDecoration(
              labelText: 'LLM_PROXY_URL',
              hintText: 'https://your-proxy.example.com',
            ),
            onChanged: (v) => ref.read(settingsProvider.notifier).update(settings.copyWith(proxyUrl: v.trim())),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await MemoryService.instance.clearMemory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Learned memory cleared.')));
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear Learned Memory'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final jsonStr = await MemoryService.instance.exportMemoryJson();
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Exported Memory (JSON)'),
                  content: SingleChildScrollView(child: Text(jsonStr)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.save_alt),
            label: const Text('Export Memory (JSON)'),
          ),
          const SizedBox(height: 24),
          const AboutListTile(
            applicationName: 'CyberAI',
            applicationVersion: '1.0.0',
            applicationLegalese: 'Cybersecurity assistant with local memory and tools.',
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}