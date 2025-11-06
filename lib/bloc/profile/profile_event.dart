import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {
  const ProfileLoadEvent();
}

class ProfileUpdateDisplayNameEvent extends ProfileEvent {
  final String displayName;

  const ProfileUpdateDisplayNameEvent(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

class ProfileUpdatePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ProfileUpdatePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ProfileUpdatePhoneNumberEvent extends ProfileEvent {
  final String phoneNumber;

  const ProfileUpdatePhoneNumberEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

