import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:github_kit/github_kit.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner('github_kit', 'CLI for GitHubKit')
    ..addCommand(GetRepoCommand())
    ..addCommand(ListIssuesCommand())
  ..addCommand(CreateRepoCommand())
  ..addCommand(DeleteRepoCommand())
  ;

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

class GetRepoCommand extends Command {
  @override
  final name = 'get-repo';
  @override
  final description = 'Get repository information';

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
      // print('Stars: ${repo.stargazersCount}');
    } catch (e) {
      print('Error: $e');
    } finally {
      gitHubKit.dispose();
    }
  }
}

class CreateRepoCommand extends Command {
  @override
  final name = 'create-repo';
  @override
  final description = 'Create repository information';

  CreateRepoCommand() {
    argParser
      ..addOption('name', abbr: 'n', help: 'Repository name')
      ..addOption('private', abbr: 'p', help: 'Repository private status')
      ..addOption('description', abbr: 'd', help: 'Repository description')
      ..addOption('token', abbr: 't', help: 'GitHub token');
  }

  @override
  Future<void> run() async {
    final private = argResults?['private']== null ? false : (argResults?['private'] as String).parseBool();
    final description = argResults?['description'];
    final name = argResults?['name'];
    final token = argResults?['token'];

    if (name == null || token == null) {
      print('Please provide owner, name, and token');
      exit(1);
    }

    final gitHubKit = GitHubKit(token: token);
    try {
      final repo = await gitHubKit.repositories.createRepository(name, private: private, description: description);
      print('Repository: ${repo.fullName}');
      print('Description: ${repo.description}');
      // print('Stars: ${repo.stargazersCount}');
    } catch (e) {
      print('Error: $e');
    } finally {
      gitHubKit.dispose();
    }
  }
}
class DeleteRepoCommand extends Command {
  @override
  final name = 'delete-repo';
  @override
  final description = 'Delete repository information';

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
       await gitHubKit.repositories.deleteRepository(owner,name);
      print('Repository Deleted');
    } catch (e) {
      print('Error: $e');
    } finally {
      gitHubKit.dispose();
    }
  }
}


class ListIssuesCommand extends Command {
  @override
  final name = 'list-issues';
  @override
  final description = 'List issues for a repository';

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




extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == 'true';
  }
}