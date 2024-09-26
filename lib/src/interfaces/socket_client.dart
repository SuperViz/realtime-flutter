import 'dart:async';

import 'params/params.dart';

abstract interface class SocketClient {
  FutureOr<SocketClient> connect(SocketConnectParams connectionParams);
  FutureOr<void> disconnect();
  void emit(String event, [dynamic data]);
  void onEvent(String event, dynamic Function(dynamic) handlerCallback);
}
