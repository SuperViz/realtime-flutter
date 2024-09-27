import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../interfaces/interfaces.dart';
import '../interfaces/params/params.dart';
import '../types/types.dart';

final class IoSocketAdapter implements SocketClient {
  IoSocketAdapter();

  io.Socket? socket;

  @override
  FutureOr<void> disconnect() async {
    if (socket == null) return;
    socket!.close();
  }

  @override
  void onEvent<T>(String event, EventHandler<T> handlerCallback) {
    if (socket == null) return;

    socket!.on(event, (data) => handlerCallback(data));
  }

  @override
  void connect(SocketConnectParams connectParams) {
    if (socket != null) return;

    print("Connecting...");

    socket = io.io(
      'https://io.superviz.com/${connectParams.environment}',
      io.OptionBuilder()
        .setTransports(['websocket'])
        .enableReconnection()
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .setReconnectionAttempts(5)
        .setExtraHeaders({
          'sv-api-key': connectParams.apiKey,
        })
        .setAuth({
          'apiKey': connectParams.apiKey,
          'envirioment': connectParams.environment,
          'secret': connectParams.secretKey,
          'clientId': connectParams.clientId,
        })
        .build()
    );
  }

  @override
  void emit(String event, [dynamic data]) {
    if (socket == null) return;

    socket!.emit(event);
  }
}
