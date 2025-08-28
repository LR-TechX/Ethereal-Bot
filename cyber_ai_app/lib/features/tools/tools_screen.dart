import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/password_service.dart';
import '../../core/services/phishing_service.dart';
import '../../core/utils/providers.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  final _passwordController = TextEditingController();
  final _phishingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final wifiAsync = ref.watch(wifiScannerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wi-Fi Scan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            wifiAsync.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SSID: ${data.ssid ?? 'Unknown'}'),
                  Text('Local IP: ${data.localIp ?? 'Unknown'}'),
                  const SizedBox(height: 6),
                  Text('Reachable hosts (${data.reachableIps.length}):'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: data.reachableIps
                        .take(64)
                        .map((ip) => Chip(label: Text(ip)))
                        .toList(),
                  ),
                ],
              ),
              error: (e, st) => Text('Scan failed: $e'),
              loading: () => const LinearProgressIndicator(),
            ),
            const Divider(height: 32),

            const Text('Password Strength', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Enter password'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _PasswordAssessmentView(password: _passwordController.text),

            const Divider(height: 32),

            const Text('Phishing Check', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _phishingController,
              decoration: const InputDecoration(hintText: 'URL or domain'),
              onSubmitted: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _PhishingResultView(input: _phishingController.text),
          ],
        ),
      ),
    );
  }
}

class _PasswordAssessmentView extends StatelessWidget {
  final String password;
  const _PasswordAssessmentView({required this.password});

  @override
  Widget build(BuildContext context) {
    final assessment = PasswordService.instance.assess(password);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Entropy: ${assessment.entropyBits.toStringAsFixed(1)} bits'),
        Text('Verdict: ${assessment.verdict}'),
        if (assessment.feedback.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text('Suggestions:'),
          for (final f in assessment.feedback) Text('- $f'),
        ],
      ],
    );
  }
}

class _PhishingResultView extends StatelessWidget {
  final String input;
  const _PhishingResultView({required this.input});

  @override
  Widget build(BuildContext context) {
    if (input.trim().isEmpty) return const SizedBox.shrink();
    final result = PhishingService.instance.check(input);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(result.suspicious ? 'Suspicious' : 'Looks OK'),
        if (result.reasons.isNotEmpty) ...[
          const SizedBox(height: 6),
          for (final r in result.reasons) Text('- $r'),
        ],
      ],
    );
  }
}