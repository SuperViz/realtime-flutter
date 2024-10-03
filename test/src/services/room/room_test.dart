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

  late Room room;

  setUpAll(() {
    event = RoomEvent.joinRoom.description;
    callback = (data) {};
    roomName = faker.conference.name();
    user = UserPresence(
      id: faker.guid.guid(),
      name: faker.person.name(),
    );

    mockSocketClient = MockSocketClient();
  });

  setUp(() {
    room = Room.register(
      io: mockSocketClient,
      user: user,
      roomName: roomName,
      apiKey: faker.guid.guid(),
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
}
