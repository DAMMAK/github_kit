import '../github_kit_base.dart';
import '../models/github_models.dart';

class SecretScanningApi {
  final SendRequestFunction _sendRequest;

  SecretScanningApi(this._sendRequest);

  Future<List<SecretScanningAlert>> listSecretScanningAlerts(String owner, String repo, {String? state, String? secretType, String? resolution}) async {
    final queryParams = {
      if (state != null) 'state': state,
      if (secretType != null) 'secret_type': secretType,
      if (resolution != null) 'resolution': resolution,
    };
    final json = await _sendRequest('GET', 'repos/$owner/$repo/secret-scanning/alerts', queryParams: queryParams);
    return (json as List).map((alert) => SecretScanningAlert.fromJson(alert)).toList();
  }

  Future<SecretScanningAlert> getSecretScanningAlert(String owner, String repo, int alertNumber) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo/secret-scanning/alerts/$alertNumber');
    return SecretScanningAlert.fromJson(json);
  }

  Future<SecretScanningAlert> updateSecretScanningAlert(String owner, String repo, int alertNumber, {required String state, String? resolution}) async {
    final json = await _sendRequest('PATCH', 'repos/$owner/$repo/secret-scanning/alerts/$alertNumber', body: {
      'state': state,
      if (resolution != null) 'resolution': resolution,
    });
    return SecretScanningAlert.fromJson(json);
  }
}