base class PresenceEvent {
  final String id;
  final String name;
  final String? connectionId;
  final dynamic data;
  final int timestamp;

  const PresenceEvent({
    required this.id,
    required this.name,
    required this.connectionId,
    required this.data,
    required this.timestamp,
  });

  factory PresenceEvent.fromMap(Map<String, dynamic> map) {
    return PresenceEvent(
      id: map['id'] as String,
      name: map['name'] as String,
      connectionId: map['connectionId'] as String?,
      data: map['data'] as dynamic,
      timestamp: map['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'connectionId': connectionId,
      'data': data,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'PresenceEvent(id: $id, name: $name, connectionId: $connectionId, data: $data, timestamp: $timestamp)';
  }
}
