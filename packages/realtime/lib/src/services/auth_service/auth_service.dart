import '../../exceptions/exceptions.dart';
import '../api/api_service.dart';
import '../config/config.dart';

Future<bool> isValidApiKey() async {
  try {
    final config = ConfigurationService();

    final apiKey = config.get<String>(ConfigurationKeys.apiKey);
    final baseUrl = config.get<String>(ConfigurationKeys.apiUrl);

    final response = await ApiService.validateApiKey(
      baseUrl: baseUrl!,
      apiKey: apiKey!,
    );

    return response == true;
  } on HttpException catch (error) {
    if (error.status == 404) return false;

    throw Exception('Unable to validate API key');
  }
}
