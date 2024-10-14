# Changelog

All notable changes to the GitHubKit package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GraphQL support for executing custom queries
- Automatic retrying for rate-limited requests
- Logging and debugging features

### Changed
- Improved error handling with custom GitHubException class

## [1.0.0] - 2023-10-13

### Added
- Initial release of GitHubKit
- Support for major GitHub API endpoints:
    - Repositories
    - Issues
    - Pull Requests
    - Users
    - Gists
    - Teams
    - Organizations
    - Projects
    - Actions
    - Packages
    - Webhooks
- Authentication support for Personal Access Tokens and OAuth
- Pagination support for list operations
- Rate limiting information in responses

[Unreleased]: https://github.com/yourusername/github-kit/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/github-kit/releases/tag/v1.0.0