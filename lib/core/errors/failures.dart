abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'An unexpected server error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to read or write local storage cache.']);
}