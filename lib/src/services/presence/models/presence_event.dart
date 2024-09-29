base class PresenceEvent {
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
