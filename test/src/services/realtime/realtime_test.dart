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
}
