
/// Events that the server listens to in the presence module
/// - `joinedRoom` - event to indicate a user has joined a room
/// - `leave` - event to indicate a user has left a room
/// - `update` - event to indicate a user has updated their presence
/// - `ERROR` - event to indicate an error in the presence module
enum PresenceEvents {
  joinedRoom('presence.joined-room'),
  leave('presence.leave'),
  update('presence.update'),
  error('presence.error');

  final String description;

  const PresenceEvents(this.description);
}
