import 'package:github_kit/github_kit.dart';

void main() async {
  final gitHubKit = GitHubKit(token: 'your_github_token');

  try {
    // Repository operations
    final repo = await gitHubKit.repositories.getRepository('octocat', 'Hello-World');
    print('Repository: ${repo.fullName}');

    // Issue operations
    final issue = await gitHubKit.issues.createIssue('octocat', 'Hello-World', 'Test issue');
    print('Created issue #${issue.number}');

    // Pull Request operations
    final prs = await gitHubKit.pullRequests.listPullRequests('octocat', 'Hello-World', state: 'open');
    print('Open PRs: ${prs.length}');

    // Workflow operations
    final workflows = await gitHubKit.actions.listWorkflows('octocat', 'Hello-World');
    print('Workflows: ${workflows.length}');

    // Code Scanning operations
    final codeAlerts = await gitHubKit.codeScanning.listCodeScanningAlerts('octocat', 'Hello-World');
    print('Code Scanning Alerts: ${codeAlerts.length}');

    // Secret Scanning operations
    final secretAlerts = await gitHubKit.secretScanning.listSecretScanningAlerts('octocat', 'Hello-World');
    print('Secret Scanning Alerts: ${secretAlerts.length}');

    // GraphQL query
    final repoInfo = await gitHubKit.graphql('''
      query {
        repository(owner: "octocat", name: "Hello-World") {
          stargazerCount
        }
      }
    ''');
    print('Stars: ${repoInfo['repository']['stargazerCount']}');

  } catch (e) {
    print('Error: $e');
  } finally {
    gitHubKit.dispose();
  }
}