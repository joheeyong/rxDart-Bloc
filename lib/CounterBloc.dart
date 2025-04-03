import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// 이벤트 정의
abstract class CounterEvent {}

class IncrementEvent extends CounterEvent {}

class DecrementEvent extends CounterEvent {}

// Bloc 클래스
class CounterBloc extends Bloc<CounterEvent, int> {
  final _counterSubject = BehaviorSubject<int>.seeded(0);

  CounterBloc() : super(0) {
    on<IncrementEvent>((event, emit) {
      _counterSubject.add(_counterSubject.value + 1);
      emit(_counterSubject.value);
    });

    on<DecrementEvent>((event, emit) {
      _counterSubject.add(_counterSubject.value - 1);
      emit(_counterSubject.value);
    });
  }

  @override
  Future<void> close() {
    _counterSubject.close();
    return super.close();
  }
}
