import 'dart:async';

import '../../adapters/adapters.dart';
import '../../enums/enums.dart';
import '../../interfaces/interfaces.dart';
import '../../types/types.dart';
import '../room/models/models.dart';
import 'models/model.dart';

export 'models/presence_event.dart';

final class PresenceRoom {
  late Logger _logger;

  final SocketClient _socket;
  final UserPresence _user;
  final String _roomId;

  final _presences = <PresenceEvent>{};
  final _observers = <PresenceEvents, StreamController<PresenceEvent>>{};

  factory PresenceRoom.register(
    SocketClient io,
    UserPresence user,
    String roomId,
  ) {
    return PresenceRoom._(
      roomId: roomId,
      socket: io,
      user: user,
    );
  }

  PresenceRoom._({
    required SocketClient socket,
    required UserPresence user,
    required String roomId,
  })  : _socket = socket,
        _user = user,
        _roomId = roomId {
    _logger = DebuggerLoggerAdapter(scope: '@superviz/socket-client/presence');

    _registerSubjects();
    _subscribeToPresenceEvents();
  }

  /// Get the presences in the room
  void get(void Function(List<PresenceEvent> data) next) {
    final subject = StreamController<List<PresenceEvent>>();

    subject.stream.listen(next);

    void callback(dynamic event) {
      final presences = event['presences']
          .map<PresenceEvent>((presence) => PresenceEvent.fromMap(presence))
          .toList();

      _logger.log(
        name: 'presence room @ get',
        description: presences.join(', '),
      );

      _socket.offEvent(InternalPresenceEvents.get.description, callback);
      subject.add(presences);
      subject.close();
    }

    _socket.onEvent(InternalPresenceEvents.get.description, callback);
    _socket.emit(InternalPresenceEvents.get.description, _roomId);
  }

  /// Update the presence data in the room
  /// - `payload` - The data to update
  void update<T extends Map>(T payload) {
    final body = PresenceEvent(
      connectionId: _socket.id,
      data: payload,
      id: _user.id,
      name: _user.name ?? 'Unknow',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _socket.emit(PresenceEvents.update.description, [_roomId, body]);
    _logger.log(
      name: 'presence room @ update',
      description: '$_roomId, ${body.toString()}',
    );
  }

  void destroy() {
    _socket.offEvent(PresenceEvents.leave.description, _onPresenceLeave);
    _socket.offEvent(PresenceEvents.update.description, _onPresenceUpdate);
    _socket.offEvent(PresenceEvents.joinedRoom.description, _onPresenceJoin);

    _observers.forEach((_, observer) => observer.close());
    _observers.clear();
  }

  /// Register the subjects for the presence events
  void _registerSubjects() {
    _observers[PresenceEvents.joinedRoom] = StreamController<PresenceEvent>();
    _observers[PresenceEvents.leave] = StreamController<PresenceEvent>();
    _observers[PresenceEvents.update] = StreamController<PresenceEvent>();
  }

  /// Listen to an event
  /// - `event` - The event to listen to
  /// - `callback` - The callback to execute when the event is emitted
  /// - `error` - The callback to execute when the event emits an error
  void on(
    PresenceEvents event,
    EventCallback<PresenceEvent> callback,
  ) {
    _observers[event]?.stream.listen(callback);
  }

  /// Stop listening to an event
  /// - `event` - The event to stop listening to
  /// - `callback` - The callback to remove from the event
  void off(PresenceEvents event) {
    _observers[event]?.close();
    _observers.remove(event);
    _observers[event] = StreamController<PresenceEvent>();
  }

  /// Subscribe to the presence events
  void _subscribeToPresenceEvents() {
    _socket.onEvent(PresenceEvents.joinedRoom.description, _onPresenceJoin);
    _socket.onEvent(PresenceEvents.update.description, _onPresenceUpdate);
    _socket.onEvent(PresenceEvents.leave.description, _onPresenceLeave);
  }

  /// Handle the presence join event
  /// - `event` - The presence event
  void _onPresenceJoin(dynamic data) {
    final event = PresenceEventFromServer.fromMap(data);

    if (event.roomId != _roomId) return;

    _logger.log(name: 'presence room @ presence join', description: event.name);

    _presences.add(event);

    _observers[PresenceEvents.joinedRoom]?.add(
      PresenceEvent(
        connectionId: event.connectionId,
        data: event.data,
        id: event.id,
        name: event.name,
        timestamp: event.timestamp,
      ),
    );
  }

  /// Handle the presence leave event
  ///- ` event` - The presence event
  void _onPresenceLeave(dynamic data) {
    PresenceEventFromServer event = PresenceEventFromServer.fromMap(data);

    if (event.roomId != _roomId) return;

    _logger.log(
      name: 'presence room @ presence leave',
      description: event.name,
    );
    _presences.remove(event);
    _observers[PresenceEvents.leave]!.add(event);
  }

  /// Handle the presence update event
  /// - `event` - The presence event
  void _onPresenceUpdate(dynamic data) {
    final event = PresenceEventFromServer.fromMap(data);

    if (event.roomId != _roomId) return;

    _logger.log(
      name: 'presence room @ presence update',
      description: event.data.toString(),
    );

    _observers[PresenceEvents.update]!.add(
      PresenceEvent(
        connectionId: event.connectionId,
        data: event.data,
        id: event.id,
        name: event.name,
        // roomId: event.roomId,
        timestamp: event.timestamp,
      ),
    );
  }
}
