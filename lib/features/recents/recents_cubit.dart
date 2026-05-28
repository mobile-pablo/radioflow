import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'recents_state.dart';

class RecentsCubit extends Cubit<RecentsState> {
  RecentsCubit(this._repository) : super(const RecentsState());

  final RecentsRepository _repository;

  Future<void> load() async {
    final recents = await _repository.getRecents();
    emit(RecentsState(recents: recents));
  }

  Future<void> push(Station station) async {
    await _repository.add(station);
    await load();
  }

  Future<void> clear() async {
    await _repository.clear();
    emit(const RecentsState());
  }
}
