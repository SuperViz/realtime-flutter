import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:socket_client/src/enums/enums.dart';
import 'package:socket_client/src/interfaces/interfaces.dart';
import 'package:socket_client/src/services/connections/connections.dart';

import 'client_connections_test.mocks.dart';

@GenerateMocks([SocketClient])
void main() {
  late final MockSocketClient mockSocketClient;
  late final Map<String, dynamic> mockSocketExceptionMap;

  late ClientConnection clientConnection;

  setUpAll(() {
    mockSocketClient = MockSocketClient();

    mockSocketExceptionMap = {
      'errorType': 'error type',
      'message': 'Message',
      'connectionId': '',
      'needsToDisconnect': true, // needsToDisconnect parsed as true
      'level': SocketExceptionErrorLevel.error.name,
    };
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
        mockSocketClient.onEvent(
            SocketEvents.reconnectAttempt.description, any),
        mockSocketClient.onEvent(SocketEvents.error.description, any),
      ]);
    });

    test('Should change client state to CONNECTED on connect', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.connect.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last(null);

      expect(clientConnection.state, equals(ClientState.connected));
    });

    test('Should change client state to CONNECTED on reconnect', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.reconnect.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last(null);

      expect(clientConnection.state, equals(ClientState.connected));
    });

    test('Should change client state to DISCONNECTED on disconnect', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.disconnect.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last(null);

      expect(clientConnection.state, equals(ClientState.disconnected));
    });

    test('Should change client state to CONNECTION_ERROR on connect error', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.connectError.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last(mockSocketExceptionMap);

      expect(clientConnection.state, equals(ClientState.connectionError));
    });

    test('Should change client state to RECONNECT_ERROR on reconect error', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.reconnectError.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last(mockSocketExceptionMap);

      expect(clientConnection.state, equals(ClientState.reconnectError));
    });

    test('Should change client state to CONNECTION_ERROR on connection error',
        () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.connectionError.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last(mockSocketExceptionMap);

      expect(clientConnection.state, equals(ClientState.connectionError));
    });

    test('Should change client state to RECONNECT_ERROR on reconnection failed',
        () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.reconnectFailed.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last(mockSocketExceptionMap);

      expect(clientConnection.state, equals(ClientState.reconnectError));
    });

    test('Should change client state to RECONNECTING on reconnect attempt', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          SocketEvents.reconnectAttempt.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last({'attempt': 1});

      expect(clientConnection.state, equals(ClientState.reconnecting));
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

        capturedArgs.first(mockSocketExceptionMap);

        verify(
          mockSocketClient.disconnect(),
        ).called(1);

        expect(clientConnection.state, equals(ClientState.disconnected));
      },
    );
  });
}
