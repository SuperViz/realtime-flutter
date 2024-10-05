import 'package:faker/faker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:realtime/src/enums/enums.dart';
import 'package:realtime/src/interfaces/interfaces.dart';
import 'package:realtime/src/services/presence/presence.dart';
import 'package:realtime/src/services/room/models/models.dart';

import 'presence_test.mocks.dart';

@GenerateMocks([SocketClient])
void main() {
  late MockSocketClient mockSocketClient;
  late String roomId;
  late UserPresence user;

  late PresenceRoom presence;

  setUpAll(() {
    mockSocketClient = MockSocketClient();
    roomId = faker.conference.name();
    user = UserPresence(
      id: faker.guid.guid(),
      name: faker.person.name(),
    );
  });

  setUp(() {
    presence = PresenceRoom.register(
      mockSocketClient,
      user,
      roomId,
    );
  });

  group('get method', () {
    late final String event;

    setUpAll(() {
      event = InternalPresenceEvents.get.description;
    });

    test('Should socket register and emit presence.get', () {
      presence.get((data) {});

      verifyInOrder([
        mockSocketClient.onEvent(event, any),
        mockSocketClient.emit(event, roomId)
      ]);
    });

    test('Should unregister socket listen to presence.get', () {
      presence.get((data) {});

      final capturedArgs = verify(
        mockSocketClient.onEvent(
          event,
          captureThat(isA<void Function(dynamic)>()),
        ),
      ).captured;

      final callback = capturedArgs[0];

      callback({ 'presences': [] });

      verify(
        mockSocketClient.offEvent(
          event,
          callback,
        ),
      ).called(1);
    });
  });

  group('update method', () {
    test('Should call socket emit presence.update', () {
      presence.update({});

      verify(
        mockSocketClient.emit(
          PresenceEvents.update.description,
          any,
        ),
      ).called(1);
    });
  });
}
