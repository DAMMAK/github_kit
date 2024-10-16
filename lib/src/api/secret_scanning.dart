import '../models/github_models.dart';

/// Provides functionality to interact with the GitHub Secret Scanning API.
///
/// This API allows you to retrieve and manage secret scanning alerts for a repository.
///
/// Import this file to use the [SecretScanningApi] class:
/// ```dart
/// import 'package:github_kit/src/api/secret_scanning.dart';
/// ```
///
/// See also:
/// * [GitHub Secret Scanning API documentation](https://docs.github.com/en/rest/secret-scanning)
class SecretScanningApi {
  final SendRequestFunction _sendRequest;

  /// Creates a new [SecretScanningApi] instance.
  ///
  /// [_sendRequest] is a function that sends HTTP requests to the GitHub API.
  SecretScanningApi(this._sendRequest);

  /// Lists secret scanning alerts for a repository.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [state] filters alerts based on their state (e.g., 'open', 'resolved', optional).
  /// [secretType] filters alerts based on the type of secret detected (optional).
  /// [resolution] filters alerts based on their resolution status (optional).
  ///
  /// Returns a list of [SecretScanningAlert] objects.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<List<SecretScanningAlert>> listSecretScanningAlerts(
      String owner, String repo,
      {String? state, String? secretType, String? resolution}) async {
    final queryParams = {
      if (state != null) 'state': state,
      if (secretType != null) 'secret_type': secretType,
      if (resolution != null) 'resolution': resolution,
    };
    final json = await _sendRequest(
        'GET', 'repos/$owner/$repo/secret-scanning/alerts',
        queryParams: queryParams);
    return (json as List)
        .map((alert) => SecretScanningAlert.fromJson(alert))
        .toList();
  }

  /// Fetches a secret scanning alert by its number.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [alertNumber] is the alert number.
  ///
  /// Returns a [SecretScanningAlert] object containing the alert details.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<SecretScanningAlert> getSecretScanningAlert(
      String owner, String repo, int alertNumber) async {
    final json = await _sendRequest(
        'GET', 'repos/$owner/$repo/secret-scanning/alerts/$alertNumber');
    return SecretScanningAlert.fromJson(json);
  }

  /// Updates a secret scanning alert.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [alertNumber] is the alert number.
  /// [state] is the new state for the alert (required, e.g., 'open' or 'resolved').
  /// [resolution] is the resolution status if the state is being set to 'resolved' (optional).
  ///
  /// Returns a [SecretScanningAlert] object representing the updated alert.
  ///
  /// Throws a [GitHubException] if the update fails.
  Future<SecretScanningAlert> updateSecretScanningAlert(
      String owner, String repo, int alertNumber,
      {required String state, String? resolution}) async {
    final json = await _sendRequest(
        'PATCH', 'repos/$owner/$repo/secret-scanning/alerts/$alertNumber',
        body: {
          'state': state,
          if (resolution != null) 'resolution': resolution,
        });
    return SecretScanningAlert.fromJson(json);
  }
}
