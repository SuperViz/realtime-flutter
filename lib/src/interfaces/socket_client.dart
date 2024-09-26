import 'dart:async';

import '../types/types.dart';
import 'params/params.dart';

abstract interface class SocketClient {
  FutureOr<SocketClient> connect(SocketConnectParams connectionParams);
  FutureOr<void> disconnect();
  void emit(String event, [dynamic data]);
  void onEvent<T>(String event, EventHandler<T> handlerCallback);
}
