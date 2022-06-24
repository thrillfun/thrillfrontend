part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ValidationProcess extends ProfileState {}

class ValidationStatus extends ProfileState {
  final String message;
  final bool status;

  const ValidationStatus({required this.message, required this.status});

  @override
  List<Object> get props => [message, status];

}

class ProfileLoaded extends ProfileState {
  UserModel userModel;
  String message;
  bool status;

  ProfileLoaded({required this.userModel,required this.status, required this.message});


  @override
  List<Object> get props => [userModel,status,message];
}

class ProfileInProcess extends ProfileState {
  @override
  List<Object> get props => [];
}

