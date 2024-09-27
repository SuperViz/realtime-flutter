import 'dart:async';

import '../types/types.dart';
import 'params/params.dart';

abstract interface class SocketClient {
  String? get id;

  /// Connect on socket server with recived socket connect params
  /// - `connectionParams` - Parameters required to connect to the server socket
  void connect(SocketConnectParams connectionParams);

  /// Disconnect from server socket
  FutureOr<void> disconnect();

  /// Emit a new data on event
  /// - `event` - The event that will recive data
  /// - `data` (optional) - Data that will be recived by event listeners
  void emit(String event, [dynamic data]);
  void onEvent(String event, EventHandler handlerCallback);

  /// Stop listening to an event
  /// - `event` - The event to stop listening to
  void offEvent(String event, [EventHandler handlerCallback]);
}
