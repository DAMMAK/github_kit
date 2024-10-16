import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpUtils {
  static Future<dynamic> sendRequestWithRetry(
    http.Client client,
    String method,
    String url,
    String token, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 5),
  }) async {
    int retries = 0;
    while (true) {
      try {
        final response = await sendRequest(client, method, url, token,
            body: body, queryParams: queryParams);
        return json.decode(response.body);
      } catch (e) {
        if (e is GitHubException &&
            e.statusCode == 403 &&
            retries < maxRetries) {
          retries++;
          await Future.delayed(retryDelay);
        } else {
          rethrow;
        }
      }
    }
  }

  static Future<http.Response> sendRequest(
    http.Client client,
    String method,
    String url,
    String token, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final headers = {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
    };

    http.Response response;
    switch (method) {
      case 'GET':
        response = await client.get(uri, headers: headers);
        break;
      case 'POST':
        response =
            await client.post(uri, headers: headers, body: json.encode(body));
        break;
      case 'PATCH':
        response =
            await client.patch(uri, headers: headers, body: json.encode(body));
        break;
      case 'PUT':
        response =
            await client.put(uri, headers: headers, body: json.encode(body));
        break;
      case 'DELETE':
        response = await client.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw GitHubException(response.statusCode, response.body);
    }
  }
}

class GitHubException implements Exception {
  final int statusCode;
  final String message;

  GitHubException(this.statusCode, this.message);

  @override
  String toString() => 'GitHubException: $statusCode - $message';
}
