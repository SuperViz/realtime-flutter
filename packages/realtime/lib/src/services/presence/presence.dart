import 'package:superviz_socket_client/superviz_socket_client.dart' as socket;

import 'types/types.dart';

final class RealtimePresence {
  late final socket.Logger _logger;

  final socket.Room _room;

  RealtimePresence(socket.Room room) : _room = room {
    _logger = socket.DebuggerLoggerAdapter(
      scope: '@superviz/realtime-presence',
    );
  }

  void update<T extends Map>(T data) {
    _logger.log(
      name: 'Realtime Presence @ update presence',
      description: data.toString(),
    );

    _room.presence?.update(data);
  }

  void subscribe(
    String event,
    PresenceCallback callback,
  ) {
    _logger.log(
      name: 'Realtime Presence @ subscribe',
      description: event,
    );

    _room.presence?.on(event, callback);
  }

  void unsubscribe(String event) {
    _logger.log(
      name: 'Realtime Presence @ unsubscribe',
      description: event,
    );

    _room.presence?.off(event);
  }

  Set<socket.PresenceEvent> getAll() {
    _logger.log(
      name: 'Realtime Presence @ get all',
      description: '',
    );

    final presences = <socket.PresenceEvent>{};

    _room.presence!.get(
      (data) => presences.addAll(data),
    );

    return presences;
  }
}
