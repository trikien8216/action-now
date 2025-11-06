import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadEvent extends HomeEvent {
  const HomeLoadEvent();
}

class SubmitLogoutEvent extends HomeEvent {
  const SubmitLogoutEvent();
}

class HomeRefreshEvent extends HomeEvent {
  const HomeRefreshEvent();
}

