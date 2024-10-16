import '../models/github_models.dart';

/// Provides functionality to interact with the GitHub Repositories API.
///
/// This API allows you to create, read, update, and delete repositories,
/// as well as manage repository-related operations.
///
/// Import this file to use the [RepositoriesApi] class:
/// ```dart
/// import 'package:github_kit/src/api/repositories.dart';
/// ```
///
/// See also:
/// * [GitHub Repositories API documentation](https://docs.github.com/en/rest/repos)
class RepositoriesApi {
  final SendRequestFunction _sendRequest;

  /// Creates a new [RepositoriesApi] instance.
  ///
  /// [_sendRequest] is a function that sends HTTP requests to the GitHub API.
  RepositoriesApi(this._sendRequest);

  /// Fetches a repository by owner and name.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  Future<Repository> getRepository(String owner, String repo) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo');
    return Repository.fromJson(json);
  }

  /// Creates a new repository.
  ///
  /// [name] is the name of the new repository.
  /// [private] determines if the repository should be private.
  /// [description] is an optional description for the repository.
  Future<Repository> createRepository(String name,
      {bool private = false, String? description}) async {
    final json = await _sendRequest('POST', 'user/repos', body: {
      'name': name,
      'private': private,
      if (description != null) 'description': description,
      'headers': {'X-GitHub-Api-Version': '2022-11-28'}
    });
    return Repository.fromJson(json);
  }

  /// Lists repositories for a user.
  ///
  /// [username] is the username of the user whose repositories to list.
  /// [perPage] is the number of results per page.
  /// [page] is the page number to fetch.
  Future<List<Repository>> listRepositories(String username,
      {int perPage = 30, int page = 1}) async {
    final json = await _sendRequest('GET', 'users/$username/repos',
        queryParams: {'per_page': perPage.toString(), 'page': page.toString()});
    return (json as List).map((repo) => Repository.fromJson(repo)).toList();
  }

  /// Deletes a repository.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository to delete.
  Future<void> deleteRepository(String owner, String repo) async {
    await _sendRequest('DELETE', 'repos/$owner/$repo');
  }
}
