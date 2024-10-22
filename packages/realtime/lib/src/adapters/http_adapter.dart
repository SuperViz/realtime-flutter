import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/exceptions.dart';
import '../interfaces/interfaces.dart';

export '../interfaces/interfaces.dart' show HttpMethod;

final class HttpAdapter implements HttpClient {
  final http.Client httpClient;

  const HttpAdapter({required this.httpClient});

  @override
  Future<HttpResponse> request({
    required String url,
    required HttpMethod method,
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final uri = Uri.parse(url);

      late final http.Response response;

      switch (method) {
        case HttpMethod.post:
          response = await httpClient.post(uri, headers: headers, body: body);
        case HttpMethod.put:
          response = await httpClient.put(uri, headers: headers, body: body);
        case HttpMethod.get:
          response = await httpClient.get(uri, headers: headers);
        case HttpMethod.delete:
          response = await httpClient.delete(uri, headers: headers, body: body);
      }

      switch (response.statusCode) {
        case 401:
          throw HttpException(
            message: response.body,
            status: response.statusCode,
          );
        default:
          return _formatResponseJson(response.body);
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(
        message: 'Unexpected error.',
        status: null,
      );
    }
  }

  HttpResponse _formatResponseJson(String json) {
    if (json.isEmpty) return HttpResponse(data: null);

    final data = jsonDecode(json);

    return HttpResponse(data: data);
  }
}
