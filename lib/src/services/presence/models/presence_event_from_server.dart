import 'dart:convert';

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
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'roomKey': roomKey,
      'roomId': roomId,
      ...super.toMap(),
    };
  }

  @override
  String toJson() => json.encode(toMap());

  factory PresenceEventFromServer.fromJson(String source) => PresenceEventFromServer.fromMap(
    json.decode(source) as Map<String, dynamic>,
  );
}
