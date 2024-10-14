import '../github_kit_base.dart';
import '../models/github_models.dart';

class CodeScanningApi {
  final SendRequestFunction _sendRequest;

  CodeScanningApi(this._sendRequest);

  Future<List<CodeScanningAlert>> listCodeScanningAlerts(String owner, String repo, {String? state, String? sort, String? direction}) async {
    final queryParams = {
      if (state != null) 'state': state,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction,
    };
    final json = await _sendRequest('GET', 'repos/$owner/$repo/code-scanning/alerts', queryParams: queryParams);
    return (json as List).map((alert) => CodeScanningAlert.fromJson(alert)).toList();
  }

  Future<CodeScanningAlert> getCodeScanningAlert(String owner, String repo, int alertNumber) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo/code-scanning/alerts/$alertNumber');
    return CodeScanningAlert.fromJson(json);
  }

  Future<CodeScanningAlert> updateCodeScanningAlert(String owner, String repo, int alertNumber, {required String state, String? dismissedReason}) async {
    final json = await _sendRequest('PATCH', 'repos/$owner/$repo/code-scanning/alerts/$alertNumber', body: {
      'state': state,
      if (dismissedReason != null) 'dismissed_reason': dismissedReason,
    });
    return CodeScanningAlert.fromJson(json);
  }
}