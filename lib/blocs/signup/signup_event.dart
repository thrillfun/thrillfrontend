part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class SignupValidation extends SignupEvent {
  final String fullName, mobile, dob, password;

  const SignupValidation(
      {required this.fullName,
      required this.mobile,
      required this.dob,
      required this.password});

  @override
  List<Object> get props => [fullName, mobile, dob, password];
}
