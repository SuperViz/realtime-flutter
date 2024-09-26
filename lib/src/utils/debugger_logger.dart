import 'dart:async';
import 'dart:developer' as developer;

import '../interfaces/interfaces.dart';

final class DebuggerLogger implements Logger {
  @override
  FutureOr<void> log({
    required String name,
    required String description,
  }) {
    developer.log(description, name: name);
  }
}
