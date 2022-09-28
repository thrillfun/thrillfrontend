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
  final UserModel userModel;
  final String message;
  final bool status;
  final List<VideoModel> likesList;
  final List<VideoModel> privateList;
  final List<VideoModel> publicList;

  const ProfileLoaded(
      {required this.userModel,
      required this.likesList,
      required this.privateList,
      required this.publicList,
      required this.status,
      required this.message});

  @override
  List<Object> get props =>
      [userModel, likesList, privateList, publicList, status, message];
}

class ProfileInProcess extends ProfileState {
  @override
  List<Object> get props => [];
}
