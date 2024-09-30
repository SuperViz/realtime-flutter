import 'dart:async';

import '../../enums/enums.dart';
import '../../interfaces/interfaces.dart';
import '../../types/types.dart';
import '../../utils/utils.dart';
import '../room/models/models.dart';
import 'models/model.dart';

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
  }) : _socket = socket,
    _user = user,
    _roomId = roomId {
    _logger = DebuggerLoggerAdapter(scope: '@superviz/socket-client/presence');

    _registerSubjects();
    _subscribeToPresenceEvents();
  }

  /// Get the presences in the room
  void get(void Function(List<PresenceEvent> data) next, ErrorCallback? error) {
    final subject = StreamController<List<PresenceEvent>>();

    subject.stream.listen(
      next,
      onError: error,
    );

    void callback(event) {
      final presences = event['presences'].map((presence) => {
        'connectionId': presence['connectionId'],
        'data': presence['data'],
        'id': presence['id'],
        'name': presence['name'],
        'timestamp': presence['timestamp'],
      }).toList();

      _logger.log(name: 'presence room @ get', description: event.toString());
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
      connectionId: _socket.id ?? 'Socket Without connection.',
      data: payload,
      id: _user.id,
      name: _user.name ?? 'Unknow',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _socket.emit(PresenceEvents.update.description, [_roomId, body]);
    _logger.log(name: 'presence room @ update', description: '$_roomId, ${body.toString()}');
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
  void on(
     PresenceEvents event,
     EventCallback callback,
     ErrorCallback? error,
  ) {
    _observers[event]?.stream.listen(
      callback,
      onError: error,
    );
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
    PresenceEventFromServer event = PresenceEventFromServer.fromMap(data[0]);

    if (event.roomId != _roomId) return;

    _logger.log(name: 'presence room @ presence join', description: event.connectionId);

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

    _logger.log(name: 'presence room @ presence leave', description: event.name);
    _presences.remove(event);
    _observers[PresenceEvents.leave]!.add(event);
  }

  
  /// Handle the presence update event
  /// - `event` - The presence event
  void _onPresenceUpdate(dynamic data) {
    PresenceEventFromServer event = PresenceEventFromServer.fromMap(data);
    if (event.roomId != _roomId) return;

    _logger.log(name: 'presence room @ presence update', description: event.name);
    _observers[PresenceEvents.update]!.add(
      PresenceEvent(
        connectionId: event.connectionId,
        data: event.data,
        id: event.id,
        name: event.name,
        // roomId: event.roomId,
        timestamp: event.timestamp,
      )
    );
  }
}