import 'room_details.dart';

final class RoomHistory {
  final String roomId;
  final RoomDetails room;
  final List<dynamic> events;
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
    'events': events,
    'connectionId': connectionId,
    'timestamp': timestamp,
  };

  @override
  String toString() => toMap().toString();
}
