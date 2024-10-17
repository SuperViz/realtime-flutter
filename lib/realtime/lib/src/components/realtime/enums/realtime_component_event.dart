enum RealtimeComponentEvent {
  realtimeStateChanged('realtime-component.state-changed');

  final String description;

  const RealtimeComponentEvent(this.description);
}
