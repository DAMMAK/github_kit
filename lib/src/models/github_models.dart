/// A typedef for a function that sends HTTP requests to the GitHub API.
///
/// [method] is the HTTP method (e.g., 'GET', 'POST').
/// [path] is the API endpoint path.
/// [body] is an optional request body for POST, PUT, or PATCH requests.
/// [queryParams] are optional query parameters to be added to the URL.
typedef SendRequestFunction = Future<dynamic> Function(
    String method, String path,
    {Map<String, dynamic>? body, Map<String, String>? queryParams});

/// Represents a GitHub repository.
class Repository {
  /// The unique identifier of the repository.
  final int id;

  /// The name of the repository.
  final String name;

  /// The full name of the repository (owner/name).
  final String fullName;

  /// A short description of the repository.
  final String? description;

  /// Indicates whether the repository is private.
  final bool private;

  /// Creates a new [Repository] instance.
  Repository(
      {required this.id,
      required this.name,
      required this.fullName,
      this.description,
      required this.private});

  /// Creates a [Repository] instance from a JSON map.
  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'],
      description: json['description'],
      private: json['private'],
    );
  }
}

/// Represents a GitHub issue.
class Issue {
  /// The issue number.
  final int number;

  /// The title of the issue.
  final String title;

  /// The body text of the issue.
  final String? body;

  /// The current state of the issue (e.g., 'open', 'closed').
  final String state;

  /// The labels associated with the issue.
  final List<String> labels;

  /// Creates a new [Issue] instance.
  Issue(
      {required this.number,
      required this.title,
      this.body,
      required this.state,
      required this.labels});

  /// Creates an [Issue] instance from a JSON map.
  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      number: json['number'],
      title: json['title'],
      body: json['body'],
      state: json['state'],
      labels: (json['labels'] as List?)
              ?.map((label) => label['name'] as String)
              .toList() ??
          [],
    );
  }
}

/// Represents a GitHub pull request.
class PullRequest {
  /// The pull request number.
  final int number;

  /// The title of the pull request.
  final String title;

  /// The body text of the pull request.
  final String? body;

  /// The current state of the pull request (e.g., 'open', 'closed').
  final String state;

  /// The name of the head branch.
  final String head;

  /// The name of the base branch.
  final String base;

  /// Creates a new [PullRequest] instance.
  PullRequest(
      {required this.number,
      required this.title,
      this.body,
      required this.state,
      required this.head,
      required this.base});

  /// Creates a [PullRequest] instance from a JSON map.
  factory PullRequest.fromJson(Map<String, dynamic> json) {
    return PullRequest(
      number: json['number'],
      title: json['title'],
      body: json['body'],
      state: json['state'],
      head: json['head']['ref'] ?? '',
      base: json['base']['ref'] ?? '',
    );
  }
}

/// Represents a GitHub Actions workflow.
class Workflow {
  /// The unique identifier of the workflow.
  final int id;

  /// The name of the workflow.
  final String name;

  /// The path to the workflow file in the repository.
  final String? path;

  /// The current state of the workflow.
  final String state;

  /// Creates a new [Workflow] instance.
  Workflow(
      {required this.id, required this.name, this.path, required this.state});

  /// Creates a [Workflow] instance from a JSON map.
  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      state: json['state'],
    );
  }
}

/// Represents a GitHub Actions workflow run.
class WorkflowRun {
  /// The unique identifier of the workflow run.
  final int id;

  /// The current status of the workflow run.
  final String status;

  /// The conclusion of the workflow run, if completed.
  final String? conclusion;

  /// The SHA of the head commit that triggered the workflow run.
  final String headSha;

  /// Creates a new [WorkflowRun] instance.
  WorkflowRun(
      {required this.id,
      required this.status,
      this.conclusion,
      required this.headSha});

  /// Creates a [WorkflowRun] instance from a JSON map.
  factory WorkflowRun.fromJson(Map<String, dynamic> json) {
    return WorkflowRun(
      id: json['id'],
      status: json['status'],
      conclusion: json['conclusion'],
      headSha: json['head_sha'],
    );
  }
}

/// Represents a GitHub code scanning alert.
class CodeScanningAlert {
  /// The number of the alert.
  final int number;

  /// The current state of the alert.
  final String state;

  /// The identifier of the rule that triggered the alert.
  final String ruleId;

  /// The severity level of the alert.
  final String severity;

  /// Creates a new [CodeScanningAlert] instance.
  CodeScanningAlert(
      {required this.number,
      required this.state,
      required this.ruleId,
      required this.severity});

  /// Creates a [CodeScanningAlert] instance from a JSON map.
  factory CodeScanningAlert.fromJson(Map<String, dynamic> json) {
    return CodeScanningAlert(
      number: json['number'],
      state: json['state'],
      ruleId: json['rule']['id'],
      severity: json['rule']['severity'],
    );
  }
}

/// Represents a GitHub secret scanning alert.
class SecretScanningAlert {
  /// The number of the alert.
  final int number;

  /// The current state of the alert.
  final String state;

  /// The type of secret that was detected.
  final String secretType;

  /// The resolution status of the alert, if any.
  final String? resolution;

  /// Creates a new [SecretScanningAlert] instance.
  SecretScanningAlert(
      {required this.number,
      required this.state,
      required this.secretType,
      this.resolution});

  /// Creates a [SecretScanningAlert] instance from a JSON map.
  factory SecretScanningAlert.fromJson(Map<String, dynamic> json) {
    return SecretScanningAlert(
      number: json['number'],
      state: json['state'],
      secretType: json['secret_type'],
      resolution: json['resolution'],
    );
  }
}

/// Represents the rate limit information for GitHub API requests.
class RateLimit {
  /// The maximum number of requests you're permitted to make per hour.
  final int limit;

  /// The number of requests remaining in the current rate limit window.
  final int remaining;

  /// The time at which the current rate limit window resets.
  final DateTime reset;

  /// Creates a new [RateLimit] instance.
  ///
  /// [limit] is the maximum number of requests permitted per hour.
  /// [remaining] is the number of requests remaining in the current window.
  /// [reset] is the time when the current rate limit window resets.
  RateLimit(
      {required this.limit, required this.remaining, required this.reset});

  /// Creates a [RateLimit] instance from HTTP response headers.
  ///
  /// This factory constructor parses the rate limit information from
  /// the 'x-ratelimit-*' headers in the GitHub API response.
  ///
  /// [headers] is a map of HTTP response headers.
  factory RateLimit.fromHeaders(Map<String, String> headers) {
    return RateLimit(
      limit: int.parse(headers['x-ratelimit-limit'] ?? '0'),
      remaining: int.parse(headers['x-ratelimit-remaining'] ?? '0'),
      reset: DateTime.fromMillisecondsSinceEpoch(
          int.parse(headers['x-ratelimit-reset'] ?? '0') * 1000),
    );
  }

  /// Indicates whether the rate limit has been exceeded.
  ///
  /// Returns `true` if there are no remaining requests, `false` otherwise.
  bool get isExceeded => remaining == 0;

  /// Calculates the duration until the rate limit resets.
  ///
  /// Returns a [Duration] representing the time left until the reset.
  /// This duration will be negative if the reset time has already passed.
  Duration get timeUntilReset => reset.difference(DateTime.now());
}
