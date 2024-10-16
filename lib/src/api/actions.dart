import '../models/github_models.dart';

/// Provides functionality to interact with the GitHub Actions API.
///
/// This API allows you to manage and interact with GitHub Actions workflows and runs.
///
/// Import this file to use the [ActionsApi] class:
/// ```dart
/// import 'package:github_kit/src/api/actions.dart';
/// ```
///
/// See also:
/// * [GitHub Actions API documentation](https://docs.github.com/en/rest/actions)
class ActionsApi {
  final SendRequestFunction _sendRequest;

  /// Creates a new [ActionsApi] instance.
  ///
  /// [_sendRequest] is a function that sends HTTP requests to the GitHub API.
  ActionsApi(this._sendRequest);

  /// Lists workflows for a repository.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  ///
  /// Returns a list of [Workflow] objects.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<List<Workflow>> listWorkflows(String owner, String repo) async {
    final json =
        await _sendRequest('GET', 'repos/$owner/$repo/actions/workflows');
    return (json['workflows'] as List)
        .map((w) => Workflow.fromJson(w))
        .toList();
  }

  /// Creates a workflow dispatch event.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [workflowId] is the ID of the workflow to trigger.
  /// [ref] is the git reference for the workflow (e.g., branch or tag name).
  /// [inputs] is an optional map of input keys and values to pass to the workflow.
  ///
  /// Returns a [WorkflowRun] object representing the triggered workflow run.
  ///
  /// Throws a [GitHubException] if the workflow dispatch fails.
  Future<WorkflowRun> createWorkflowDispatch(
      String owner, String repo, String workflowId, String ref,
      {Map<String, dynamic>? inputs}) async {
    await _sendRequest(
        'POST', 'repos/$owner/$repo/actions/workflows/$workflowId/dispatches',
        body: {
          'ref': ref,
          if (inputs != null) 'inputs': inputs,
        });
    final runsJson = await _sendRequest(
        'GET', 'repos/$owner/$repo/actions/workflows/$workflowId/runs');
    return WorkflowRun.fromJson(runsJson['workflow_runs'][0]);
  }

  /// Fetches a workflow run by its ID.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [runId] is the ID of the workflow run.
  ///
  /// Returns a [WorkflowRun] object containing the workflow run details.
  ///
  /// Throws a [GitHubException] if the API request fails.
  Future<WorkflowRun> getWorkflowRun(
      String owner, String repo, int runId) async {
    final json =
        await _sendRequest('GET', 'repos/$owner/$repo/actions/runs/$runId');
    return WorkflowRun.fromJson(json);
  }

  /// Cancels a workflow run.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [runId] is the ID of the workflow run to cancel.
  ///
  /// Throws a [GitHubException] if the cancellation fails.
  Future<void> cancelWorkflowRun(String owner, String repo, int runId) async {
    await _sendRequest('POST', 'repos/$owner/$repo/actions/runs/$runId/cancel');
  }

  /// Reruns a workflow run.
  ///
  /// [owner] is the username of the repository owner.
  /// [repo] is the name of the repository.
  /// [runId] is the ID of the workflow run to rerun.
  ///
  /// Throws a [GitHubException] if the rerun fails.
  Future<void> rerunWorkflowRun(String owner, String repo, int runId) async {
    await _sendRequest('POST', 'repos/$owner/$repo/actions/runs/$runId/rerun');
  }
}
