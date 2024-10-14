import 'package:http/http.dart' as http;
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:logging/logging.dart';
import 'api/repositories.dart';
import 'api/issues.dart';
import 'api/pull_requests.dart';
import 'api/actions.dart';
import 'api/code_scanning.dart';
import 'api/secret_scanning.dart';
import 'utils/http_utils.dart';
import 'package:gql/language.dart';


class GitHubKit {
  final String token;
  final String baseURL;
   http.Client _client;
   Link? _graphQLLink;
  final Logger _logger = Logger('GitHubKit');
  final int maxRetries;
  final Duration retryDelay;

  late final RepositoriesApi repositories;
  late final IssuesApi issues;
  late final PullRequestsApi pullRequests;
  late final ActionsApi actions;
  late final CodeScanningApi codeScanning;
  late final SecretScanningApi secretScanning;

  GitHubKit({
    required this.token,
    this.baseURL = 'https://api.github.com',
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 5),
    http.Client? client,
    Link? graphQLLink,
  }) : _client = client ?? http.Client(),
        _graphQLLink = graphQLLink ?? HttpLink(
          'https://api.github.com/graphql',
          defaultHeaders: {
            'Authorization': 'Bearer $token',
          },
        ){
      _setupLogging();
      repositories = RepositoriesApi(_sendRequest);
      issues = IssuesApi(_sendRequest);
      pullRequests = PullRequestsApi(_sendRequest);
      actions = ActionsApi(_sendRequest);
      codeScanning = CodeScanningApi(_sendRequest);
      secretScanning = SecretScanningApi(_sendRequest);
  }

  // GitHubKit({
  //   required this.token,
  //   this.baseURL = 'https://api.github.com',
  //   this.maxRetries = 3,
  //   this.retryDelay = const Duration(seconds: 5),
  //   http.Client? client,
  //   Link? graphQLLink,
  // }) {
  //   _client = client ?? http.Client();
  //   _setupLogging();
  //   _graphQLLink = graphQLLink ?? HttpLink(
  //     'https://api.github.com/graphql',
  //     defaultHeaders: {
  //       'Authorization': 'Bearer $token',
  //     },
  //   );
  //   repositories = RepositoriesApi(_sendRequest);
  //   issues = IssuesApi(_sendRequest);
  //   pullRequests = PullRequestsApi(_sendRequest);
  //   actions = ActionsApi(_sendRequest);
  //   codeScanning = CodeScanningApi(_sendRequest);
  //   secretScanning = SecretScanningApi(_sendRequest);
  // }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<dynamic> _sendRequest(String method, String path, {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    return HttpUtils.sendRequestWithRetry(_client, method, '$baseURL/$path', token, body: body, queryParams: queryParams, maxRetries: maxRetries, retryDelay: retryDelay);
  }

  // Future<Map<String, dynamic>> graphql(String query, {Map<String, dynamic>? variables}) async {
  //   final link = HttpLink(
  //     'https://api.github.com/graphql',
  //     defaultHeaders: {
  //       'Authorization': 'Bearer $token',
  //     },
  //   );
  //
  //   final request = Request(
  //     operation: Operation(document: parseString(query)),
  //     variables: variables ?? {},
  //   );
  //
  //   try {
  //     final response = await link.request(request).first;
  //     if (response.errors != null && response.errors!.isNotEmpty) {
  //       throw GitHubException(400, response.errors!.map((e) => e.message).join(', '));
  //     }
  //     return response.data ?? {};
  //   } catch (e) {
  //     _logger.severe('GraphQL query failed: $e');
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> graphql(String query, {Map<String, dynamic>? variables}) async {
    final request = Request(
      operation: Operation(document: parseString(query)),
      variables: variables ?? {},
    );

    final result = await _graphQLLink!.request(request).first;
    if (result.errors != null && result.errors!.isNotEmpty) {
      throw Exception(result.errors!.map((e) => e.message).join(', '));
    }
    return result.data ?? {};
  }

  void log(String message, {LogLevel level = LogLevel.info}) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] ${level.toString().toUpperCase()}: $message');
  }

  void dispose() {
    _client.close();
  }
}

enum LogLevel { debug, info, warning, error }

