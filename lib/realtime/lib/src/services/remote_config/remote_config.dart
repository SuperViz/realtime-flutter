import 'package:http/http.dart';

import '../../adapters/adapters.dart';
import '../config/config.dart';
import 'models/models.dart';
import 'params/params.dart';

final class RemoteConfigService {
  static const remoteConfigBaseUrl = 'https://remote-config.superviz.com';

  static final _httpClient = HttpAdapter(
    httpClient: Client(),
  );

  /// Retrieves the remote configuration for the specified environment.
  /// - `environment` - The environment to retrieve the remote configuration for. Defaults to EnvironmentTypes.PROD.
  /// returns A Future that resolves with the remote configuration object.
  static Future<RemoteConfig> getRemoteConfig([
    EnvironmentTypes environment = EnvironmentTypes.prod,
  ]) async {
    const version  = "lab";

    final remoteConfigParams = RemoteConfigParams(
      version: version,
      env: environment,
    );

    final url = createUrl(remoteConfigParams);

    final response = await _httpClient.get(url: url);

    return RemoteConfig(
      apiUrl: response.data['apiUrl'] as String,
      version: EnvironmentTypes.values.firstWhere(
        (environment) => environment.environment == response.data['version'],
      ),
    );
  }

  /// Creates a URL for fetching remote configuration data based on the provided version and environment.
  /// - `params` - The parameters for creating the URL.
  /// returns a String for the URL to fetching remote configuration data.
  static String createUrl(RemoteConfigParams remoteConfigParams) {
    return '$remoteConfigBaseUrl/realtime/${remoteConfigParams.env.environment}?env=${remoteConfigParams.env.environment}';
  }
}
