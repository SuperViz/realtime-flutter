import 'dart:async';

import '../../enums/enums.dart';
import '../../exceptions/exceptions.dart';
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
    _socket.onEvent(SocketEvents.connect.description, _onConnect);
    _socket.onEvent(SocketEvents.reconnect.description, _onReconnect);
    _socket.onEvent(SocketEvents.disconnect.description, _onDisconnect);
    _socket.onEvent(SocketEvents.connectError.description, _onConnectError);
    _socket.onEvent(SocketEvents.reconnectError.description, _onReconnectError);
    _socket.onEvent(SocketEvents.connectionError.description, _onConnectionError);
    _socket.onEvent(SocketEvents.reconnectFailed.description, _onReconnectFailed);
    _socket.onEvent(SocketEvents.reconnectAttempt.description, _onReconnecAttempt);

    _socket.onEvent(SocketEvents.error.description, _onCustomError);
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

  void _onConnect(dynamic _) {
    _logger.log(name: 'connection @ on connect', description: 'Connected to the socket');
    _changeConnectionState(ClientState.connected);
  }

  void _onDisconnect(dynamic _) {
    _logger.log(name: 'connection @ on disconnect', description: 'Disconnected from the socket');
    _changeConnectionState(ClientState.disconnected);
  }

  void _onReconnect(dynamic _) {
    _logger.log(name: 'connection @ on reconnect', description: 'Reconnected to the socket');
    _changeConnectionState(ClientState.connected);
  }

  void _onReconnectFailed(dynamic _) {
    _logger.log(name: 'connection @ on reconnect failed', description: 'Failed to reconnect to the socket');
    _changeConnectionState(ClientState.reconnectError);
  }

  void _onConnectError(dynamic data) {
    final error = SocketException.fromMap(data[0]);

    _logger.log(name: 'connection @ on connect error', description: 'Connection error', error: Exception(error));
    _changeConnectionState(ClientState.connectionError);
  }

  void _onConnectionError(dynamic data) {
    final error = Exception(data['message']);

    _logger.log(name: 'connection @ on connection error', description: 'Connection error', error: error);
    _changeConnectionState(ClientState.connectionError, error.toString());
  }

  void _onReconnectError(dynamic data) {
    final error = SocketException.fromMap(data[0]);

    _logger.log(name: 'connection @ on reconnect error', description: 'Reconnect error');
    _changeConnectionState(ClientState.reconnectError, error.message);
  }

  void _onReconnecAttempt(dynamic data) {
    final attempt = data[0]['attempt'] as int;

    _logger.log(name: 'connection @ on reconnect attempt', description: 'Reconnect attempt $attempt');
    _changeConnectionState(ClientState.reconnecting, 'Reconnect attempt $attempt');
  }

  void _onCustomError(dynamic data) {
    final error = SocketException.fromMap(data[0]);

    if (error.needsToDisconnect) {
      _socket.disconnect();
      _changeConnectionState(ClientState.disconnected, error.errorType);
    }

    _logger.log(
      name: '[SuperViz]',
      description: '\n- Error: ${error.errorType}\n- Message: ${error.message}'
    );
  }
}
