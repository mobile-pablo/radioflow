import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivity) : super(true) {
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
    _connectivity.checkConnectivity().then(_update);
  }

  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  void _update(List<ConnectivityResult> results) {
    emit(results.any((result) => result != ConnectivityResult.none));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
