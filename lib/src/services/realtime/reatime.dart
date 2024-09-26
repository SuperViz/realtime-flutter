import '../../interfaces/interfaces.dart';
import '../connections/connections.dart';

class Realtime {
  final SocketClient socket;
  final ClientConnection clientConnection;

  Realtime({
    required this.socket,
    required this.clientConnection,
  });
}
