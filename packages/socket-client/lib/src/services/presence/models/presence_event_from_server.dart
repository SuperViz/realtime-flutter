import 'model.dart';

final class PresenceEventFromServer extends PresenceEvent {
  final String roomKey;
  final String roomId;

  const PresenceEventFromServer({
    required super.id,
    required super.name,
    required super.connectionId,
    required super.data,
    required super.timestamp,
    required this.roomKey,
    required this.roomId,
  });

  factory PresenceEventFromServer.fromMap(Map<String, dynamic> data) {
    return PresenceEventFromServer(
      id: data['id'],
      name: data['name'],
      connectionId: data['connectionId'],
      data: data['data'],
      timestamp: data['timestamp'],
      roomKey: data['roomKey'],
      roomId: data['roomId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'roomKey': roomKey,
      'roomId': roomId,
      ...super.toJson(),
    };
  }

  @override
  String toString() =>
      'PresenceEventFromServer(roomKey: $roomKey, roomId: $roomId)';
}
