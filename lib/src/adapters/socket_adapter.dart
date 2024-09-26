import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../interfaces/interfaces.dart';
import '../interfaces/params/params.dart';

final class IoSocketAdapter implements SocketClient {
  IoSocketAdapter();

  io.Socket? socket;

  @override
  FutureOr<void> disconnect() async {
    if (socket == null) return;
    socket!.close();
  }

  @override
  void onEvent(String event, dynamic Function(dynamic) callback) {
    if (socket == null) return;

    socket!.on(event, callback);
  }
  
  @override
  FutureOr<IoSocketAdapter> connect(SocketConnectParams connectParams) async {
    if (socket != null) return IoSocketAdapter();

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

    return IoSocketAdapter();
  }
  
  @override
  void emit(String event, [dynamic data]) {
    if (socket == null) return;

    socket!.emit(event);
  }
}
