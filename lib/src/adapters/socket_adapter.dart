import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../interfaces/interfaces.dart';

final class IoSocketAdapter implements SocketClient {
  IoSocketAdapter();

  IO.Socket? socket;

  @override
  FutureOr<void> disconnect() async {
    if (socket == null) return;

    print('disconnecting...');

    socket!.close();

    print('Desconected');
  }

  @override
  void onEvent(String event, dynamic Function(dynamic) callback) {
    if (socket == null) return;

    socket!.on(event, callback);
  }
  
  @override
  FutureOr<IoSocketAdapter> connect() async {
    if (socket != null) return IoSocketAdapter();

    print("Connecting...");

    socket = IO.io(
      'https://io.superviz.com',
      IO.OptionBuilder()
        .enableReconnection()
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .setReconnectionAttempts(5)
        .setExtraHeaders({
          'sv-api-key': 'neydzn8hlkhn2bymaq3rcabaxa5v3z',
        })
        .setAuth({
          'apiKey': 'neydzn8hlkhn2bymaq3rcabaxa5v3z',
          'envirioment': 'dev',
          'secret': 'sk_7y7aq70twj7nd2vy7ss4mbxomhb9w1',
          'clientId': '499a215e-c957-46b3-a81c-f0a8de19defa',
        })
        .build()
    );

    socket!.onConnect((ev) {
      print("Connected");
      print(ev);
    });

    return IoSocketAdapter();
  }
  
  @override
  void emit(String event, [dynamic data]) {
    if (socket == null) return;

    socket!.emit(event);
  }
}
