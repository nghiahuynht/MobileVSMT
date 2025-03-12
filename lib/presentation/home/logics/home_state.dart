// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.counter = 0,
  });

  final int counter;

  @override
  List<Object> get props => [counter];

  HomeState copyWith({
    int? counter,
  }) {
    return HomeState(
      counter: counter ?? this.counter,
    );
  }
}
