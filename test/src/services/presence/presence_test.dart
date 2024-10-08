import 'package:faker/faker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:realtime/src/enums/enums.dart';
import 'package:realtime/src/interfaces/interfaces.dart';
import 'package:realtime/src/services/presence/models/model.dart';
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

    when(
      mockSocketClient.id
    ).thenReturn(
      faker.guid.guid(),
    );
  });

  setUp(() {
    presence = PresenceRoom.register(
      mockSocketClient,
      user,
      roomId,
    );
  });

  group('constructor method', () {
    test('Should subscribe socket on correct events', () {
      verifyInOrder([
        mockSocketClient.onEvent(PresenceEvents.joinedRoom.description, any),
        mockSocketClient.onEvent(PresenceEvents.update.description, any),
        mockSocketClient.onEvent(PresenceEvents.leave.description, any),
      ]);
    });

    test('Should convert presence join data to correct object', () {
      final capturedArgs = verify(
        mockSocketClient.onEvent(
          PresenceEvents.joinedRoom.description,
          captureThat(isA<Function>()),
        ),
      ).captured;

      capturedArgs.last({
        'id': user.id,
        'name': user.name,
        'connectionId': roomId,
        'data': {},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'roomKey': roomId,
        'roomId': roomId,
      });
    });
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

      callback({
        'presences': [{
          'id': user.id,
          'name': user.name,
          'connectionId': roomId,
          'data': {},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }],
      });

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

    test('Should call socket emit with correct values', () {
      final payload = { 'teste': 'unitario' };

      presence.update(payload);

      final capturedArgs = verify(
        mockSocketClient.emit(
          PresenceEvents.update.description,
          captureThat(isA<List>()),
        ),
      ).captured;

      final firstArgument = capturedArgs[0][0];

      expect(
        firstArgument,
        isA<String>().having(
          (value) => value,
          'correct room id',
          equals(roomId),
        ),
      );

      final secondArgument = capturedArgs[0][1];

      expect(
        secondArgument,
        isA<PresenceEvent>().having(
          (presence) => presence.toJson(), 
          'Should have encodable function',
          isA<Map<String, dynamic>>(),
        ),
      );

      expect(secondArgument.data, equals(payload));
    });
  });

  group('destroy method', () {
    test('Should unsubscribe from all presence events listeners', () {
      presence.destroy();

      verifyInOrder([
        mockSocketClient.offEvent(PresenceEvents.leave.description, any),
        mockSocketClient.offEvent(PresenceEvents.update.description, any),
        mockSocketClient.offEvent(PresenceEvents.joinedRoom.description, any),
      ]);
    });
  });
}
