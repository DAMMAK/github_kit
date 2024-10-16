# GitHubKit API Overview

GitHubKit provides a comprehensive set of APIs to interact with GitHub. Here's an overview of the main components:

## Repositories API

The `RepositoriesApi` class provides methods to interact with GitHub repositories:

- `getRepository`: Fetch details of a specific repository
- `createRepository`: Create a new repository
- `listRepositories`: List repositories for a user
- `deleteRepository`: Delete a repository

## Issues API

The `IssuesApi` class allows you to manage issues:

- `createIssue`: Create a new issue
- `getIssue`: Fetch details of a specific issue
- `listIssues`: List issues for a repository
- `updateIssue`: Update an existing issue

## Pull Requests API

The `PullRequestsApi` class provides methods to work with pull requests:

- `createPullRequest`: Create a new pull request
- `getPullRequest`: Fetch details of a specific pull request
- `listPullRequests`: List pull requests for a repository
- `updatePullRequest`: Update an existing pull request
- `mergePullRequest`: Merge a pull request

## Actions API

The `ActionsApi` class allows you to interact with GitHub Actions:

- `listWorkflows`: List workflows for a repository
- `createWorkflowDispatch`: Trigger a workflow run
- `getWorkflowRun`: Fetch details of a specific workflow run
- `cancelWorkflowRun`: Cancel a workflow run
- `rerunWorkflowRun`: Re-run a workflow

## Code Scanning API

The `CodeScanningApi` class provides methods to work with code scanning alerts:

- `listCodeScanningAlerts`: List code scanning alerts for a repository
- `getCodeScanningAlert`: Fetch details of a specific code scanning alert
- `updateCodeScanningAlert`: Update a code scanning alert

## Secret Scanning API

The `SecretScanningApi` class allows you to manage secret scanning alerts:

- `listSecretScanningAlerts`: List secret scanning alerts for a repository
- `getSecretScanningAlert`: Fetch details of a specific secret scanning alert
- `updateSecretScanningAlert`: Update a secret scanning alert

## GraphQL API

GitHubKit also supports GitHub's GraphQL API. You can make custom GraphQL queries using the `graphql` method of the `GitHubKit` class.

For detailed usage of each API, please refer to the specific documentation files.