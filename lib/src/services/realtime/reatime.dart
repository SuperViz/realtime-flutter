import '../../enums/enums.dart';
import '../../interfaces/interfaces.dart';
import '../../interfaces/params/params.dart';
import '../connections/connections.dart';
import '../room/models/models.dart';
import '../room/room.dart';

final class Realtime {
  final String _apiKey;
  final String _environment;
  final UserPresence _presence;
  final String _secret;
  final String _clientId;

  late final SocketClient _socket;
  late final ClientConnection _clientConnection;

  ClientConnection get clientConnection => _clientConnection;

  Realtime({
    required SocketClient socket,
    required String apiKey,
    required String environment,
    required UserPresence presence,
    required String secret,
    required String clientId,
  }) : _socket = socket,
  _apiKey = apiKey,
  _environment = environment,
  _presence = presence,
  _secret = secret,
  _clientId = clientId {
    _socket.connect(
      SocketConnectParams(
        apiKey: _apiKey,
        secretKey: _secret,
        clientId: _clientId,
        environment: _environment
      ),
    );

    _clientConnection = ClientConnection(socket: _socket);
  }

  ClientState get state => _clientConnection.state;

  /// - `roomName` - The room name
  /// - `maxConnections` - The maximum number of connections allowed in the room
  Room connect(String roomName, int? maxConnections) {
    return Room.register(
      io: _socket,
      user: _presence,
      roomName: roomName,
      apiKey: _apiKey,
      maxConnections: maxConnections,
    );
  }

  void destroy() {
    _socket.disconnect();
    _clientConnection.off();
  }
}
