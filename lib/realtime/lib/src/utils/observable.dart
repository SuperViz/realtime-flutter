import 'package:socket_client/socket_client.dart' as socket;

import 'observer.dart';

abstract class Observable {
  final _logger = socket.DebuggerLoggerAdapter(
    scope: '@superviz/realtime',
  );

  final _observers = <String, Observer>{};
  Map<String, Observer> get observers => _observers;

  /// Subscribe to an event
  /// - `type` - event type
  /// - `listener` - event callback
  void subscribe(
    String type,
    void Function(List data) listener,
  ) {
    _logger.log(name: '[SuperViz] - Subscribed to event', description: type);

    if (_observers[type] == null) {
      _observers[type] = Observer();
    }

    _observers[type]!.subscribe(listener);
  }

  /// Unsubscribes from a specific event.
  /// - `event` - The event to unsubscribe from.
  /// - `callback` - A callback function to be called when the event is unsubscribed.
  void unsubscribe({
    required String event,
    required void Function(dynamic data) callback,
  }) {
    if (observers[event] == null) {
      _logger.log(name: "$event isn't subscribed");
      return;
    }

    _logger.log(name: 'unsubscribed from $event event');

    _observers[event]!.unsubscribe(callback);
    _observers[event]!.destroy();
  }

  /// Publish an event to client
  /// - `type` - Event type.
  /// - `data` - Event data.
  void publish(String type, [Map<String, dynamic>? data]) {
    final hasListenerRegistered = _observers.keys.any((key) => key == type);

    if (!hasListenerRegistered) return;

    _observers[type]!.publish(
      data != null
        ? [data]
        : []
    );
  }
}
