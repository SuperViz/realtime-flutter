final class PresenceEvent {
  final String id;
  final String name;
  final String connectionId;
  final dynamic data;
  final int timestamp;

  const PresenceEvent({
    required this.id,
    required this.name,
    required this.connectionId,
    required this.data,
    required this.timestamp,
  });
}

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

  factory PresenceEventFromServer.fromMap(Map data) {
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
}
