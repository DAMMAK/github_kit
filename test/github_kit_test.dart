
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import '../lib/github_kit.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('GitHubKit', () {
    late GitHubKit gitHubKit;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      gitHubKit = GitHubKit(token: 'test_token');
    });

    // ... (previous tests remain)

    test('listWorkflowRuns returns list of workflow runs', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"workflow_runs": [{"id": 1}, {"id": 2}]}', 200, headers: {
        'x-ratelimit-limit': '5000',
        'x-ratelimit-remaining': '4999',
        'x-ratelimit-reset': '1372700873',
      }));

      final runs = await gitHubKit.actions.listWorkflowRuns('octocat', 'Hello-World');
      expect(runs, hasLength(2));
      expect(runs[0]['id'], equals(1));
      expect(runs[1]['id'], equals(2));
    });

    test('listPackagesForOrg returns list of packages', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('[{"name": "package1"}, {"name": "package2"}]', 200, headers: {
        'x-ratelimit-limit': '5000',
        'x-ratelimit-remaining': '4999',
        'x-ratelimit-reset': '1372700873',
      }));

      final packages = await gitHubKit.packages.listPackagesForOrg('github');
      expect(packages, hasLength(2));
      expect(packages[0]['name'], equals('package1'));
      expect(packages[1]['name'], equals('package2'));
    });

    test('createWebhook creates a new webhook', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"id": 1, "url": "https://api.github.com/repos/octocat/Hello-World/hooks/1"}', 201, headers: {
        'x-ratelimit-limit': '5000',
        'x-ratelimit-remaining': '4999',
        'x-ratelimit-reset': '1372700873',
      }));

      final webhook = await gitHubKit.webhooks.createWebhook('octocat', 'Hello-World', 'https://example.com/webhook');
      expect(webhook['id'], equals(1));
      expect(webhook['url'], equals('https://api.github.com/repos/octocat/Hello-World/hooks/1'));
    });

    test('graphql executes a GraphQL query', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"data": {"viewer": {"login": "octocat"}}}', 200, headers: {
        'x-ratelimit-limit': '5000',
        'x-ratelimit-remaining': '4999',
        'x-ratelimit-reset': '1372700873',
      }));

      final result = await gitHubKit.graphql('''
        query {
          viewer {
            login
          }
        }
      ''');
      expect(result['viewer']['login'], equals('octocat'));
    });
  });
}
