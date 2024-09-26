import 'dart:async';

import '../enums/enums.dart';

abstract interface class SocketClient {
  FutureOr<void> disconnect();
  void onEvent(SocketEvent event, Function callback);
}
