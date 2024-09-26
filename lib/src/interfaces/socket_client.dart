import 'dart:async';

abstract interface class SocketClient {
  FutureOr<SocketClient> connect();
  FutureOr<void> disconnect();
  void emit(String event, [dynamic data]);
  void onEvent(String event, dynamic Function(dynamic) handlerCallback);
}
