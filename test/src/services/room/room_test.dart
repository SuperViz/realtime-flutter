import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:faker/faker.dart';

import 'package:realtime/src/enums/enums.dart';
import 'package:realtime/src/interfaces/interfaces.dart';
import 'package:realtime/src/services/room/models/models.dart';
import 'package:realtime/src/services/room/room.dart';

import 'room_test.mocks.dart';

@GenerateMocks([SocketClient])
void main() {
  late final MockSocketClient mockSocketClient;
  late final String event;
  late final void Function(dynamic) callback;
  late final String roomName;
  late final UserPresence user;
  late final int maxConnections;

  late Room room;

  setUpAll(() {
    mockSocketClient = MockSocketClient();
    event = RoomEvent.joinRoom.description;
    callback = (data) {};
    roomName = faker.conference.name();
    user = UserPresence(
      id: faker.guid.guid(),
      name: faker.person.name(),
    );
    maxConnections = 250;
  });

  setUp(() {
    room = Room.register(
      io: mockSocketClient,
      user: user,
      roomName: roomName,
      apiKey: faker.guid.guid(),
      maxConnections: maxConnections,
    );

    when(
      mockSocketClient.onEvent(RoomEvent.joinedRoom.description, any)
    ).thenAnswer((realInvocation) {
      final joinedRoomMock = <String, dynamic>{
        "name": RoomEvent.joinedRoom.description,
        "roomId": faker.guid.guid(),
        "connectionId": faker.guid.guid(),
        "presence": null,
        "data": {
          "id": faker.guid.guid(),
          "name": roomName,
          "userId": faker.guid.guid(),
          "apiKey": "",
          "createdAt": faker.date.dateTime().toIso8601String(),
          "environment": "dev",
          "maxConnections": 250,
        },
        "timestamp": 1727964497566,
      };

      realInvocation.positionalArguments.last(joinedRoomMock);
    });
  });

  group('constructor method', () {
    test('Should emit room.join with correct value when register a room', () {
      final payload = {
        'name': roomName,
        'user': user.toMap(),
        'maxConnections': maxConnections,
      };

      verify(
        mockSocketClient.emit(RoomEvent.joinRoom.description, payload),
      ).called(1);
    });
  });

  group('on method', () {
    test('Should register onEvent with correct event', () {
      room.on(event, callback);

      verify(
        mockSocketClient.onEvent(event, any),
      ).called(1);
    });
  });

  group('off method', () {
    test('Should call offEvent with correct event', () {
      room.off(event, callback);

      verify(
        mockSocketClient.offEvent(event),
      ).called(1);
    });
  });

  group('emit method', () {
    late final Map<String, dynamic> payload;
    late final String roomUpdateEvent;

    setUpAll(() {
      payload = { 'name': faker.person.name() };

      roomUpdateEvent = RoomEvent.update.description;

      when(mockSocketClient.id).thenReturn(faker.guid.guid());
    });

    test('Should emit a room.update event with room name and correct payload', () {
      room.emit(event, payload);

      var capturedArgs = verify(
        mockSocketClient.emit(
          roomUpdateEvent,
          captureAny,
        )
      ).captured;

      expect(capturedArgs.first[0], equals(roomName));

      expect(
        capturedArgs.first[1],
        isA<Map<String, dynamic>>().having(
          (map) => map.keys,
          'map keys',
          containsAll([
            'name',
            'roomId',
            'presence',
            'connectionId',
            'data',
            'timestamp',
          ])
        ),
      );

      expect(
        capturedArgs.first[1]['data'],
        equals(payload),
      );
    });
  });

  group('history method', () {
    test('Should socket register and emit internal room event', () {
      final internalRoomEvent = InternalRoomEvents.get.description;

      room.history((data) {});

      verifyInOrder([
        mockSocketClient.onEvent(internalRoomEvent, captureThat(isA<Function>())),
        mockSocketClient.emit(internalRoomEvent, roomName),
      ]);
    });

    test('Should unregister socket listem from internal room event', () {
      final internalRoomEvent = InternalRoomEvents.get.description;

      room.history((data) {});

      final capturedArgs = verify(
        mockSocketClient.onEvent(
          internalRoomEvent,
          captureThat(isA<void Function(dynamic)>()),
        ),
      ).captured;

      final callback = capturedArgs[0];

      callback({
        'roomId': '',
        'room': {
          'id': '',
          'name': '',
          'userId': '',
          'apiKey': '',
          'createdAt': DateTime.now().toIso8601String(),
        },
        'connectionId': '',
        'timestamp': 0,
        'events': [],
      });

      verify(
        mockSocketClient.offEvent(
          internalRoomEvent,
          callback,
        ),
      ).called(1);
    });
  });

  group('disconnect method', () {
    test('Should emit leave room event on socket', () {
      room.disconnect();

      verify(
        mockSocketClient.emit(RoomEvent.leaveRoom.description, roomName),
      ).called(1);
    });

    test('Should should call presence destroy', () {
      room.disconnect();

      verifyInOrder([
        mockSocketClient.offEvent(PresenceEvents.leave.description, any),
        mockSocketClient.offEvent(PresenceEvents.update.description, any),
        mockSocketClient.offEvent(PresenceEvents.joinedRoom.description, any),
      ]);
    });
  });
}
