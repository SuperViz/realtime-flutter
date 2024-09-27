import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../interfaces/interfaces.dart';
import '../interfaces/params/params.dart';
import '../types/types.dart';

final class IoSocketAdapter implements SocketClient {
  IoSocketAdapter();

  io.Socket? socket;

  @override
  String? get id => socket?.id;

  @override
  FutureOr<void> disconnect() async {
    if (socket == null) return;
    socket!.close();
    socket = null;
  }

  @override
  void onEvent(String event, EventHandler handlerCallback) {
    if (socket == null) return;

    socket!.on(event, (data) => handlerCallback(data));
  }

  @override
  void connect(SocketConnectParams connectParams) {
    if (socket != null) return;

    print("Connecting...");

    socket = io.io(
      'https://io.superviz.com',
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

    socket!.emit(event, data);
  }

  @override
  void offEvent(String event, [EventHandler? handlerCallback]) {
    if (socket == null) return;

    socket!.off(
      event,
      handlerCallback != null ? (data) => handlerCallback(data) : null,
    );
  }
}
