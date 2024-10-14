import 'package:github_kit/github_kit.dart';

void main() async {
  final gitHubKit = GitHubKit(token: 'your_github_token');

  try {
    // List workflow runs
    final runs = await gitHubKit.actions.listWorkflowRuns('octocat', 'Hello-World');
    print('Recent workflow runs:');
    for (var run in runs) {
      print('- ${run['id']}: ${run['status']}');
    }

    // List packages for an organization
    final packages = await gitHubKit.packages.listPackagesForOrg('github');
    print('\nPackages in the github organization:');
    for (var package in packages) {
      print('- ${package['name']}');
    }

    // Create a webhook
    final webhook = await gitHubKit.webhooks.createWebhook(
      'octocat',
      'Hello-World',
      'https://example.com/webhook',
      events: ['push', 'pull_request'],
    );
    print('\nCreated webhook: ${webhook['id']}');

    // Execute a GraphQL query
    final result = await gitHubKit.graphql('''
      query {
        viewer {
          login
          repositories(first: 5) {
            nodes {
              name
              stargazerCount
            }
          }
        }
      }
    ''');
    print('\nGraphQL query result:');
    print('Logged in as: ${result['viewer']['login']}');
    print('Top 5 repositories:');
    for (var repo in result['viewer']['repositories']['nodes']) {
      print('- ${repo['name']}: ${repo['stargazerCount']} stars');
    }

  } catch (e) {
    if (e is GitHubException) {
      print('GitHub API Error: ${e.message} (Status: ${e.statusCode})');
    } else {
      print('Error: $e');
    }
  }
}