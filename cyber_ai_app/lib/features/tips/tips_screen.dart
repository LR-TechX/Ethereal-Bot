import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/providers.dart';

class TipsScreen extends ConsumerWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tip = ref.watch(tipsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Tips')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tip,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(tipsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Another Tip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}