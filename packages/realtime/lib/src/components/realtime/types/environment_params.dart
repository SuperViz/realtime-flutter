import '../../../services/services.dart';
import '../../../types/types.dart';

final class EnvironmentParams {
  final Participant? participant;
  final EnvironmentTypes? environment;
  final bool? debug;

  const EnvironmentParams({
    required this.participant,
    required this.environment,
    required this.debug,
  });
}
