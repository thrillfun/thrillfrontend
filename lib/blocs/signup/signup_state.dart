part of 'signup_bloc.dart';

abstract class SignupState extends Equatable {
  const SignupState();
  @override
  List<Object> get props => [];
}

class SignupInitial extends SignupState {}

class SignupValidated extends SignupState {}

class SignupError extends SignupState {
  final String message;
  final bool isName;
  final bool isMobile;
  final bool isDob;
  final bool isPass;

  const SignupError(
      {required this.message,
      required this.isMobile,
      required this.isName,
      required this.isPass,
      required this.isDob});

  @override
  List<Object> get props => [message, isName, isMobile, isPass, isDob];
}

class SignupSuccess extends SignupState {
  final String message;
  final bool status;

  const SignupSuccess({required this.message, required this.status});

  @override
  List<Object> get props => [message, status];

}
