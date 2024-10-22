/// Events that the server listens to in the presence module
/// - `get` - Event to get the presence list
enum InternalPresenceEvents {
  get('presence.get');

  final String description;

  const InternalPresenceEvents(this.description);
}
