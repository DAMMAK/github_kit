library github_kit;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:logging/logging.dart';
import 'package:gql/language.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_exec/gql_exec.dart';

import 'src/rate_limit.dart';

class GitHubKit {
  final String baseURL;
  String? token;
  oauth2.Client? _client;
  final Logger _logger = Logger('GitHubKit');
  final int maxRetries;
  final Duration retryDelay;

  GitHubKit({
    this.baseURL = 'https://api.github.com',
    this.token,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 5),
  }) {
    _setupLogging();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }


  Future<void> authenticateWithOAuth(String clientId, String clientSecret, List<String> scopes) async {
    final authorizationEndpoint = Uri.parse('https://github.com/login/oauth/authorize');
    final tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

    final grant = oauth2.AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: clientSecret,
    );

    // You would typically redirect the user to this URL in a web application
    final authorizationUrl = grant.getAuthorizationUrl(Uri.parse('http://localhost:8080/oauth2-redirect'), scopes: scopes);

    // After the user grants access, you would receive the authorization code
    // For this example, we'll assume you have the authorization code
    const authorizationCode = 'AUTHORIZATION_CODE';

    try {
      _client = await grant.handleAuthorizationCode(authorizationCode);
      token = _client?.credentials.accessToken;
    } catch (e) {
      throw GitHubException(400, 'Failed to authenticate: $e');
    }
  }

  Future<GitHubResponse> _retryableRequest(Future<http.Response> Function() request) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await request();
        final gitHubResponse = _handleResponse(response);
        if (gitHubResponse.rateLimit.isExceeded) {
          _logger.warning('Rate limit exceeded. Retrying after ${retryDelay.inSeconds} seconds.');
          await Future.delayed(retryDelay);
          attempts++;
        } else {
          return gitHubResponse;
        }
      } catch (e) {
        _logger.severe('Request failed: $e');
        if (attempts == maxRetries - 1) rethrow;
        attempts++;
        await Future.delayed(retryDelay);
      }
    }
    throw GitHubException(429, 'Rate limit exceeded after $maxRetries retries');
  }

  Future<GitHubResponse> get(String path, {Map<String, String>? queryParams}) async {
    return _retryableRequest(() async {
      final uri = Uri.parse('$baseURL/$path').replace(queryParameters: queryParams);
      _logger.info('GET request to $uri');
      return await (_client?.get(uri) ?? http.get(uri, headers: _headers));
    });
  }


  Future<GitHubResponse> post(String path, Map<String, dynamic> body) async {
    return _retryableRequest(() async {
      final uri =  Uri.parse('$baseURL/$path');
      _logger.info('POST request to $uri');
      return await (_client?.post(uri,body: json.encode(body)) ?? http.post(uri, headers: _headers, body:  json.encode(body)));
    });
  }

  Future<GitHubResponse> patch(String path, Map<String, dynamic> body) async {
    return _retryableRequest(() async {
      final uri =  Uri.parse('$baseURL/$path');
      _logger.info('PATCH request to $uri');
      return await (_client?.patch(uri,body: json.encode(body)) ?? http.patch(uri, headers: _headers, body:  json.encode(body)));
    });
  }

  Future<GitHubResponse> delete(String path) async {
    return _retryableRequest(() async {
      final uri =  Uri.parse('$baseURL/$path');
      _logger.info('PATCH request to $uri');
      return await (_client?.delete(uri) ?? http.delete(uri, headers: _headers));
    });
  }

  GitHubResponse _handleResponse(http.Response response) {
    final headers = response.headers;
    final body = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return GitHubResponse(
        body: body,
        statusCode: response.statusCode,
        headers: headers,
      );
    } else {
      throw GitHubException(response.statusCode, body['message'] ?? 'Unknown error');
    }
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'token $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> graphql(String query, {Map<String, dynamic>? variables}) async {
    final link = HttpLink(
      'https://api.github.com/graphql',
      defaultHeaders: {
        'Authorization': 'Bearer $token',
      },
    );

    final request = Request(
      operation: Operation(document: parseString(query)),
      variables: variables ?? {},
    );

    try {
      final response = await link.request(request).first;
      if (response.errors != null && response.errors!.isNotEmpty) {
        throw GitHubException(400, response.errors!.map((e) => e.message).join(', '));
      }
      return response.data ?? {};
    } catch (e) {
      _logger.severe('GraphQL query failed: $e');
      rethrow;
    }
  }


  // Endpoints
  late final repositories = Repositories(this);
  late final issues = Issues(this);
  late final pullRequests = PullRequests(this);
  late final users = Users(this);
  late final gists = Gists(this);
  late final teams = Teams(this);
  late final organizations = Organizations(this);
  late final projects = Projects(this);
  late final actions = Actions(this);
  late final packages = Packages(this);
  late final webhooks = Webhooks(this);
}

class GitHubResponse {
  final dynamic body;
  final int statusCode;
  final Map<String, String> headers;
  final RateLimit rateLimit;

