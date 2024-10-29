import 'dart:async';

import 'package:superviz_socket_client/superviz_socket_client.dart' as socket;

import '../../components/realtime/enums/enums.dart';
import '../../components/realtime/types/types.dart';
import '../../types/types.dart';
import '../../utils/utils.dart';
import '../ioc/ioc.dart';
import '../presence/presence.dart';

final class Channel extends Observable {
  final String _name;
  String get name => _name;

  final Ioc _ioc;
  final Participant _localParticipant;
  final _callbacksToSubscribeWhenJoined =
      <({String event, void Function(List) callback})>[];

  RealtimeChannelState _state = RealtimeChannelState.disconnected;

  late final socket.Room _channel;
  late final socket.Logger _logger;

  late final RealtimePresence _participant;
  RealtimePresence get participant => _participant;

  Channel({
    required String name,
    required Ioc ioc,
    required Participant localParticipant,
    int connectionLimit = 200,
  })  : _ioc = ioc,
        _name = name,
        _localParticipant = localParticipant {
    _logger = socket.DebuggerLoggerAdapter(scope: '@superviz/realtime-channel');
    _channel = _ioc.createRoom('realtime:$name', connectionLimit);
    localParticipant = localParticipant;

    _subscribeToRealtimeEvents();
    _logger.log(name: 'started');
    _participant = RealtimePresence(_channel);
  }

  Future<void> disconnect() async {
    if (_state == RealtimeChannelState.disconnected) {
      _logger.log(name: 'Realtime channel is already disconnected');
      return;
    }

    _logger.log(name: 'destroyed');
    _changeState(RealtimeChannelState.disconnected);
    observers.clear();
    _channel.disconnect();
  }

  /// Publishes an event with data to the channel.
  /// - `event` - The name of the event to publish.
  /// - `data` - Data to be sent along with the event.
  @override
  void publish(String event, [Map<String, dynamic>? data]) {
    if (_state != RealtimeChannelState.connected) {
      final message =
          'Realtime channel $_name has not started yet. You can\'t publish event $event before start';

      _logger.log(name: '[SuperViz]', description: message);

      return;
    }

    super.publish(event, data);
    _channel.emit('message:$_name', {'name': event, 'payload': data});
  }

  /// Subscribes to a specific event and registers a callback function to handle the received data.
  /// If the channel is not yet available, the subscription will be queued and executed once the channel is joined.
  /// - `event` - The name of the event to subscribe to.
  /// - `listener` - The listener function to handle the received data. It takes a parameter of type 'RealtimeMessage' or 'string'.
  @override
  void subscribe(
    String event,
    void Function(List data) listener,
  ) {
    if (_state != RealtimeChannelState.connected) {
      _callbacksToSubscribeWhenJoined.add((event: event, callback: listener));
      return;
    }

    super.subscribe(event, listener);
  }

  /// Change realtime component state and publish state to client
  /// - `state` - The state of realtime channel to change to.
  void _changeState(RealtimeChannelState state) {
    _logger.log(
      name: 'realtime component @ changeState - state changed',
      description: state.description,
    );

    _state = state;

    _publishEventToClient<RealtimeChannelState>(
      RealtimeChannelEvent.realtimeChannelStateChanged.description,
      state,
    );
  }

  void _subscribeToRealtimeEvents() {
    _channel.presence?.on(socket.PresenceEvents.joinedRoom, (event) {
      if (event.id != _localParticipant.id) return;

      _changeState(RealtimeChannelState.connected);

      for (var callbackToSubscribe in _callbacksToSubscribeWhenJoined) {
        subscribe(
          callbackToSubscribe.event,
          callbackToSubscribe.callback,
        );
      }

      _logger.log(name: 'joined room');
      // publishing again to make sure all clients know that we are connected
      _changeState(RealtimeChannelState.connected);
    });

    _channel.on('message:$_name}', (event) {
      _logger.log(name: 'message received', description: event);

      _publishEventToClient<RealtimeMessage>(event, (
        connectionId: event['connectionId'],
        data: event['data']['payload'],
        name: event['data']['name'],
        participantId: event?['presence']?['id'],
        timestamp: event['timestamp'],
      ));
    });
  }

  /// Get realtime client data history
  Future<Map<String, List<RealtimeMessage>>?> fetchHistory(
    String? eventName,
  ) async {
    if (_state != RealtimeChannelState.connected) {
      const message =
          'Realtime component has not started yet. You can\'t retrieve history before start';

      _logger.log(name: message);
      _logger.log(name: '[SuperViz]', description: message);
      return null;
    }

    final completer = Completer<Map<String, List<RealtimeMessage>>?>();

    Future.microtask(() {
      void next(socket.RoomHistory data) {
        if (data.events.isEmpty) {
          completer.complete(null);
        }

        final groupMessages =
            data.events.fold<Map<String, List<RealtimeMessage>>>(
          {},
          (group, socket.SocketEvent event) {
            if (group[event.data['name']] == null) {
              group[event.data['name']] = [];
            }

            group[event.data['name']]?.add((
              data: event.data['payload'],
              connectionId: event.connectionId,
              name: event.data['name'],
              participantId: event.presence?.id,
              timestamp: event.timestamp,
            ));

            return group;
          },
        );

        if (eventName != null && groupMessages[eventName] == null) {
          completer.completeError(
            Exception('Event $eventName not found in the history'),
          );
        }

        if (eventName != null) {
          completer.complete({eventName: groupMessages[eventName]!});
        }

        completer.complete(groupMessages);
      }

      _channel.history(next);
    });

    return completer.future;
  }

  /// Publish event to client
  /// - `event` - Event name
  /// - `data` - Data to publish
  void _publishEventToClient<T>(String event, T data) {
    _logger.log(
      name: 'realtime channel @ publishEventToClient',
      description: '$event $data',
    );

    observers[event]?.publish([data]);
  }
}
