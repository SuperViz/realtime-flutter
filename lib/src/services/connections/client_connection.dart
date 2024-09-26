import 'dart:async';

import '../../enums/enums.dart';
import '../../exceptions/exceptions.dart';
import '../../interfaces/interfaces.dart';
import '../../types/types.dart';
import '../../utils/utils.dart';
import 'connection_state.dart';

final class ClientConnection {
  final SocketClient _socket;

  late Logger logger;
  late StreamController<ConnectionState> _stateController;
  late ClientState state;

  ClientConnection({
    required SocketClient socket,
  }) : _socket = socket {
    logger = DebuggerLoggerAdapter(scope: '[SuperViz]');
    _subscribeToManagerEvents();
    _stateController = StreamController<ConnectionState>();
  }

  void on({
    required void Function(ConnectionState connectionState) next,
    required ErrorCallback? error,
  }) {
    if (_stateController.isClosed) {
      _stateController = StreamController<ConnectionState>();
    }

    _stateController.stream.listen(next, onError: error);
  }

  void off() {
    if (_stateController.isClosed) return;

    _stateController.close();
  }

  void _subscribeToManagerEvents() {
    _socket.onEvent(SocketEvent.connect.description, _onConnect);
    _socket.onEvent(SocketEvent.reconnect.description, _onReconnect);
    _socket.onEvent(SocketEvent.disconnect.description, _onDisconnect);
    _socket.onEvent(SocketEvent.connectError.description, _onConnectError);
    _socket.onEvent(SocketEvent.reconnectError.description, _onReconnectError);
    _socket.onEvent(SocketEvent.connectionError.description, _onConnectionError);
    _socket.onEvent(SocketEvent.reconnectFailed.description, _onReconnectFailed);
    _socket.onEvent(SocketEvent.reconnectAttempt.description, _onReconnecAttempt);
  }

   /// Change the state of the connection
  void _changeConnectionState(ClientState state, [String? reason]) {
    this.state = state;

    if (_stateController.isClosed) return;

    _stateController.add(
      ConnectionState(
        state: state,
        reason: reason,
      ),
    );
  }

  void _onConnect() {
    logger.log(name: 'connection @ on connect', description: 'Connected to the socket');
    _changeConnectionState(ClientState.connected);
  }

  void _onDisconnect() {
    logger.log(name: 'connection @ on disconnect', description: 'Disconnected from the socket');
    _changeConnectionState(ClientState.disconnected);
  }

  void _onReconnect() {
    logger.log(name: 'connection @ on reconnect', description: 'Reconnected to the socket');
    _changeConnectionState(ClientState.connected);
  }

  void _onReconnectFailed() {
    logger.log(name: 'connection @ on reconnect failed', description: 'Failed to reconnect to the socket');
    _changeConnectionState(ClientState.reconnectError);
  }

  void _onConnectError(SocketException error) {
    logger.log(name: 'connection @ on connect error', description: 'Connection error', error: error);
    _changeConnectionState(ClientState.connectionError);
  }

  void _onConnectionError(SocketException error) {
    logger.log(name: 'connection @ on connection error', description: 'Connection error', error: error);
    _changeConnectionState(ClientState.connectionError, error.reason);
  }

  void _onReconnectError(SocketException error) {
    logger.log(name: 'connection @ on reconnect error', description: 'Reconnect error');
    _changeConnectionState(ClientState.reconnectError, error.reason);
  }

  void _onReconnecAttempt(int attempt) {
    logger.log(name: 'connection @ on reconnect attempt', description: 'Reconnect attempt $attempt');
    _changeConnectionState(ClientState.reconnecting, 'Reconnect attempt $attempt');
  }
}
