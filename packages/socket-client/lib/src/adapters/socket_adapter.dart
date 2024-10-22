import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../interfaces/interfaces.dart';
import '../types/types.dart';

final class IoSocketAdapter implements SocketClient {
  IoSocketAdapter._();

  static final IoSocketAdapter _singleton = IoSocketAdapter._();

  factory IoSocketAdapter() => _singleton;

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

    socket!.on(event, (data) {
      if (data is List) {
        data.removeWhere((element) => (element is! Map) && (element is! List));
        if (data.length > 1) {
          return handlerCallback(data);
        } else if (data.length == 1) {
          return handlerCallback(data.first);
        } else {
          return handlerCallback([]);
        }
      }

      return handlerCallback(data);
    });
  }

  @override
  void connect(SocketConnectParams connectParams) {
    if (socket != null) return;

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
          .build(),
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
      handlerCallback,
    );
  }
}
