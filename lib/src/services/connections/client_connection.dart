import 'dart:async';

import '../../enums/enums.dart';
import '../../interfaces/interfaces.dart';
import '../../types/types.dart';
import '../../utils/utils.dart';
import 'connection_state.dart';

final class ClientConnection {
  final SocketClient _socket;

  late Logger _logger;
  late StreamController<ConnectionState> _stateController;
  ClientState state = ClientState.disconnected;

  ClientConnection({
    required SocketClient socket,
  }) : _socket = socket {
    _logger = DebuggerLoggerAdapter(scope: '@superviz/socket-client/realtime');
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
    _socket.onEvent(SocketEvent.connect.description, (_) => _onConnect());
    _socket.onEvent(SocketEvent.reconnect.description, (_) => _onReconnect());
    _socket.onEvent(SocketEvent.disconnect.description, (_) => _onDisconnect());
    _socket.onEvent(SocketEvent.reconnectFailed.description, (_) => _onReconnectFailed());
    _socket.onEvent(SocketEvent.connectError.description, (error) => _onConnectError(error));
    _socket.onEvent(SocketEvent.reconnectError.description, (error) => _onReconnectError(error));
    _socket.onEvent(SocketEvent.connectionError.description, (error) => _onConnectionError(error));
    _socket.onEvent(SocketEvent.reconnectAttempt.description, (attempt) => _onReconnecAttempt(attempt));

    _socket.onEvent(SocketEvent.error.description, onCustomError);
  }

   /// Change the state of the connection
  void _changeConnectionState(ClientState newState, [String? reason]) {
    state = newState;

    if (_stateController.isClosed) return;

    _stateController.add(
      ConnectionState(
        state: newState,
        reason: reason,
      ),
    );
  }

  void _onConnect() {
    _logger.log(name: 'connection @ on connect', description: 'Connected to the socket');
    _changeConnectionState(ClientState.connected);
  }

  void _onDisconnect() {
    _logger.log(name: 'connection @ on disconnect', description: 'Disconnected from the socket');
    _changeConnectionState(ClientState.disconnected);
  }

  void _onReconnect() {
    _logger.log(name: 'connection @ on reconnect', description: 'Reconnected to the socket');
    _changeConnectionState(ClientState.connected);
  }

  void _onReconnectFailed() {
    _logger.log(name: 'connection @ on reconnect failed', description: 'Failed to reconnect to the socket');
    _changeConnectionState(ClientState.reconnectError);
  }

  void _onConnectError(String error) {
    _logger.log(name: 'connection @ on connect error', description: 'Connection error', error: Exception(error));
    _changeConnectionState(ClientState.connectionError);
  }

  void _onConnectionError(String error) {
    _logger.log(name: 'connection @ on connection error', description: 'Connection error', error: Exception(error));
    _changeConnectionState(ClientState.connectionError, error);
  }

  void _onReconnectError(String error) {
    _logger.log(name: 'connection @ on reconnect error', description: 'Reconnect error');
    _changeConnectionState(ClientState.reconnectError, error);
  }

  void _onReconnecAttempt(int attempt) {
    _logger.log(name: 'connection @ on reconnect attempt', description: 'Reconnect attempt $attempt');
    _changeConnectionState(ClientState.reconnecting, 'Reconnect attempt $attempt');
  }

  void onCustomError(dynamic error) {
    final errorMap = error[0];

    if (errorMap['needsToDisconnect']) {
      _socket.disconnect();
      _changeConnectionState(ClientState.disconnected, error['errorType']);
    }

    _logger.log(
      name: '[SuperViz]',
      description: '\n- Error: ${errorMap['errorType']}\n- Message: ${errorMap['message']}'
    );
  }
}
