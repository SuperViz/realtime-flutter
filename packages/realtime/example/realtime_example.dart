import 'package:superviz_realtime/superviz_realtime.dart';

void main() async {
  final realtime = Realtime(
    RealtimeAuthenticationParams(
      clientId: '',
      secret: '',
    ),
    RealtimeEnvironmentParams(
      participant: Participant(
        id: '',
      ),
    ),
  );

  final channel = await realtime.connect('ExampleChannel');

  print('Observers: ${channel.observers}');

  channel.subscribe('Qualquer', (data) {
    print(data);
  });

  await Future.delayed(Duration(seconds: 10));

  final participants = await channel.participant.getAll();

  print('Participants: $participants');

  channel.publish('Qualquer', {'name': 'Maelzinho'});

  Future.delayed(
    const Duration(seconds: 20),
    () {
      realtime.destroy();
    },
  );
}
