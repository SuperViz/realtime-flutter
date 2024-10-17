import 'dart:async';

import 'package:socket_client/socket_client.dart' as socket;

final class RealtimePresence {
  late final socket.Logger _logger;

  final socket.Room _room;

  RealtimePresence(socket.Room room) : _room = room {
    _logger = socket.DebuggerLoggerAdapter(scope: '@superviz/realtime-presence');
  }

  void update<T extends Map>(T data) {
    _logger.log(
      name: 'Realtime Presence @ update presence',
      description: data.toString(),
    );

    _room.presence?.update(data);
  }

  void subscribe(
    socket.PresenceEvents event,
    void Function(socket.PresenceEvent event) callback,
  ) {
    _logger.log(
      name: 'Realtime Presence @ subscribe',
      description: event.description,
    );

    _room.presence?.on(event, callback);
  }

  void unsubscribe(socket.PresenceEvents event) {
    _logger.log(
      name: 'Realtime Presence @ unsubscribe',
      description: event.description,
    );

    _room.presence?.off(event);
  }

  Future<List<socket.PresenceEvent>> getAll() async {
    _logger.log(
      name: 'Realtime Presence @ get all',
      description: '',
    );

    final completer = Completer<List<socket.PresenceEvent>>();

    _room.presence!.get(
      (data) => completer.complete(data),
    );

    return completer.future;
  }
}
