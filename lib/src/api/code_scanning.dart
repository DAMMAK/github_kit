import '../models/github_models.dart';

/// Provides functionality to interact with the GitHub Code Scanning API.
///
/// This API allows you to retrieve and manage code scanning alerts for a repository.
///
/// Import this file to use the [CodeScanningApi] class:
/// ```dart
/// import 'package:github_kit/src/api/code_scanning.dart';
/// ```
///
/// See also:
/// * [GitHub Code Scanning API documentation](https://docs.github.com/en/rest/code-scanning)

class CodeScanningApi {
  final SendRequestFunction _sendRequest;

  /// Creates a new [CodeScanningApi] instance.
  ///
  /// [_sendRequest] is a function that sends HTTP requests to the GitHub API.
  CodeScanningApi(this._sendRequest);

  /// Lists code scanning alerts for a repository.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [state] filters alerts based on their state (e.g., 'open', 'closed', 'fixed', optional).
  /// [sort] determines how alerts are sorted (optional).
  /// [direction] determines the direction of the sort (e.g., 'asc' or 'desc', optional).
  ///
  /// Returns a list of [CodeScanningAlert] objects.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<List<CodeScanningAlert>> listCodeScanningAlerts(
      String owner, String repo,
      {String? state, String? sort, String? direction}) async {
    final queryParams = {
      if (state != null) 'state': state,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction,
    };
    final json = await _sendRequest(
        'GET', 'repos/$owner/$repo/code-scanning/alerts',
        queryParams: queryParams);
    return (json as List)
        .map((alert) => CodeScanningAlert.fromJson(alert))
        .toList();
  }

  /// Fetches a code scanning alert by its number.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [alertNumber] is the alert number.
  ///
  /// Returns a [CodeScanningAlert] object containing the alert details.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<CodeScanningAlert> getCodeScanningAlert(
      String owner, String repo, int alertNumber) async {
    final json = await _sendRequest(
        'GET', 'repos/$owner/$repo/code-scanning/alerts/$alertNumber');
    return CodeScanningAlert.fromJson(json);
  }

  /// Updates a code scanning alert.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [alertNumber] is the alert number.
  /// [state] is the new state for the alert (required, e.g., 'open' or 'closed').
  /// [dismissedReason] is the reason for dismissing the alert (optional, required if state is 'closed').
  ///
  /// Returns a [CodeScanningAlert] object representing the updated alert.
  ///
  /// Throws a [GitHubException] if the update fails.
  Future<CodeScanningAlert> updateCodeScanningAlert(
      String owner, String repo, int alertNumber,
      {required String state, String? dismissedReason}) async {
    final json = await _sendRequest(
        'PATCH', 'repos/$owner/$repo/code-scanning/alerts/$alertNumber',
        body: {
          'state': state,
          if (dismissedReason != null) 'dismissed_reason': dismissedReason,
        });
    return CodeScanningAlert.fromJson(json);
  }
}
