import '../github_kit_base.dart';
import '../models/github_models.dart';

class ActionsApi {
  final SendRequestFunction _sendRequest;

  ActionsApi(this._sendRequest);

  Future<List<Workflow>> listWorkflows(String owner, String repo) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo/actions/workflows');
    return (json['workflows'] as List).map((w) => Workflow.fromJson(w)).toList();
  }

  Future<WorkflowRun> createWorkflowDispatch(String owner, String repo, String workflowId, String ref, {Map<String, dynamic>? inputs}) async {
    await _sendRequest('POST', 'repos/$owner/$repo/actions/workflows/$workflowId/dispatches', body: {
      'ref': ref,
      if (inputs != null) 'inputs': inputs,
    });
    final runsJson = await _sendRequest('GET', 'repos/$owner/$repo/actions/workflows/$workflowId/runs');
    return WorkflowRun.fromJson(runsJson['workflow_runs'][0]);
  }

  Future<WorkflowRun> getWorkflowRun(String owner, String repo, int runId) async {
    final json = await _sendRequest('GET', 'repos/$owner/$repo/actions/runs/$runId');
    return WorkflowRun.fromJson(json);
  }

  Future<void> cancelWorkflowRun(String owner, String repo, int runId) async {
    await _sendRequest('POST', 'repos/$owner/$repo/actions/runs/$runId/cancel');
  }

  Future<void> rerunWorkflowRun(String owner, String repo, int runId) async {
    await _sendRequest('POST', 'repos/$owner/$repo/actions/runs/$runId/rerun');
  }
}