  GitHubResponse({required this.body, required this.statusCode, required this.headers})
      : rateLimit = RateLimit.fromHeaders(headers);


  bool get hasNextPage => headers['link']?.contains('rel="next"') ?? false;
  String? get nextPageUrl => _extractUrlFromLink('next');

  String? _extractUrlFromLink(String rel) {
    final linkHeader = headers['link'];
    if (linkHeader == null) return null;
    final links = linkHeader.split(',');
    for (var link in links) {
      if (link.contains('rel="$rel"')) {
        return link.split(';').first.trim().replaceAll(['<', '>'] as Pattern, '');
      }
    }
    return null;
  }
}

class Repositories {
  final GitHubKit _kit;

  Repositories(this._kit);

  Future<Map<String, dynamic>> getRepository(String owner, String repo) async {
    final response = await _kit.get('repos/$owner/$repo');
    return response.body;
  }

  Future<List<Map<String, dynamic>>> listRepositories(String username, {int perPage = 30, int page = 1}) async {
    final response = await _kit.get('users/$username/repos', queryParams: {'per_page': perPage.toString(), 'page': page.toString()});
    return List<Map<String, dynamic>>.from(response.body);
  }



  Future<GitHubResponse> createRepository(String name, {String? description, bool private = false})async {
    return await _kit.post('user/repos', {
      'name': name,
      'description': description,
      'private': private,
    });
  }

  Future<void> deleteRepository(String owner, String repo) {
    return _kit.delete('repos/$owner/$repo');
  }
}

class Issues {
  final GitHubKit _kit;

  Issues(this._kit);

  Future<GitHubResponse> getIssue(String owner, String repo, int number)async {
    return await _kit.get('repos/$owner/$repo/issues/$number');
  }

  Future<GitHubResponse> listIssues(String owner, String repo, {String? state, String? sort, String? direction}) async{
    final params = {
      if (state != null) 'state': state,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction,
    };
    final queryString = Uri(queryParameters: params).query;
    return await _kit.get('repos/$owner/$repo/issues?$queryString');
  }

  Future<GitHubResponse> createIssue(String owner, String repo, String title, {String? body, List<String>? labels})async {
    return await _kit.post('repos/$owner/$repo/issues', {
      'title': title,
      'body': body,
      'labels': labels,
    });
  }

  Future<GitHubResponse> updateIssue(String owner, String repo, int number, {String? title, String? body, String? state})async {
    return await _kit.patch('repos/$owner/$repo/issues/$number', {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (state != null) 'state': state,
    });
  }
}

class PullRequests {
  final GitHubKit _kit;

  PullRequests(this._kit);

  Future<GitHubResponse> getPullRequest(String owner, String repo, int number)async {
    return await _kit.get('repos/$owner/$repo/pulls/$number');
  }

  Future<GitHubResponse> listPullRequests(String owner, String repo, {String? state, String? sort, String? direction})async {
    final params = {
      if (state != null) 'state': state,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction,
    };
    final queryString = Uri(queryParameters: params).query;
    return await _kit.get('repos/$owner/$repo/pulls?$queryString');
  }

  Future<GitHubResponse> createPullRequest(String owner, String repo, String title, String head, String base, {String? body})async {
    return await _kit.post('repos/$owner/$repo/pulls', {
      'title': title,
      'head': head,
      'base': base,
      'body': body,
    });
  }
}

class Users {
  final GitHubKit _kit;

  Users(this._kit);

  Future<GitHubResponse> getUser(String username)async {
    return await _kit.get('users/$username');
  }

  Future<GitHubResponse> getCurrentUser()async {
    return await _kit.get('user');
  }

  Future<GitHubResponse> listFollowers(String username)async {
    return await _kit.get('users/$username/followers');
  }

  Future<GitHubResponse> listFollowing(String username)async {
    return await _kit.get('users/$username/following');
  }
}


class Gists {
  final GitHubKit _kit;

  Gists(this._kit);

  Future<Map<String, dynamic>> getGist(String id) async {
    final response = await _kit.get('gists/$id');
    return response.body;
  }

  Future<List<Map<String, dynamic>>> listGists(String username, {int perPage = 30, int page = 1}) async {
    final response = await _kit.get('users/$username/gists', queryParams: {'per_page': perPage.toString(), 'page': page.toString()});
    return List<Map<String, dynamic>>.from(response.body);
  }

  Future<Map<String, dynamic>> createGist(Map<String, String> files, {String? description, bool public = false}) async {
    final response = await _kit.post('gists', {
      'files': files,
      'description': description,
      'public': public,
    });
    return response.body;
  }
}

class Teams {
  final GitHubKit _kit;

  Teams(this._kit);

  Future<Map<String, dynamic>> getTeam(int teamId) async {
    final response = await _kit.get('teams/$teamId');
    return response.body;
  }

  Future<List<Map<String, dynamic>>> listTeamMembers(int teamId, {int perPage = 30, int page = 1}) async {
    final response = await _kit.get('teams/$teamId/members', queryParams: {'per_page': perPage.toString(), 'page': page.toString()});
    return List<Map<String, dynamic>>.from(response.body);
  }
}

