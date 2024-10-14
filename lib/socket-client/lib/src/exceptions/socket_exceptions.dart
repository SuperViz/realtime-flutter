import '../enums/enums.dart';

final class SocketException implements Exception {
  final String errorType;
  final String message;
  final String connectionId;
  final bool needsToDisconnect;
  final SocketExceptionErrorLevel level;

  const SocketException({
    required this.errorType,
    required this.message,
    required this.connectionId,
    required this.needsToDisconnect,
    required this.level,
  });

  factory SocketException.fromMap(Map<String, dynamic> map) {
    return SocketException(
      errorType: map['errorType'] as String,
      message: map['message'] as String,
      connectionId: map['connectionId'] as String,
      needsToDisconnect: map['needsToDisconnect'] as bool,
      level: SocketExceptionErrorLevel.values.firstWhere(
        (level) => level.name == map['level'],
      ),
    );
  }
}
