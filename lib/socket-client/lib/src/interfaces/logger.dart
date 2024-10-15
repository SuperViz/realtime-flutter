import 'dart:async';

abstract interface class Logger {
  FutureOr<void> log({
    required String name,
    String description,
    Exception? error,
    StackTrace? stackTrace,
  });
}
