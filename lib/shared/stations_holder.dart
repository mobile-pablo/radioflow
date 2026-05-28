import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

class StationsHolder {
  List<Station> stations = const [];
  final ValueNotifier<int> circleCount = ValueNotifier(0);
}
