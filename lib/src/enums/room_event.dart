enum RoomEvent {
  joinRoom('room.join'),
  joinedRoom('room.joined'),
  leaveRoom('room.leave'),
  update('room.update'),
  error('room.error');

  final String description;

  const RoomEvent(this.description);
}
