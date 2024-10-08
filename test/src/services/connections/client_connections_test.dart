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

  late ClientConnection clientConnection;

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

    test('Should change client state to connected on connected', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.connect.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.first(null);

      expect(clientConnection.state, equals(ClientState.connected));
    });

    test('Should change client state to connected on reconnect', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.reconnect.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.first(null);

      expect(clientConnection.state, equals(ClientState.connected));
    });

    test('Should change client state to disconnected on disconnect', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.disconnect.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.first(null);

      expect(clientConnection.state, equals(ClientState.disconnected));
    });

    test(
      'Should call socket disconnect when recive a socket-event.error with disconect parameter',
      () {
        final capturedArgs = verify(
          mockSocketClient.onEvent(
            SocketEvents.error.description,
            captureThat(isA<Function>()),
          ),
        ).captured;

        when(
          mockSocketClient.disconnect(),
        ).thenAnswer((_) {});

        capturedArgs.first({
          'errorType': 'error type',
          'message': 'Message',
          'connectionId': '',
          'needsToDisconnect': true, // needsToDisconnect parsed as true
          'level': SocketExceptionErrorLevel.error.name,
        });

        verify(
          mockSocketClient.disconnect(),
        ).called(1);

        expect(clientConnection.state, equals(ClientState.disconnected));
      },
    );
  });
}
