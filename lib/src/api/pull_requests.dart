import '../github_kit_base.dart';
import '../models/github_models.dart';

class PullRequestsApi {
  final SendRequestFunction _sendRequest;

  PullRequestsApi(this._sendRequest);

  Future<PullRequest> createPullRequest(String owner, String repo, String title, String head, String base, {String? body}) async {
    final json = await _sendRequest('POST', 'repos/$owner/$repo/pulls', body: {
      'title': title,
      'head': head,
      'base': base,
      if (body != null) 'body': body,
    });
    return PullRequest.fromJson(json);
  }

  Future<PullRequest> getPullRequest(String owner, String repo, int number) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo/pulls/$number');
    return PullRequest.fromJson(json);
  }

  Future<List<PullRequest>> listPullRequests(String owner, String repo, {String? state, String? sort, String? direction}) async {
    final queryParams = {
      if (state != null) 'state': state,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction,
    };
    final json = await _sendRequest('GET', 'repos/$owner/$repo/pulls', queryParams: queryParams);
    return (json as List).map((pr) => PullRequest.fromJson(pr)).toList();
  }

  Future<PullRequest> updatePullRequest(String owner, String repo, int number, {String? title, String? body, String? state}) async {
    final json = await _sendRequest('PATCH', 'repos/$owner/$repo/pulls/$number', body: {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (state != null) 'state': state,
    });
    return PullRequest.fromJson(json);
  }

  Future<PullRequest> mergePullRequest(String owner, String repo, int number, {String? commitTitle, String? commitMessage, String mergeMethod = 'merge'}) async {
    final json = await _sendRequest('PUT', 'repos/$owner/$repo/pulls/$number/merge', body: {
      if (commitTitle != null) 'commit_title': commitTitle,
      if (commitMessage != null) 'commit_message': commitMessage,
      'merge_method': mergeMethod,
    });
    return PullRequest.fromJson(json);
  }
}