part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class TextChangeEvent extends LoginEvent{
  final String email;
  final String password;
  final String loginType;
  const TextChangeEvent({required this.email,required this.password,required this.loginType});

  @override
  List<Object?> get props => [email,password,loginType];

}


class PhoneValidation extends LoginEvent{
  final String phone;
  const PhoneValidation({required this.phone});

  @override
  List<Object?> get props => [phone];

}

class PassValidation extends LoginEvent{
  final String pass,confirm,phone;
  const PassValidation({required this.pass,required this.confirm,required this.phone});

  @override
  List<Object?> get props => [pass,confirm,phone];

}

