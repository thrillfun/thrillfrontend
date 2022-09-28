part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginStatus extends LoginState {
  final String message;
  final bool status;

  const LoginStatus({required this.message, required this.status});

  @override
  List<Object?> get props => [status, message];
}

class LoginValidated extends LoginState {}

class OnError extends LoginState {
  final String message;
  final bool isPass;
  final bool isEmail;

  const OnError(
      {required this.message, required this.isPass, required this.isEmail});

  @override
  List<Object?> get props => [message, isPass, isEmail];
}

class OnValidation extends LoginState {
  final String message;
  final bool status;

  const OnValidation({required this.message, required this.status});

  @override
  List<Object?> get props => [message, status];
}

class OnPassValidation extends LoginState {
  final String message;
  final bool isPass;
  final bool isConfirm;

  const OnPassValidation(
      {required this.message, required this.isPass, required this.isConfirm});

  @override
  List<Object?> get props => [message, isPass, isConfirm];
}
