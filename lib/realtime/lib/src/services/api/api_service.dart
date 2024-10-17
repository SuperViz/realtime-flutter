import 'package:http/http.dart';

import '../../adapters/adapters.dart';
import '../../exceptions/exceptions.dart';
import '../config/config.dart';
import 'models/models.dart';

class ApiService {
  static final _config = ConfigurationService();

  static final _httpClient = HttpAdapter(
    httpClient: Client(),
  );

  /// Create an URL
  /// - `baseUrl` - The base path of your URL with out schema (https://)
  /// - `path` - The path to complete your URL
  /// - `query` - Query parameters to to pass on your URL
  ///
  /// Example:
  /// ```dart
  /// var url = ApiService.createUrl(
  ///   baseUrl: 'example.com',
  ///   path: '/path',
  ///   query: { 'e': 'xample' },
  /// );
  ///
  /// print(url); // https://example.com/path?e=xample
  /// ```
  static String createUrl({
    required String baseUrl,
    required String path,
    Map<String, dynamic> query = const <String, dynamic>{},
  }) {
    final String url = Uri.https(baseUrl, path, query).toString();

    return url;
  }

  /// Validate an API key
  static Future<bool> validateApiKey({
    required String baseUrl,
    required String apiKey,
  }) async {
    try {
      final path = '/user/checkapikey';
      final url = createUrl(
        baseUrl: baseUrl,
        path: path,
      );

      final response = await _httpClient.request(
        url: url,
        method: HttpMethod.post,
        body: { apiKey },
      );

      return response.data as bool;
    } on HttpException {
      rethrow;
    }
  }

  static Future<ComponentLimits> fetchLimits(String baseUrl, String apikey) async {
    const path = '/user/check_limits_v2';
    final url = createUrl(baseUrl: baseUrl, path: path);
    final result = await _httpClient.request(
      url: url,
      method: HttpMethod.get,
      headers: { 'apiKey': apikey },
    );
    return ComponentLimits.fromMap(result.data['limits']);
  }

  static Future<String> fetchApiKey() async {
    final apiUrl = _config.get<String>(ConfigurationKeys.apiUrl);
    final secret = _config.get<String>(ConfigurationKeys.secret);
    final clientId = _config.get<String>(ConfigurationKeys.clientId);

    const path = '/socket/key';

    final url = createUrl(baseUrl: apiUrl!, path: path);

    final headers = {
      'client_id': clientId!,
      'secret': secret!,
    };

    try {
      final result = await _httpClient.request(
        url: url,
        method: HttpMethod.get,
        headers: headers,
      );

      return result.data['apiKey'] ?? '';
    } catch (error) {
      print('[SuperViz] - Error $error');
      rethrow;
    }
  }

  static sendActivity(String userId) async {
    final baseUrl = _config.get<String>(ConfigurationKeys.apiUrl);
    final apikey = _config.get<String>(ConfigurationKeys.apiKey);

    const path = '/activity';

    final url = createUrl(baseUrl: baseUrl!, path: path);

    final body = {
      'product': 'realtime',
      'userId': userId,
    };

    await _httpClient.request(
      url: url,
      method: HttpMethod.post,
      headers: { 'apikey': apikey! },
      body: body,
    );
  }
}
