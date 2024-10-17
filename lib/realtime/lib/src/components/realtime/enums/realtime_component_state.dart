enum RealtimeComponentState {
  started('STARTED'),
  stopped('STOPPED');

  final String description;

  const RealtimeComponentState(this.description);
}
