import 'dart:convert';

import 'package:http/http.dart' as http;

import '../interfaces/http/http_client.dart';
import '../interfaces/http/http_response.dart';

final class HttpAdapter implements HttpClient {
  final http.Client httpClient;

  const HttpAdapter({required this.httpClient});

  @override
  Future<HttpResponse> delete({
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final uri = Uri.parse(url);

      final response = await httpClient.delete(
        uri,
        headers: headers,
        body: body,
      );

      return _formatResponseJson(response.body);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<HttpResponse> get({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);

      final response = await httpClient.get(
        uri,
        headers: headers,
      );

      return _formatResponseJson(response.body);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<HttpResponse> post({
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final uri = Uri.parse(url);

      final response = await httpClient.post(
        uri,
        body: body,
        headers: headers,
      );

      return _formatResponseJson(response.body);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<HttpResponse> put({
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final uri = Uri.parse(url);

      final response = await httpClient.put(
        uri,
        body: body,
        headers: headers,
      );

      return _formatResponseJson(response.body);
    } catch (e) {
      rethrow;
    }
  }

  HttpResponse _formatResponseJson(String json) {
    final data = jsonDecode(json);

    return HttpResponse(data: data);
  }
}
