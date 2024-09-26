/// The state of the client
enum ClientState {
  /// In this state the client is connected
  connected('CONNECTED'),

  /// In this state the client is connecting
  connecting('CONNECTING'),

  /// In this state the client is disconnected
  disconnected('DISCONNECTED'),

  /// In this state the client has a connection error
  connectionError('CONNECTION_ERROR'),

  /// In this state the client is reconnecting
  reconnecting('RECONNECTING'),

  /// In this state the client has a reconnect error
  reconnectError('RECONNECT_ERROR');

  final String description;

  const ClientState(this.description);
}
