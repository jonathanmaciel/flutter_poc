import 'package:equatable/equatable.dart';

abstract class State extends Equatable {

  const State();

  @override
  List<Object> get props => [];
}

abstract class StateListener<T extends State> extends State {

  T get state;

  bool isEmited(Type type);
}
