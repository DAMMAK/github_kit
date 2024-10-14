# GitHubKit

A comprehensive Dart package for interacting with the GitHub API, including REST and GraphQL support.

## Features

- Authentication with personal access tokens and OAuth
- Repository management
- Issue tracking
- Pull request handling
- User information
- Gist operations
- Team management
- Organization management
- Project management
- GitHub Actions integration
- Package management
- Webhook management
- GraphQL API support
- Pagination support
- Rate limiting information and automatic retrying
- Logging and debugging features

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  github_kit: ^1.0.0
```

## Usage

### Authentication

#### Personal Access Token

```dart
final gitHubKit = GitHubKit(token: 'your_personal_access_token');
```

#### OAuth

```dart
final gitHubKit = GitHubKit();
await gitHubKit.authenticateWithOAuth(
  'your_client_id',
  'your_client_secret',
  ['repo', 'user'],
);
```

### REST API Examples

#### Repository Operations

```dart
// Get repository information
final repo = await gitHubKit.repositories.getRepository('octocat', 'Hello-World');
print('Repository: ${repo['name']}');

// List repositories for a user
final repos = await gitHubKit.repositories.listRepositories('octocat');
for (var repo in repos) {
  print('Repo: ${repo['name']}');
}
```

#### Issue Management

```dart
// Create an issue
final newIssue = await gitHubKit.issues.createIssue(
  'octocat',
  'Hello-World',
  'Test issue',
  body: 'This is a test issue created by GitHubKit',
);
print('Created issue: ${newIssue['number']}');

// List issues for a repository
final issues = await gitHubKit.issues.listIssues('octocat', 'Hello-World');
for (var issue in issues) {
  print('Issue #${issue['number']}: ${issue['title']}');
}
```

#### Pull Requests

```dart
// Create a pull request
final newPR = await gitHubKit.pullRequests.createPullRequest(
  'octocat',
  'Hello-World',
  'New feature',
  'feature-branch',
  'main',
  body: 'This PR adds a new feature',
);
print('Created PR: ${newPR['number']}');

// List pull requests
final prs = await gitHubKit.pullRequests.listPullRequests('octocat', 'Hello-World');
for (var pr in prs) {
  print('PR #${pr['number']}: ${pr['title']}');
}
```

#### GitHub Actions

```dart
// List workflow runs
final runs = await gitHubKit.actions.listWorkflowRuns('octocat', 'Hello-World');
for (var run in runs) {
  print('Workflow run #${run['id']}: ${run['status']}');
}

// Re-run a workflow
await gitHubKit.actions.reRunWorkflow('octocat', 'Hello-World', 12345);
```

#### Package Management

```dart
// List packages for an organization
final packages = await gitHubKit.packages.listPackagesForOrg('github');
for (var package in packages) {
  print('Package: ${package['name']}');
}
```

#### Webhook Management

```dart
// Create a webhook
final webhook = await gitHubKit.webhooks.createWebhook(
  'octocat',
  'Hello-World',
  'https://example.com/webhook',
  events: ['push', 'pull_request'],
);
print('Created webhook: ${webhook['id']}');

// List webhooks
final webhooks = await gitHubKit.webhooks.listRepoWebhooks('octocat', 'Hello-World');
for (var hook in webhooks) {
  print('Webhook #${hook['id']}: ${hook['config']['url']}');
}
```

### GraphQL API Usage

```dart
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

print('Logged in as: ${result['viewer']['login']}');
print('Top 5 repositories:');
for (var repo in result['viewer']['repositories']['nodes']) {
  print('- ${repo['name']}: ${repo['stargazerCount']} stars');
}
```

### Pagination

Most list methods support pagination. You can use the `perPage` and `page` parameters to control the results:

```dart
final repos = await gitHubKit.repositories.listRepositories('octocat', perPage: 10, page: 2);
```

For convenience, you can use the `paginateAll` helper to fetch all pages automatically:

```dart
final allRepos = await gitHubKit.repositories.listAllRepositories('octocat');
```

### Rate Limiting

GitHubKit automatically handles rate limiting information and provides it in the response:

```dart
final response = await gitHubKit.repositories.getRepository('octocat', 'Hello-World');
print('Rate limit remaining: ${response.rateLimit.remaining}');
print('Rate limit resets at: ${response.rateLimit.reset}');
```

The package will automatically retry requests if the rate limit is exceeded, up to a configurable number of times:

```dart
final gitHubKit = GitHubKit(
  token: 'your_token',
  maxRetries: 5,
  retryDelay: Duration(seconds: 10),
);
```

### Logging

GitHubKit uses the `logging` package for debug information. You can configure logging levels and listen to log messages:

```dart
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Your GitHubKit code here
}
```

## Error Handling

GitHubKit throws `GitHubException` for API-related errors. You can catch and handle these exceptions:

```dart
try {
  // Your GitHubKit code here
} catch (e) {
  if (e is GitHubException) {
    print('GitHub API Error: ${e.message} (Status: ${e.statusCode})');
  } else {
    print('Error: $e');
  }
}
```

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for more information.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.