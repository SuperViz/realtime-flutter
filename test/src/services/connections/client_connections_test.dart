import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:realtime/src/enums/enums.dart';
import 'package:realtime/src/interfaces/interfaces.dart';
import 'package:realtime/src/services/connections/connections.dart';

import 'client_connections_test.mocks.dart';

@GenerateMocks([SocketClient])
void main() {
  late final MockSocketClient mockSocketClient;
  late final ClientConnection clientConnection;

  setUpAll(() {
    mockSocketClient = MockSocketClient();
  });

  setUp(() {
    clientConnection = ClientConnection(
      socket: mockSocketClient,
    );
  });

  group('constructor method', () {
    test('Should subscribe on all event listners', () {
      verifyInOrder([
        mockSocketClient.onEvent(SocketEvents.connect.description, any),
        mockSocketClient.onEvent(SocketEvents.reconnect.description, any),
        mockSocketClient.onEvent(SocketEvents.disconnect.description, any),
        mockSocketClient.onEvent(SocketEvents.connectError.description, any),
        mockSocketClient.onEvent(SocketEvents.reconnectError.description, any),
        mockSocketClient.onEvent(SocketEvents.connectionError.description, any),
        mockSocketClient.onEvent(SocketEvents.reconnectFailed.description, any),
        mockSocketClient.onEvent(SocketEvents.reconnectAttempt.description, any),
        mockSocketClient.onEvent(SocketEvents.error.description, any),
      ]);
    });
  });
}
