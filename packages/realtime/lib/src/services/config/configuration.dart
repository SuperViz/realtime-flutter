import 'enums/enums.dart';

interface class Configuration {
  String? roomId;
  EnvironmentTypes? environment;
  String? apiKey;
  String? secret;
  String? clientId;
  String? apiUrl;
  bool? debug;

  Configuration({
    this.roomId,
    this.environment,
    this.apiKey,
    this.secret,
    this.clientId,
    this.apiUrl,
    this.debug,
  });
}
