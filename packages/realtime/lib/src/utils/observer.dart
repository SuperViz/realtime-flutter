import 'dart:async';

import 'package:superviz_socket_client/superviz_socket_client.dart' as socket;

class Observer {
  late final socket.Logger _logger;
  late List<Function> _callbacks;

  Observer() {
    _logger = socket.DebuggerLoggerAdapter(scope: '@superviz/observer-helper');
    _callbacks = [];
  }

  /// Subscribe to observer
  /// - `callback` - Callback to subscribe
  void subscribe(Function callback) {
    _callbacks.add(callback);
  }

  /// Unsubscribe from observer
  /// - `callbackToRemove` - Callback to remove
  void unsubscribe(Function callbackToRemove) {
    _callbacks =
        _callbacks.where((callback) => callback != callbackToRemove).toList();
  }

  /// Publish event to all subscribers
  /// - `event` - Event to publish
  void publish(dynamic event) {
    if (_callbacks.isEmpty) return;

    for (var callback in _callbacks) {
      _callListener(callback, event).onError((error, stacktrace) {
        _logger.log(
          name: 'superviz-sdk:observer-helper:publish:error',
          description: '''
            Failed to execute callback on publish value.
            Error: $error $stacktrace
          ''',
        );
        return;
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
  Future<void> _callListener(
    Function listener,
    dynamic params,
  ) {
    final completer = Completer();

    Future.microtask(() {
      try {
        final result = listener(params);
        return completer.complete(result);
      } catch (error) {
        return completer.completeError(error);
      }
    });

    return completer.future;
  }
}
