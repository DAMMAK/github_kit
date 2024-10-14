# GitHubKit

[![Pub Version](https://img.shields.io/pub/v/github_kit.svg)](https://pub.dev/packages/github_kit)
[![Build Status](https://travis-ci.org/yourusername/github_kit.svg?branch=master)](https://travis-ci.org/yourusername/github_kit)
[![Coverage Status](https://coveralls.io/repos/github/yourusername/github_kit/badge.svg?branch=master)](https://coveralls.io/github/yourusername/github_kit?branch=master)

GitHubKit is a comprehensive Dart package for interacting with the GitHub API. It provides an easy-to-use interface for common GitHub operations and supports advanced features like GitHub Actions, code scanning, and secret scanning.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Repositories](#repositories)
    - [Issues](#issues)
    - [Pull Requests](#pull-requests)
    - [GitHub Actions](#github-actions)
    - [Code Scanning](#code-scanning)
    - [Secret Scanning](#secret-scanning)
    - [GraphQL API](#graphql-api)
- [Error Handling](#error-handling)
- [Pagination](#pagination)
- [Rate Limiting](#rate-limiting)
- [Logging](#logging)
- [Testing](#testing)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Features

- Complete coverage of GitHub REST API v3
- Support for GitHub GraphQL API v4
- Repositories management
- Issues and Pull Requests handling
- GitHub Actions workflow management
- Code scanning and Secret scanning APIs
- Automatic pagination handling
- Built-in rate limit handling and automatic retries
- Comprehensive logging system
- Easy error handling with custom exceptions
- Full support for authentication (Personal Access Tokens)
- Extensive documentation and examples

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  github_kit: ^1.0.0
```

Then run:

```
$ dart pub get
```

## Usage

### Initialization

First, import the package and create an instance of `GitHubKit`:

```dart
import 'package:github_kit/github_kit.dart';

final gitHubKit = GitHubKit(token: 'your_personal_access_token');
```

### Repositories

```dart
// Get a repository
final repo = await gitHubKit.repositories.getRepository('octocat', 'Hello-World');
print('Repository: ${repo.fullName}');

// Create a repository
final newRepo = await gitHubKit.repositories.createRepository('New-Repo', private: true);
print('Created new repository: ${newRepo.fullName}');

// List repositories
final repos = await gitHubKit.repositories.listRepositories('octocat');
for (var repo in repos) {
  print('Repo: ${repo.name}');
}
```

### Issues

```dart
// Create an issue
final issue = await gitHubKit.issues.createIssue('octocat', 'Hello-World', 'Bug report', body: 'This is a bug report');
print('Created issue #${issue.number}');

// Get an issue
final fetchedIssue = await gitHubKit.issues.getIssue('octocat', 'Hello-World', 1);
print('Issue title: ${fetchedIssue.title}');

// List issues
final issues = await gitHubKit.issues.listIssues('octocat', 'Hello-World', state: 'open');
for (var issue in issues) {
  print('Issue #${issue.number}: ${issue.title}');
}
```

### Pull Requests

```dart
// Create a pull request
final pr = await gitHubKit.pullRequests.createPullRequest('octocat', 'Hello-World', 'New feature', 'feature-branch', 'main');
print('Created PR #${pr.number}');

// Get a pull request
final fetchedPR = await gitHubKit.pullRequests.getPullRequest('octocat', 'Hello-World', 1);
print('PR title: ${fetchedPR.title}');

// List pull requests
final prs = await gitHubKit.pullRequests.listPullRequests('octocat', 'Hello-World', state: 'open');
for (var pr in prs) {
  print('PR #${pr.number}: ${pr.title}');
}
```

### GitHub Actions

```dart
// List workflows
final workflows = await gitHubKit.actions.listWorkflows('octocat', 'Hello-World');
for (var workflow in workflows) {
  print('Workflow: ${workflow.name}');
}

// Create a workflow dispatch event
await gitHubKit.actions.createWorkflowDispatch('octocat', 'Hello-World', 'main.yml', 'main');
print('Workflow dispatch created');
```

### Code Scanning

```dart
// List code scanning alerts
final alerts = await gitHubKit.codeScanning.listCodeScanningAlerts('octocat', 'Hello-World');
for (var alert in alerts) {
  print('Alert #${alert.number}: ${alert.state}');
}
```

### Secret Scanning

```dart
// List secret scanning alerts
final secretAlerts = await gitHubKit.secretScanning.listSecretScanningAlerts('octocat', 'Hello-World');
for (var alert in secretAlerts) {
  print('Secret Alert #${alert.number}: ${alert.state}');
}
```

### GraphQL API

```dart
final result = await gitHubKit.graphql('''
  query {
    viewer {
      login
      repositories(first: 10) {
        nodes {
          name
          stargazerCount
        }
      }
    }
  }
''');
print('Logged in as: ${result['viewer']['login']}');
```

## Error Handling

GitHubKit uses custom exceptions for error handling. Always wrap your API calls in a try-catch block:

```dart
try {
  final repo = await gitHubKit.repositories.getRepository('octocat', 'Hello-World');
  print('Repository: ${repo.fullName}');
} catch (e) {
  if (e is GitHubException) {
    print('GitHub API Error: ${e.message} (Status: ${e.statusCode})');
  } else {
    print('Error: $e');
  }
}
```

## Pagination

Most list methods in GitHubKit handle pagination automatically. You can control pagination using the `perPage` and `page` parameters:

```dart
final repos = await gitHubKit.repositories.listRepositories('octocat', perPage: 100, page: 2);
```

## Rate Limiting

GitHubKit automatically handles rate limiting by retrying requests when limits are hit. You can configure retry behavior when creating the GitHubKit instance:

```dart
final gitHubKit = GitHubKit(
  token: 'your_token',
  maxRetries: 5,
  retryDelay: Duration(seconds: 10),
);
```

## Logging

GitHubKit includes a built-in logging system. You can configure logging when creating the GitHubKit instance:

```dart
final gitHubKit = GitHubKit(token: 'your_token');
gitHubKit.setLogLevel(LogLevel.debug);
```

## Testing

To run the tests for GitHubKit:

```
$ dart test
```

## Examples

For more examples, check the `example` folder in the repository.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for more information.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.