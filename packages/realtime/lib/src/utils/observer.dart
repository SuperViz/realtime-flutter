import 'dart:async';

import 'package:superviz_socket_client/superviz_socket_client.dart' as socket;

class Observer {
  late final socket.Logger _logger;
  late List<dynamic Function(List)> _callbacks;

  Observer() {
    _logger = socket.DebuggerLoggerAdapter(scope: '@superviz/observer-helper');
    _callbacks = [];
  }

  /// Subscribe to observer
  /// - `callback` - Callback to subscribe
  void subscribe(dynamic Function(List) callback) {
    _callbacks.add(callback);
  }

  /// Unsubscribe from observer
  /// - `callbackToRemove` - Callback to remove
  void unsubscribe(dynamic Function(dynamic) callbackToRemove) {
    _callbacks = _callbacks
        .where(
          (callback) => callback != callbackToRemove,
        )
        .toList();
  }

  /// Publish event to all subscribers
  /// - `events` - List on events to publish
  void publish(List events) {
    if (_callbacks.isEmpty) return;

    for (var callback in _callbacks) {
      _callListener(callback, events).onError((error, _) {
        _logger.log(
          name: 'superviz-sdk:observer-helper:publish:error',
          description: '''
            Failed to execute callback on publish value.
            Error: $error
          ''',
        );
      });
    }
  }

  /// Reset observer
  void reset() {
    _callbacks = [];
  }

  /// Destroy observer
  void destroy() {
    reset();
  }

  /// Call listener with params
  /// - `listener` Function to execute and return result when the task is completed.
  /// - `params` Params to parse to listener.
  Future<dynamic> _callListener(dynamic Function(List) listener, List params) {
    final completer = Completer();

    Future.microtask(() {
      try {
        final result = listener(params);
        completer.complete(result);
      } catch (error) {
        completer.completeError(error);
      }
    });

    return completer.future;
  }
}
