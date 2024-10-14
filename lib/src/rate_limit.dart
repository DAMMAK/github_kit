class RateLimit {
  final int limit;
  final int remaining;
  final DateTime reset;

  RateLimit({required this.limit, required this.remaining, required this.reset});

  factory RateLimit.fromHeaders(Map<String, String> headers) {
    return RateLimit(
      limit: int.parse(headers['x-ratelimit-limit'] ?? '0'),
      remaining: int.parse(headers['x-ratelimit-remaining'] ?? '0'),
      reset: DateTime.fromMillisecondsSinceEpoch(int.parse(headers['x-ratelimit-reset'] ?? '0') * 1000),
    );
  }

  bool get isExceeded => remaining == 0;

  Duration get timeUntilReset => reset.difference(DateTime.now());
}