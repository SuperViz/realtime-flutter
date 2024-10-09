import 'package:faker/faker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:realtime/realtime.dart';
import 'package:realtime/src/interfaces/interfaces.dart';
import 'package:realtime/src/interfaces/params/params.dart';
import 'package:realtime/src/services/room/models/models.dart';

import 'realtime_test.mocks.dart';

@GenerateMocks([SocketClient])
void main() {
  late final String apiKey;
  late final String environment;
  late final UserPresence presence;
  late final String secret;
  late final String clientId;

  late final MockSocketClient mockSocketClient;

  late Realtime realtime;

  setUpAll(() {
    apiKey = faker.guid.guid();
    environment = 'dev';
    presence = UserPresence(id: faker.guid.guid(), name: faker.person.name());
    secret = faker.guid.guid();
    clientId = faker.guid.guid();

    mockSocketClient = MockSocketClient();

    realtime = Realtime(
      socket: mockSocketClient,
      apiKey: apiKey,
      environment: environment,
      presence: presence,
      secret: secret,
      clientId: clientId,
    );
  });

  group('constructor method', () {
    test('Should connect on socket with correct parameters', () {
      when(
        mockSocketClient.connect(any),
      ).thenAnswer((_) {});

      final capturedArgs = verify(
        mockSocketClient.connect(captureAny),
      ).captured;

      expect(
        capturedArgs.last,
        isA<SocketConnectParams>().having(
          (params) => params.apiKey,
          'Socket connect parameter apiKey',
          equals(apiKey),
        ).having(
          (params) => params.clientId,
          'Socket connect parameter clientId',
          equals(clientId),
        ).having(
          (params) => params.environment,
          'Socket connect parameter environment',
          equals(environment),
        ).having(
          (params) => params.secretKey,
          'Socket connect parameter secretKey',
          equals(secret),
        ),
      );
    });

    test('Should create client connection', () {
      expect(realtime.clientConnection, isNotNull);
      expect(realtime.clientConnection.state, equals(realtime.state));
    });
  });

  group('destroy method', () {
    setUpAll(() {
      when(
        mockSocketClient.disconnect(),
      ).thenAnswer((_) {});
    });

    test('Should disconnect from socket', () {
      realtime.destroy();

      verify(
        mockSocketClient.disconnect(),
      ).called(1);
    });
  });
}
