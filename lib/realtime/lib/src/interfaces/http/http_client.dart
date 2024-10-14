import 'http.dart';

abstract interface class HttpClient {
  Future<HttpResponse> delete({
    required String url,
    Map<String, String>? headers,
    Object? body,
  });
  Future<HttpResponse> get({
    required String url,
    Map<String, String>? headers,
  });
  Future<HttpResponse> post({
    required String url,
    Map<String, String>? headers,
    Object? body,
  });
  Future<HttpResponse> put({
    required String url,
    Map<String, String>? headers,
    Object? body,
  });
}
