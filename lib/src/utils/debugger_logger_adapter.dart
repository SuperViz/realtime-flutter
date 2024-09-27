import 'dart:async';
import 'dart:developer' as developer;

import '../interfaces/interfaces.dart';

final class DebuggerLoggerAdapter implements Logger {
  final String scope;

  DebuggerLoggerAdapter({required this.scope});

  @override
  FutureOr<void> log({
    required String name,
    required String description,
    Exception? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '$name: $description',
      name: scope,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
