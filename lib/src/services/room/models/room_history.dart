import 'models.dart';

final class RoomHistory {
  final String roomId;
  final RoomDetails room;
  final List<SocketEvent> events;
  final String connectionId;
  final DateTime timestamp;

  const RoomHistory({
    required this.roomId,
    required this.room,
    required this.events,
    required this.connectionId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'roomId': roomId,
    'room': room.toMap(),
    'events': events.map((event) => event.toMap()),
    'connectionId': connectionId,
    'timestamp': timestamp,
  };

  @override
  String toString() => toMap().toString();
}
