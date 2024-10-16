import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:github_kit/github_kit.dart';

/// The main entry point for the GitHubKit CLI application.
///
/// This function sets up the command runner and handles exceptions.
void main(List<String> arguments) async {
  final runner = CommandRunner('github_kit', 'CLI for GitHubKit')
    ..addCommand(GetRepoCommand())
    ..addCommand(ListIssuesCommand())
    ..addCommand(CreateRepoCommand())
    ..addCommand(DeleteRepoCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e);
    exit(64);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

/// Command to get information about a GitHub repository.
class GetRepoCommand extends Command {
  @override
  final name = 'get-repo';
  @override
  final description = 'Get repository information';

  /// Constructor that sets up command-line arguments.
  GetRepoCommand() {
    argParser
      ..addOption('owner', abbr: 'o', help: 'Repository owner')
      ..addOption('name', abbr: 'n', help: 'Repository name')
      ..addOption('token', abbr: 't', help: 'GitHub token');
  }

  @override
  Future<void> run() async {
    final owner = argResults?['owner'];
    final name = argResults?['name'];
    final token = argResults?['token'];

    if (owner == null || name == null || token == null) {
      print('Please provide owner, name, and token');
      exit(1);
    }

    final gitHubKit = GitHubKit(token: token);
    try {
      final repo = await gitHubKit.repositories.getRepository(owner, name);
      print('Repository: ${repo.fullName}');
      print('Description: ${repo.description}');
    } catch (e) {
      print('Error: $e');
    } finally {
      gitHubKit.dispose();
    }
  }
}

/// Command to create a new GitHub repository.
class CreateRepoCommand extends Command {
  @override
  final name = 'create-repo';
  @override
  final description = 'Create repository information';

  /// Constructor that sets up command-line arguments.
  CreateRepoCommand() {
    argParser
      ..addOption('name', abbr: 'n', help: 'Repository name')
      ..addOption('private', abbr: 'p', help: 'Repository private status')
      ..addOption('description', abbr: 'd', help: 'Repository description')
      ..addOption('token', abbr: 't', help: 'GitHub token');
  }

  @override
  Future<void> run() async {
    final private = argResults?['private'] == null
        ? false
        : (argResults?['private'] as String).parseBool();
    final description = argResults?['description'];
    final name = argResults?['name'];
    final token = argResults?['token'];

    if (name == null || token == null) {
      print('Please provide owner, name, and token');
      exit(1);
    }

    final gitHubKit = GitHubKit(token: token);
    try {
      final repo = await gitHubKit.repositories
          .createRepository(name, private: private, description: description);
      print('Repository: ${repo.fullName}');
      print('Description: ${repo.description}');
    } catch (e) {
      print('Error: $e');
    } finally {
      gitHubKit.dispose();
    }
  }
}

/// Command to delete a GitHub repository.
class DeleteRepoCommand extends Command {
  @override
  final name = 'delete-repo';
  @override
  final description = 'Delete repository information';

  /// Constructor that sets up command-line arguments.
  DeleteRepoCommand() {
    argParser
      ..addOption('owner', abbr: 'o', help: 'Repository owner')
      ..addOption('name', abbr: 'n', help: 'Repository name')
      ..addOption('token', abbr: 't', help: 'GitHub token');
  }

  @override
  Future<void> run() async {
    final owner = argResults?['owner'];
    final name = argResults?['name'];
    final token = argResults?['token'];

    if (owner == null || name == null || token == null) {
      print('Please provide owner, name, and token');
      exit(1);
    }

    final gitHubKit = GitHubKit(token: token);
    try {
      await gitHubKit.repositories.deleteRepository(owner, name);
      print('Repository Deleted');
    } catch (e) {
      print('Error: $e');
    } finally {
      gitHubKit.dispose();
    }
  }
}

/// Command to list issues for a GitHub repository.
class ListIssuesCommand extends Command {
  @override
  final name = 'list-issues';
  @override
  final description = 'List issues for a repository';

  /// Constructor that sets up command-line arguments.
  ListIssuesCommand() {
    argParser
      ..addOption('owner', abbr: 'o', help: 'Repository owner')
      ..addOption('name', abbr: 'n', help: 'Repository name')
      ..addOption('token', abbr: 't', help: 'GitHub token');
  }

  @override
  Future<void> run() async {
    final owner = argResults?['owner'];
    final name = argResults?['name'];
    final token = argResults?['token'];

    if (owner == null || name == null || token == null) {
      print('Please provide owner, name, and token');
      exit(1);
    }

    final gitHubKit = GitHubKit(token: token);
    try {
      final issues = await gitHubKit.issues.listIssues(owner, name);
      for (var issue in issues) {
        print('#${issue.number} - ${issue.title}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      gitHubKit.dispose();
    }
  }
}

/// Extension on [String] to parse boolean values.
extension BoolParsing on String {
  /// Parses a string to a boolean value.
  ///
  /// Returns `true` if the lowercase string is "true", otherwise `false`.
  bool parseBool() {
    return toLowerCase() == 'true';
  }
}
