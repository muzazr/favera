import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import 'theme/app_theme.dart';

class FaveraApp extends ConsumerWidget {
  const FaveraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return MaterialApp(
      title: 'Favera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_rounded,
                size: 64,
                color: Color(0xFF19C66A),
              ),
              const SizedBox(height: 16),
              const Text(
                'Favera',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2635),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Satu ruang untuk uang dan perasaan keluarga.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9F7E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Mode: ${config.appMode.toUpperCase()} | Env: ${config.environment.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF087A54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
