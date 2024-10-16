import '../models/github_models.dart';

/// Provides functionality to interact with the GitHub Issues API.
///
/// This API allows you to create, read, update, and manage issues in GitHub repositories.
///
/// Import this file to use the [IssuesApi] class:
/// ```dart
/// import 'package:github_kit/src/api/issues.dart';
/// ```
///
/// See also:
/// * [GitHub Issues API documentation](https://docs.github.com/en/rest/issues)
class IssuesApi {
  final SendRequestFunction _sendRequest;

  /// Creates a new [IssuesApi] instance.
  ///
  /// [_sendRequest] is a function that sends HTTP requests to the GitHub API.
  IssuesApi(this._sendRequest);

  /// Creates a new issue in a repository.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [title] is the title of the new issue.
  /// [body] is the optional body text of the issue.
  /// [labels] is an optional list of label names to apply to the issue.
  ///
  /// Returns an [Issue] object representing the newly created issue.
  ///
  /// Throws a [GitHubException] if the issue creation fails.
  Future<Issue> createIssue(String owner, String repo, String title,
      {String? body, List<String>? labels}) async {
    final json = await _sendRequest('POST', 'repos/$owner/$repo/issues', body: {
      'title': title,
      if (body != null) 'body': body,
      if (labels != null) 'labels': labels,
    });
    return Issue.fromJson(json);
  }

  /// Fetches an issue by its number.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [number] is the issue number.
  ///
  /// Returns an [Issue] object containing the issue details.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<Issue> getIssue(String owner, String repo, int number) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo/issues/$number');
    return Issue.fromJson(json);
  }

  /// Lists issues for a repository.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [state] filters issues based on their state (e.g., 'open', 'closed', 'all').
  /// [labels] filters issues based on their labels.
  /// [sort] determines how issues are sorted (e.g., 'created', 'updated', 'comments').
  /// [direction] determines the direction of the sort (e.g., 'asc' or 'desc').
  ///
  /// Returns a list of [Issue] objects.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<List<Issue>> listIssues(String owner, String repo,
      {String? state, String? sort, String? direction}) async {
    final queryParams = {
      if (state != null) 'state': state,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction,
    };
    final json = await _sendRequest('GET', 'repos/$owner/$repo/issues',
        queryParams: queryParams);
    return (json as List).map((issue) => Issue.fromJson(issue)).toList();
  }

  /// Updates an existing issue.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [number] is the issue number.
  /// [title] is the new title for the issue (optional).
  /// [body] is the new body text for the issue (optional).
  /// [state] is the new state for the issue (e.g., 'open' or 'closed', optional).
  ///
  /// Returns an [Issue] object representing the updated issue.
  ///
  /// Throws a [GitHubException] if the update fails.
  Future<Issue> updateIssue(String owner, String repo, int number,
      {String? title, String? body, String? state}) async {
    final json =
        await _sendRequest('PATCH', 'repos/$owner/$repo/issues/$number', body: {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (state != null) 'state': state,
    });
    return Issue.fromJson(json);
  }
}
