import '../github_kit_base.dart';
import '../models/github_models.dart';

class RepositoriesApi {
  final SendRequestFunction _sendRequest;

  RepositoriesApi(this._sendRequest);

  Future<Repository> getRepository(String owner, String repo) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo');
    return Repository.fromJson(json);
  }

  Future<Repository> createRepository(String name, {bool private = false, String? description}) async {
    final json = await _sendRequest('POST', 'user/repos', body: {
      'name': name,
      'private': private,
      if (description != null) 'description': description,
      'headers': {
        'X-GitHub-Api-Version': '2022-11-28'
      }
    });
    return Repository.fromJson(json);
  }

  Future<List<Repository>> listRepositories(String username, {int perPage = 30, int page = 1}) async {
    final json = await _sendRequest('GET', 'users/$username/repos', queryParams: {'per_page': perPage.toString(), 'page': page.toString()});
    return (json as List).map((repo) => Repository.fromJson(repo)).toList();
  }

  Future<void> deleteRepository(String owner, String repo) async {
    await _sendRequest('DELETE', 'repos/$owner/$repo');
  }
}