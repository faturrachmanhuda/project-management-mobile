import 'package:flutter/foundation.dart';

/// Simple CounterViewModel used for teaching Provider/ChangeNotifier.
class CounterViewModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}
