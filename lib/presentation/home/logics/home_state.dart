abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {}

class HomeFailure extends HomeState {
  final String message;
  HomeFailure(this.message);
}
