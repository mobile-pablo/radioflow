part of 'recents_cubit.dart';

final class RecentsState extends Equatable {
  const RecentsState({this.recents = const []});

  final List<Station> recents;

  @override
  List<Object?> get props => [recents];
}
