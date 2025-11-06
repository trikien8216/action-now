import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final String displayName;
  final bool isLoggedIn;

  const HomeLoaded({
    required this.displayName,
    required this.isLoggedIn,
  });

  @override
  List<Object?> get props => [displayName, isLoggedIn];

  HomeLoaded copyWith({
    String? displayName,
    bool? isLoggedIn,
  }) {
    return HomeLoaded(
      displayName: displayName ?? this.displayName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeLogoutLoading extends HomeState {
  const HomeLogoutLoading();
}

class HomeLogoutSuccess extends HomeState {
  const HomeLogoutSuccess();
}

class HomeLogoutError extends HomeState {
  final String message;

  const HomeLogoutError(this.message);

  @override
  List<Object?> get props => [message];
}

