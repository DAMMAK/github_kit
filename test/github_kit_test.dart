
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:github_kit/github_kit.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql/language.dart';



// Generate a Mock class for http.Client
@GenerateMocks([http.Client])
import 'github_kit_test.mocks.dart';
class MockLink extends Mock implements Link {}

void main() {
  late GitHubKit gitHubKit;
  late MockClient mockClient;
  late MockLink mockLink;

  setUp(() {
    mockClient = MockClient();
    mockLink = MockLink();
    gitHubKit = GitHubKit(token: 'test_token', client: mockClient,graphQLLink: mockLink);

    // // Mock the GraphQL link to return an empty result
    // when(mockLink.request(any)).thenAnswer((_) => Stream.fromIterable([
    //   Response(data: {}, response: {})
    // ]));

  });

  group('RepositoriesApi', () {
    test('getRepository returns a repository', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"id": 1, "name": "Hello-World", "full_name": "octocat/Hello-World", "private": false}', 200));

      final repo = await gitHubKit.repositories.getRepository('octocat', 'Hello-World');

      expect(repo.id, equals(1));
      expect(repo.name, equals('Hello-World'));
      expect(repo.fullName, equals('octocat/Hello-World'));
      expect(repo.private, isFalse);
    });

    test('createRepository creates a new repository', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"id": 1, "name": "New-Repo", "full_name": "octocat/New-Repo", "private": true}', 201));

      final repo = await gitHubKit.repositories.createRepository('New-Repo', private: true);

      expect(repo.id, equals(1));
      expect(repo.name, equals('New-Repo'));
      expect(repo.fullName, equals('octocat/New-Repo'));
      expect(repo.private, isTrue);
    });

    // Add more tests for RepositoriesApi
  });

  group('IssuesApi', () {
    test('createIssue creates a new issue', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"number": 1, "title": "Test Issue", "state": "open", "labels": []}', 201));

      final issue = await gitHubKit.issues.createIssue('octocat', 'Hello-World', 'Test Issue');

      expect(issue.number, equals(1));
      expect(issue.title, equals('Test Issue'));
      expect(issue.state, equals('open'));
    });

    test('getIssue returns an issue', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"number": 1, "title": "Test Issue", "state": "open"}', 200));

      final issue = await gitHubKit.issues.getIssue('octocat', 'Hello-World', 1);

      expect(issue.number, equals(1));
      expect(issue.title, equals('Test Issue'));
      expect(issue.state, equals('open'));
    });

    // Add more tests for IssuesApi
  });

  group('PullRequestsApi', () {
    test('createPullRequest creates a new pull request', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"number": 1, "title": "New feature", "state": "open", "head": {"ref": "feature-branch"}, "base": {"ref": "main"}}', 201));

      final pr = await gitHubKit.pullRequests.createPullRequest('octocat', 'Hello-World', 'New feature', 'feature-branch', 'main');

      expect(pr.number, equals(1));
      expect(pr.title, equals('New feature'));
      expect(pr.state, equals('open'));
      expect(pr.head, equals('feature-branch'));
      expect(pr.base, equals('main'));
    });


    // Add more tests for PullRequestsApi
  });

  group('ActionsApi', () {
    test('listWorkflows returns a list of workflows', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"workflows": [{"id": 1, "name": "CI", "state": "active"}]}', 200));

      final workflows = await gitHubKit.actions.listWorkflows('octocat', 'Hello-World');

      expect(workflows, hasLength(1));
      expect(workflows[0].id, equals(1));
      expect(workflows[0].name, equals('CI'));
      expect(workflows[0].state, equals('active'));
    });

    // Add more tests for ActionsApi
  });

  group('CodeScanningApi', () {
    test('listCodeScanningAlerts returns a list of alerts', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('[{"number": 1, "state": "open", "rule": {"id": "js/xss", "severity": "warning"}}]', 200));

      final alerts = await gitHubKit.codeScanning.listCodeScanningAlerts('octocat', 'Hello-World');

      expect(alerts, hasLength(1));
      expect(alerts[0].number, equals(1));
      expect(alerts[0].state, equals('open'));
      expect(alerts[0].ruleId, equals('js/xss'));
      expect(alerts[0].severity, equals('warning'));
    });

    // Add more tests for CodeScanningApi
  });

  group('SecretScanningApi', () {
    test('listSecretScanningAlerts returns a list of alerts', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('[{"number": 1, "state": "open", "secret_type": "github_token"}]', 200));

      final alerts = await gitHubKit.secretScanning.listSecretScanningAlerts('octocat', 'Hello-World');

      expect(alerts, hasLength(1));
      expect(alerts[0].number, equals(1));
      expect(alerts[0].state, equals('open'));
      expect(alerts[0].secretType, equals('github_token'));
    });

    // Add more tests for SecretScanningApi
  });

  // TODO: Implement proper mocking for GraphQL requests

  // group('GraphQL API', () {
  //   test('graphql executes a GraphQL query', () async {
  //     final mockResponse = Response(
  //       data: {'viewer': {'login': 'octocat'}},
  //       response: {'data': {'viewer': {'login': 'octocat'}}},
  //     );
  //
  //     when(mockLink.request(any)).thenAnswer((_) => Stream.fromIterable([mockResponse]));
  //
  //     final result = await gitHubKit.graphql('''
  //     query {
  //       viewer {
  //         login
  //       }
  //     }
  //   ''');
  //
  //     expect(result['viewer']['login'], equals('octocat'));
  //   });
  // });

  group('Error Handling', () {
    test('throws GitHubException on API error', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"message": "Not Found"}', 404));

      expect(
            () => gitHubKit.repositories.getRepository('octocat', 'Non-Existent-Repo'),
        throwsA(
          allOf(
            isA<GitHubException>(),
            predicate((e) => (e as GitHubException).statusCode == 404),
            predicate((e) => (e as GitHubException).message.contains('Not Found')),
          ),
        ),
      );
    });
  });

  group('Rate Limiting', () {
    test('retries on rate limit exceeded', () async {
      var callCount = 0;
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async {
        callCount++;
        if (callCount < 3) {
          return http.Response('{"message": "API rate limit exceeded"}', 403, headers: {'Retry-After': '1'});
        } else {
          return http.Response('{"id": 1, "name": "Hello-World", "full_name": "octocat/Hello-World", "private": false}', 200);
        }
      });

      final repo = await gitHubKit.repositories.getRepository('octocat', 'Hello-World');

      expect(callCount, equals(3));
      expect(repo.id, equals(1));
      expect(repo.name, equals('Hello-World'));
    });
  });
}