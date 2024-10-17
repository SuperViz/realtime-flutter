enum RealtimeChannelEvent {
  realtimeChannelStateChanged('realtime-channel.state-changed');

  final String description;

  const RealtimeChannelEvent(this.description);
}
