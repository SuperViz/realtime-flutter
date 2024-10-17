import 'dart:async';

import 'package:socket_client/socket_client.dart' as socket;

import '../../types/types.dart';
import '../config/config.dart';
import 'enums/enums.dart';

final class Ioc {
  late socket.ConnectionState state;
  late socket.Realtime client;

  final stateSubject = StreamController<dynamic>();

  late final Participant _participant;

  final _config = ConfigurationService();

  Ioc(Participant participant) : _participant = participant {
    createClient();
  }

  /// Destroys the socket connection
  void destroy() {
    stateSubject.close();
    client.destroy();
  }

  /// Subscribe to the default socket events
  void subscribeToDefaultEvents() {
    client.clientConnection.on(next: _handleConnectionState);
  }

  void _handleConnectionState(socket.ConnectionState state) {
    if (state.reason == 'Unauthorized connection') {
      print(
        '[Superviz] Unauthorized connection. Please check your API key and if your domain is white listed.',
      );

      this.state = socket.ConnectionState(
        state: socket.ClientState.disconnected,
        reason: state.reason,
      );

      stateSubject.add(IocState.authError);

      return;
    }

    if (state.reason == 'user-already-in-room') {
      this.state = state;
      stateSubject.add(IocState.sameAccountError);
      return;
    }

    this.state = state;

    if (stateSubject.isClosed) return;

    stateSubject.add(state.state);
  }

  /// create a new socket client
  void createClient() {
    final environment = _config.get<String>(ConfigurationKeys.environment);

    client = socket.Realtime(
      socket: socket.IoSocketAdapter(),
      apiKey: _config.get<String>(ConfigurationKeys.apiKey)!,
      environment: environment!,
      presence: socket.UserPresence(
        id: _participant.id,
        name: _participant.name,
      ),
      secret: _config.get<String>(ConfigurationKeys.secret)!,
      clientId: _config.get<String>(ConfigurationKeys.clientId)!,
    );

    subscribeToDefaultEvents();
  }

  /// create and join realtime room
  /// - `roomName` - name of the room that will be created
  /// - `connectionLimit` - connection limit for the room, the default is 200 because it's the maximum number of slots
  socket.Room createRoom(String roomName, [int connectionLimit = 200]) {
    return client.connect('realtime-component:$roomName', connectionLimit);
  }
}
