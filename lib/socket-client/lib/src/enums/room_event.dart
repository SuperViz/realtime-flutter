/// events that the server listens to in the room module
/// - `joinRoom` - Event to join a room.
/// - `joinedRoom` - Event to indicate a user has joined a room.
/// - `leaveRoom` - Event to leave a room.
/// - `update` - Event to update a room.
/// - `error` - Event to indicate an error in the room module.
enum RoomEvent {
  joinRoom('room.join'),
  joinedRoom('room.joined'),
  leaveRoom('room.leave'),
  update('room.update'),
  error('room.error');

  final String description;

  const RoomEvent(this.description);
}
