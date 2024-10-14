typedef SendRequestFunction = Future<dynamic> Function(String method, String path, {Map<String, dynamic>? body, Map<String, String>? queryParams});



class Repository {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final bool private;

  Repository({required this.id, required this.name, required this.fullName, this.description, required this.private});

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

class Issue {
  final int number;
  final String title;
  final String? body;
  final String state;
  final List<String> labels;

  Issue({required this.number, required this.title, this.body, required this.state, required this.labels});

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      number: json['number'],
      title: json['title'],
      body: json['body'],
      state: json['state'],
      labels: (json['labels'] as List?)?.map((label) => label['name'] as String).toList() ?? [],
    );
  }
}

class PullRequest {
  final int number;
  final String title;
  final String? body;
  final String state;
  final String head;
  final String base;

  PullRequest({required this.number, required this.title, this.body, required this.state, required this.head, required this.base});

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
class Workflow {
  final int id;
  final String name;
  final String? path;
  final String state;

  Workflow({required this.id, required this.name, this.path, required this.state});

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      state: json['state'],
    );
  }
}
class WorkflowRun {
  final int id;
  final String status;
  final String? conclusion;
  final String headSha;

  WorkflowRun({required this.id, required this.status, this.conclusion, required this.headSha});

  factory WorkflowRun.fromJson(Map<String, dynamic> json) {
    return WorkflowRun(
      id: json['id'],
      status: json['status'],
      conclusion: json['conclusion'],
      headSha: json['head_sha'],
    );
  }
}

class CodeScanningAlert {
  final int number;
  final String state;
  final String ruleId;
  final String severity;

  CodeScanningAlert({required this.number, required this.state, required this.ruleId, required this.severity});

  factory CodeScanningAlert.fromJson(Map<String, dynamic> json) {
    return CodeScanningAlert(
      number: json['number'],
      state: json['state'],
      ruleId: json['rule']['id'],
      severity: json['rule']['severity'],
    );
  }
}

class SecretScanningAlert {
  final int number;
  final String state;
  final String secretType;
  final String? resolution;

  SecretScanningAlert({required this.number, required this.state, required this.secretType, this.resolution});

  factory SecretScanningAlert.fromJson(Map<String, dynamic> json) {
    return SecretScanningAlert(
      number: json['number'],
      state: json['state'],
      secretType: json['secret_type'],
      resolution: json['resolution'],
    );
  }
}