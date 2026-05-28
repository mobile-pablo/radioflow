import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Nothing found here yet.']);
}

final class PlaybackFailure extends Failure {
  const PlaybackFailure([super.message = 'This station is unavailable.']);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Could not save your changes.']);
}
