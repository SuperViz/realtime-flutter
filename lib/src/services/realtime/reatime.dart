import '../../enums/enums.dart';
import '../../interfaces/interfaces.dart';
import '../connections/connections.dart';

class Realtime {
  final SocketClient socket;
  final ClientConnection clientConnection;

  Realtime({
    required this.socket,
    required this.clientConnection,
  });

  ClientState get state => clientConnection.state;

  void destroy() {
    socket.disconnect();
    clientConnection.off();
  }
}
