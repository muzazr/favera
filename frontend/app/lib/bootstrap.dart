import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

import 'app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent system status bar and navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Setup Flutter error boundary
  FlutterError.onError = (FlutterErrorDetails details) {
    log(
      'FlutterError: ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
      name: 'FaveraBootstrap',
    );
    FlutterError.presentError(details);
  };

  // Setup PlatformDispatcher error boundary for uncaught async errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    log(
      'PlatformError: $error',
      error: error,
      stackTrace: stack,
      name: 'FaveraBootstrap',
    );
    return true;
  };

  // Custom ErrorWidget for UI crashes in production/release mode
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE85B5B),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Terjadi Kendala pada Tampilan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2635),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplikasi mendeteksi masalah kecil. Coba muat ulang halaman ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667085),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                SingleChildScrollView(
                  child: Text(
                    details.exceptionAsString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE85B5B),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  };

  runApp(
    const ProviderScope(
      child: FaveraApp(),
    ),
  );
}
