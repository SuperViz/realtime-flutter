import '../../../services/services.dart';
import '../../../types/types.dart';

final class RealtimeEnvironmentParams {
  final Participant? participant;
  final EnvironmentTypes environment;
  final bool debug;

  const RealtimeEnvironmentParams({
    required this.participant,
    this.environment = EnvironmentTypes.prod,
    this.debug = false,
  });
}
