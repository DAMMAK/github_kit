import '../github_kit_base.dart';
import '../models/github_models.dart';

class IssuesApi {
  final SendRequestFunction _sendRequest;

  IssuesApi(this._sendRequest);

  Future<Issue> createIssue(String owner, String repo, String title, {String? body, List<String>? labels}) async {
    final json = await _sendRequest('POST', 'repos/$owner/$repo/issues', body: {
      'title': title,
      if (body != null) 'body': body,
      if (labels != null) 'labels': labels,
    });
    return Issue.fromJson(json);
  }

  Future<Issue> getIssue(String owner, String repo, int number) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo/issues/$number');
    return Issue.fromJson(json);
  }

  Future<List<Issue>> listIssues(String owner, String repo, {String? state, String? sort, String? direction}) async {
    final queryParams = {
      if (state != null) 'state': state,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction,
    };
    final json = await _sendRequest('GET', 'repos/$owner/$repo/issues', queryParams: queryParams);
    return (json as List).map((issue) => Issue.fromJson(issue)).toList();
  }

  Future<Issue> updateIssue(String owner, String repo, int number, {String? title, String? body, String? state}) async {
    final json = await _sendRequest('PATCH', 'repos/$owner/$repo/issues/$number', body: {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (state != null) 'state': state,
    });
    return Issue.fromJson(json);
  }
}