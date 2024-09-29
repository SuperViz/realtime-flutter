enum SocketEvents {
  connect('connect'),
  disconnect('disconnect'),
  connectError('connect_error'),
  connectionError('error'),
  reconnect('reconnect'),
  reconnectAttempt('reconnect_attempt'),
  reconnectError('reconnect_error'),
  reconnectFailed('reconnect_failed'),
  error('socket-event.error');

  final String description;

  const SocketEvents(this.description);
}
