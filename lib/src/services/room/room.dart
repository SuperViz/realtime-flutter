import 'dart:async';

import '../../enums/enums.dart';
import '../../interfaces/interfaces.dart';
import '../../types/types.dart';
import '../../utils/utils.dart';
import '../presence/presence.dart';
import 'models/models.dart';

final class Room {
  final SocketClient _socket;
  final UserPresence _user;
  final String _roomName;
  final String _apiKey;

  late Logger _logger;

  bool _isJoined = false;

  final Map<Function, StreamSubscription> _subscriptions = {};
  final Map<String, StreamController> _observers = {};

  PresenceRoom? _presence;

  PresenceRoom? get presence => _presence;

  Room._({
    required SocketClient io,
    required UserPresence user,
    required String roomName,
    required String apiKey,
    required int maxConnections,
  }) : _socket = io,
      _user = user,
      _roomName = roomName,
      _apiKey = apiKey {
    final payload = {
      'name': roomName,
      'user': user.toMap(),
      'maxConnections': maxConnections,
    };

    _logger = DebuggerLoggerAdapter(scope: '@superviz/socket-client/room');

    _presence = PresenceRoom.register(io, user, roomName);

    io.emit(RoomEvent.joinRoom.description, payload);
    _subscribeToRoomEvents();
  }

  factory Room.register({
    required SocketClient io,
    required UserPresence user,
    required String roomName,
    required String apiKey,
    int? maxConnections,
  }) {
    return Room._(
      io: io,
      user: user,
      roomName: roomName,
      apiKey: apiKey,
      maxConnections: maxConnections ?? 250,
    );
  }

  /// Listen to an event
  /// - `event` - The event to listen to
  /// - `callback` - The callback to execute when the event is emitted
  void on(String event, EventCallback callback) {
    _logger.log(name: 'room @ on', description: event);

    var subject = _observers[event];

    if (subject == null) {
      subject = StreamController();
      _observers[event] = subject;

      _socket.onEvent(event, (data) {
        _publishEventToClient(event, data);
      });
    }

    _subscriptions[callback] = subject.stream.listen((data) => callback(data));
  }

  /// Stop listening to an event
  /// - `event` - The event to stop listening to
  /// - `callback` - The callback to remove from the event
  void off(String event, EventCallback? callback) {
    _logger.log(name: 'room @ off', description: event);

    if (callback != null) {
      _observers.remove(event);
      _socket.offEvent(event);
      return;
    }

    _subscriptions[callback]?.cancel();
  }

  /// Emit an event
  /// - `event` - The event to emit
  /// - `payload` - The payload to send with the event
  void emit(String event, Map<String, dynamic> payload) {
    if (!_isJoined) {
      _logger.log(name: 'Cannot emit event', description: 'Not joined to room');
      return;
    }

    final body = {
      'name': event,
      'roomId': _roomName,
      'presence': _user.toMap(),
      'connectionId': _socket.id,
      'data': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socket.emit(RoomEvent.update.description, [_roomName, body]);
    _logger.log(name: 'room @ emit', description: '$event $body');
  }

  /// Get the presences in the room
  void history(EventCallback next, ErrorCallback? error) {
    final subject = StreamController<RoomHistory>();

    subject.stream.listen(
      next,
      onError: error,
    );

    void callback(dynamic event) {
      final roomHistory = RoomHistory.fromMap(event[0]);

      _logger.log(name: 'room @ history', description: roomHistory.toString());
      _socket.offEvent(InternalRoomEvents.get.description, callback);
      subject.add(roomHistory);
      subject.close();
    }

    _socket.onEvent(InternalRoomEvents.get.description, callback);
    _socket.emit(InternalRoomEvents.get.description, _roomName);
  }

  /// Disconnect from the room
  void disconnect() {
    _logger.log(name: 'room @ disconnect', description: 'Leaving room: $_roomName');
    _socket.emit(RoomEvent.leaveRoom.description, _roomName);

    // unsubscribe from all events
    _subscriptions.forEach((_, subscription) => subscription.cancel());
    _subscriptions.clear();
    _observers.forEach((_, subject) => subject.close());
    _observers.clear();

    _presence?.destroy();
  }

  /// Publish an event to the client
  /// - `event` - The event to publish
  /// - `data` - The data to publish
  void _publishEventToClient(String event, dynamic data) {
    final subject = _observers[event];

    if (subject == null || data['roomId'] != _roomName) return;

    subject.add(data);
  }

   /// Subscribe to room events
  void _subscribeToRoomEvents() {
    _socket.onEvent(RoomEvent.joinedRoom.description, _onJoinedRoom);
    _socket.onEvent('http:$_roomName:$_apiKey', _onHttpEvent);
    _socket.onEvent(RoomEvent.error.description, (data) {
      _logger.log(name: 'Room Error', description: data?['name']);
    });
  }

  /// handles the event when a user joins a room.
  /// - `event` The socket event containing presence data.
  void _onJoinedRoom(dynamic event) {
    if (_roomName != event?[0]?['data']?['name']) return;

    _isJoined = true;
    _socket.emit(RoomEvent.joinedRoom.description, [_roomName, event[0]['data']]);
    _logger.log(name: 'room @ joined', description: event?[0]?['data']?['name']);
  }

  void _onHttpEvent (dynamic event) {
    _publishEventToClient(event['name'], event);
  }
}
