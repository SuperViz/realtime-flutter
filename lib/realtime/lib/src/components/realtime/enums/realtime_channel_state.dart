enum RealtimeChannelState {
  disconnected('DISCONNECTED'),
  connected('CONNECTED'),
  connecting('CONNECTING');

  final String description;

  const RealtimeChannelState(this.description);
}
