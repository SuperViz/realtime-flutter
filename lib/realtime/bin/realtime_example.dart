import 'package:realtime/realtime.dart';
import 'package:realtime/src/components/realtime/types/types.dart';

void main() async {
  final realtime = Realtime(
    AuthenticationParams(
      clientId: '722a950b-86a9-487e-a742-4e0a30d5491d',
      secret: 'sk_orewlu3iogeuyjy6eyh8ulmdgdjmg1',
    ),
    EnvironmentParams(
      debug: true,
      environment: EnvironmentTypes.dev,
      participant: Participant(
        id: 'b502e42c-aa22-496b-94d8-9d689d9954e2',
        name: 'Maelito',
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

  channel.publish('Qualquer', { 'name': 'Maelzinho' });

  Future.delayed(
    const Duration(seconds: 20),
    () {
      realtime.destroy();
    },
  );
}
