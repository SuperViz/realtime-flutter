import '../../config/config.dart';

class RemoteConfigParams {
  final String version;
  final EnvironmentTypes env;

  const RemoteConfigParams({
    required this.version,
    required this.env,
  });
}
