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

/// The main class for interacting with the GitHub API.
///
/// This class provides methods for authentication, sending requests,
/// and accessing various GitHub API endpoints.
class GitHubKit {
  /// Creates a new instance of [GitHubKit].
  ///
  /// [token] is the GitHub personal access token or OAuth token.
  /// [baseURL] is the base URL for the GitHub API, defaulting to 'https://api.github.com'.
  /// [maxRetries] is the maximum number of retries for failed requests.
  /// [retryDelay] is the delay between retries.
  /// [client] is an optional HTTP client to use for requests.
  /// [graphQLLink] is an optional GraphQL link to use for GraphQL queries.

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

  /// Sets up the logging system for GitHubKit.
  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
  /// Sends a request to the GitHub API.
  ///
  /// [method] is the HTTP method to use.
  /// [path] is the API endpoint path.
  /// [body] is the request body for POST and PUT requests.
  /// [queryParams] are the query parameters to include in the URL.
  Future<dynamic> _sendRequest(String method, String path, {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    return HttpUtils.sendRequestWithRetry(_client, method, '$baseURL/$path', token, body: body, queryParams: queryParams, maxRetries: maxRetries, retryDelay: retryDelay);
  }

  /// Executes a GraphQL query.
  ///
  /// [query] is the GraphQL query string.
  /// [variables] are the variables to include in the GraphQL query.

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

  /// Logs a message with the specified log level.
  ///
  /// [message] is the message to log.
  /// [level] is the log level to use.
  void log(String message, {LogLevel level = LogLevel.info}) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] ${level.toString().toUpperCase()}: $message');
  }

  /// Disposes of the GitHubKit instance, closing any open connections.
  void dispose() {
    _client.close();
  }
}

/// Enum representing different log levels.
enum LogLevel { debug, info, warning, error }