class Organizations {
  final GitHubKit _kit;

  Organizations(this._kit);

  Future<Map<String, dynamic>> getOrganization(String org) async {
    final response = await _kit.get('orgs/$org');
    return response.body;
  }

  Future<List<Map<String, dynamic>>> listOrganizationMembers(String org, {int perPage = 30, int page = 1}) async {
    final response = await _kit.get('orgs/$org/members', queryParams: {'per_page': perPage.toString(), 'page': page.toString()});
    return List<Map<String, dynamic>>.from(response.body);
  }

  Future<Map<String, dynamic>> createOrganization(String login, String adminEmail, {String? name}) async {
    final response = await _kit.post('admin/organizations', {
      'login': login,
      'admin': adminEmail,
      'name': name,
    });
    return response.body;
  }
}

class Projects {
  final GitHubKit _kit;

  Projects(this._kit);

  Future<Map<String, dynamic>> getProject(int projectId) async {
    final response = await _kit.get('projects/$projectId');
    return response.body;
  }

  Future<List<Map<String, dynamic>>> listProjectColumns(int projectId) async {
    final response = await _kit.get('projects/$projectId/columns');
    return List<Map<String, dynamic>>.from(response.body);
  }

  Future<Map<String, dynamic>> createProjectCard(int columnId, {String? note, int? contentId, String? contentType}) async {
    final response = await _kit.post('projects/columns/$columnId/cards', {
      if (note != null) 'note': note,
      if (contentId != null) 'content_id': contentId,
      if (contentType != null) 'content_type': contentType,
    });
    return response.body;
  }
}

class Actions {
  final GitHubKit _kit;

  Actions(this._kit);

  Future<List<Map<String, dynamic>>> listWorkflowRuns(String owner, String repo) async {
    final response = await _kit.get('repos/$owner/$repo/actions/runs');
    return List<Map<String, dynamic>>.from(response.body['workflow_runs']);
  }

  Future<Map<String, dynamic>> getWorkflowRun(String owner, String repo, int runId) async {
    final response = await _kit.get('repos/$owner/$repo/actions/runs/$runId');
    return response.body;
  }

  Future<void> reRunWorkflow(String owner, String repo, int runId) async {
    await _kit.post('repos/$owner/$repo/actions/runs/$runId/rerun', {});
  }
}

class Packages {
  final GitHubKit _kit;

  Packages(this._kit);

  Future<List<Map<String, dynamic>>> listPackagesForOrg(String org, {String packageType = 'container'}) async {
    final response = await _kit.get('orgs/$org/packages', queryParams: {'package_type': packageType});
    return List<Map<String, dynamic>>.from(response.body);
  }

  Future<Map<String, dynamic>> getPackage(String packageType, String packageName, {String? org, String? username}) async {
    String path;
    if (org != null) {
      path = 'orgs/$org/packages/$packageType/$packageName';
    } else if (username != null) {
      path = 'users/$username/packages/$packageType/$packageName';
    } else {
      throw ArgumentError('Either org or username must be provided');
    }
    final response = await _kit.get(path);
    return response.body;
  }
}

class Webhooks {
  final GitHubKit _kit;

  Webhooks(this._kit);

  Future<List<Map<String, dynamic>>> listRepoWebhooks(String owner, String repo) async {
    final response = await _kit.get('repos/$owner/$repo/hooks');
    return List<Map<String, dynamic>>.from(response.body);
  }

  Future<Map<String, dynamic>> createWebhook(String owner, String repo, String url, {List<String> events = const ['push']}) async {
    final response = await _kit.post('repos/$owner/$repo/hooks', {
      'name': 'web',
      'active': true,
      'events': events,
      'config': {
        'url': url,
        'content_type': 'json',
      },
    });
    return response.body;
  }

  Future<void> deleteWebhook(String owner, String repo, int hookId) async {
    await _kit.delete('repos/$owner/$repo/hooks/$hookId');
  }
}

class GitHubException implements Exception {
  final int statusCode;
  final String message;

  GitHubException(this.statusCode, this.message);

  @override
  String toString() => 'GitHubException: $statusCode - $message';
}

// File: lib/github_kit.dart (continued)

// Helper function for pagination
Future<List<T>> paginateAll<T>(
    Future<GitHubResponse> Function(int page) fetcher,
    T Function(dynamic) converter,
    ) async {
  List<T> allItems = [];
  int page = 1;
  GitHubResponse response;

  do {
    response = await fetcher(page);
    allItems.addAll(response.body.map<T>(converter).toList());
    page++;
  } while (response.hasNextPage);

  return allItems;
}

// Example usage of pagination helper
extension RepositoriesPagination on Repositories {
  Future<List<Map<String, dynamic>>> listAllRepositories(String username) {
    return paginateAll<Map<String, dynamic>>(
          (page) => _kit.get('users/$username/repos', queryParams: {'per_page': '100', 'page': page.toString()}),
          (item) => item as Map<String, dynamic>,
    );
  }
}

