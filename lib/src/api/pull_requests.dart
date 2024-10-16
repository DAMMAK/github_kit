import '../models/github_models.dart';

/// Provides functionality to interact with the GitHub Pull Requests API.
///
/// This API allows you to create, read, update, and manage pull requests in GitHub repositories.
///
/// Import this file to use the [PullRequestsApi] class:
/// ```dart
/// import 'package:github_kit/src/api/pull_requests.dart';
/// ```
///
/// See also:
/// * [GitHub Pull Requests API documentation](https://docs.github.com/en/rest/pulls)
class PullRequestsApi {
  final SendRequestFunction _sendRequest;

  /// Creates a new [PullRequestsApi] instance.
  ///
  /// [_sendRequest] is a function that sends HTTP requests to the GitHub API.
  PullRequestsApi(this._sendRequest);

  /// Creates a new pull request.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [title] is the title of the new pull request.
  /// [head] is the name of the branch where your changes are implemented.
  /// [base] is the name of the branch you want the changes pulled into.
  /// [body] is the optional body text of the pull request.
  ///
  /// Returns a [PullRequest] object representing the newly created pull request.
  ///
  /// Throws a [GitHubException] if the pull request creation fails.
  Future<PullRequest> createPullRequest(
      String owner, String repo, String title, String head, String base,
      {String? body}) async {
    final json = await _sendRequest('POST', 'repos/$owner/$repo/pulls', body: {
      'title': title,
      'head': head,
      'base': base,
      if (body != null) 'body': body,
    });
    return PullRequest.fromJson(json);
  }

  /// Fetches a pull request by its number.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [number] is the pull request number.
  ///
  /// Returns a [PullRequest] object containing the pull request details.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<PullRequest> getPullRequest(
      String owner, String repo, int number) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo/pulls/$number');
    return PullRequest.fromJson(json);
  }

  /// Lists pull requests for a repository.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [state] filters pull requests based on their state (e.g., 'open', 'closed', 'all').
  /// [sort] determines how pull requests are sorted (e.g., 'created', 'updated', 'popularity').
  /// [direction] determines the direction of the sort (e.g., 'asc' or 'desc').
  ///
  /// Returns a list of [PullRequest] objects.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<List<PullRequest>> listPullRequests(String owner, String repo,
      {String? state, String? sort, String? direction}) async {
    final queryParams = {
      if (state != null) 'state': state,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction,
    };
    final json = await _sendRequest('GET', 'repos/$owner/$repo/pulls',
        queryParams: queryParams);
    return (json as List).map((pr) => PullRequest.fromJson(pr)).toList();
  }

  /// Updates an existing pull request.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [number] is the pull request number.
  /// [title] is the new title for the pull request (optional).
  /// [body] is the new body text for the pull request (optional).
  /// [state] is the new state for the pull request (e.g., 'open' or 'closed', optional).
  ///
  /// Returns a [PullRequest] object representing the updated pull request.
  ///
  /// Throws a [GitHubException] if the update fails.
  Future<PullRequest> updatePullRequest(String owner, String repo, int number,
      {String? title, String? body, String? state}) async {
    final json =
        await _sendRequest('PATCH', 'repos/$owner/$repo/pulls/$number', body: {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (state != null) 'state': state,
    });
    return PullRequest.fromJson(json);
  }

  /// Merges a pull request.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [number] is the pull request number.
  /// [commitTitle] is the title for the automatic commit message (optional).
  /// [commitMessage] is the extra detail to append to automatic commit message (optional).
  /// [mergeMethod] is the merge method to use (e.g., 'merge', 'squash', 'rebase', optional).
  ///
  /// Returns a [PullRequest] object representing the merged pull request.
  ///
  /// Throws a [GitHubException] if the merge fails.
  Future<PullRequest> mergePullRequest(String owner, String repo, int number,
      {String? commitTitle,
      String? commitMessage,
      String mergeMethod = 'merge'}) async {
    final json = await _sendRequest(
        'PUT', 'repos/$owner/$repo/pulls/$number/merge',
        body: {
          if (commitTitle != null) 'commit_title': commitTitle,
          if (commitMessage != null) 'commit_message': commitMessage,
          'merge_method': mergeMethod,
        });
    return PullRequest.fromJson(json);
  }
}
