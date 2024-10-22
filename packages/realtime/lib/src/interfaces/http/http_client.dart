import 'http.dart';

abstract interface class HttpClient {
  Future<HttpResponse> request({
    required String url,
    required HttpMethod method,
    Map<String, String>? headers,
    Object? body,
  });
}
