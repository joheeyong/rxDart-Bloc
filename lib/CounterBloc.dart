import 'package:rxdart/rxdart.dart';

class CounterBloc {
  final _counter = BehaviorSubject<int>.seeded(0);

  Stream<int> get counterStream => _counter.stream;
  void increment() => _counter.add(_counter.value + 1);
  void dispose() => _counter.close();
}
