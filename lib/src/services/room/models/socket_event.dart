import 'models.dart';

final class SocketEvent<T> {
  final String name;
  final String roomId;
  final String connectionId;
  final UserPresence? presence;
  final T data;
  final int timestamp;

  const SocketEvent({
    required this.name,
    required this.roomId,
    required this.connectionId,
    required this.presence,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'roomId': roomId,
    'connectionId': connectionId,
    'presence': presence,
    'data': data,
    'timestamp': timestamp,
  };

  factory SocketEvent.fromMap(Map map) => SocketEvent(
    name: map['name'] as String,
    roomId: map['roomId'] as String,
    connectionId: map['connectionId'] as String,
    presence: map['presence'] != null
      ? UserPresence.fromMap(map['presence'])
      : null,
    data: map['data'],
    timestamp: map['timestamp'] as int,
  );
}

