import 'package:realtime/realtime.dart';
import 'package:realtime/src/adapters/socket_adapter.dart';

import 'package:realtime/src/services/room/models/models.dart';

void main() {
  final realtime = Realtime(
    socket: IoSocketAdapter(),
    apiKey: '',
    environment: 'dev',
    presence: UserPresence(
      id: '6c3f85b3-9631-4252-a39d-05297334ae87',
      name: 'Maelito',
    ),
    secret: '',
    clientId: '',
  );

  final room = realtime.connect('TesteRoom', null);

  room.on('state', (data) {
    room.on('Message', (event) {
      print('Message');
    });

    room.emit('Message', {'name': 'MAELITO', 'id': 'um Id'});
  });

  Future.delayed(
    const Duration(seconds: 30),
    () {
      realtime.destroy();
    },
  );
}
