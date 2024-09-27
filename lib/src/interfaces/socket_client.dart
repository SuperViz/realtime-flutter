import 'dart:async';

import '../types/types.dart';
import 'params/params.dart';

abstract interface class SocketClient {

  /// Connect on socket server with recived socket connect params
  /// - `connectionParams` - Parameters required to connect to the server socket
  void connect(SocketConnectParams connectionParams);

  FutureOr<void> disconnect();
  void emit(String event, [dynamic data]);
  void onEvent<T>(String event, EventHandler<T> handlerCallback);
}
