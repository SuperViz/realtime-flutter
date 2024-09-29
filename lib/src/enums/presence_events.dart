enum PresenceEvents {
  joinedRoom('presence.joined-room'),
  leave('presence.leave'),
  update('presence.update');

  final String description;

  const PresenceEvents(this.description);
}
