import '../../interfaces/socket_client.dart';
import 'models/models.dart';

final class PresenceRoom {
  const PresenceRoom();

  factory PresenceRoom.register(
    SocketClient io,
    UserPresence user,
    String roomId,
  ) {
    return PresenceRoom();
  }

  void destroy() {}
}
