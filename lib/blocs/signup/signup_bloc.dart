import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user.dart';
import '../../repository/login/login_repository.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final LoginRepository _loginRepository;

  SignupBloc({required LoginRepository loginRepository})
      : _loginRepository = loginRepository,
        super(SignupInitial()) {
    on<SignupValidation>(_onValidation);
  }

  void _onValidation(SignupValidation event, Emitter<SignupState> emit) async {
    List<String> likeList = List<String>.empty(growable: true);
    likeList.add("0");
    List<String> commetList = List<String>.empty(growable: true);
    commetList.add("0");
    List<String> viewVideoList = List<String>.empty(growable: true);
    commetList.add("0");
    List<String> followList = List<String>.empty(growable: true);
    followList.add("0");
    List<String> favSound = List<String>.empty(growable: true);
    favSound.add("0");
    List<String> favHastag = List<String>.empty(growable: true);
    favHastag.add("0");
    if (event.fullName.isEmpty &&
        event.password.isEmpty &&
        event.mobile.isEmpty &&
        event.dob.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: true,
          isDob: true,
          isName: true,
          isMobile: true));
    } else if (event.fullName.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: false,
          isDob: false,
          isName: true,
          isMobile: false));
    } else if (event.fullName.isEmpty && event.dob.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: false,
          isDob: true,
          isName: true,
          isMobile: false));
    } else if (event.fullName.isEmpty && event.password.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: true,
          isDob: false,
          isName: true,
          isMobile: false));
    } else if (event.mobile.isEmpty &&
        event.password.isEmpty &&
        event.dob.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: true,
          isDob: true,
          isName: false,
          isMobile: true));
    } else if (event.fullName.isEmpty &&
        event.password.isEmpty &&
        event.dob.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: true,
          isDob: true,
          isName: true,
          isMobile: false));
    } else if (event.mobile.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: false,
          isDob: false,
          isName: false,
          isMobile: true));
    } else if (event.mobile.length < 10) {
      emit(const SignupError(
          message: "Mobile must be 10 digit",
          isPass: false,
          isDob: false,
          isName: false,
          isMobile: true));
    } else if (event.dob.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: false,
          isDob: true,
          isName: false,
          isMobile: false));
    } else if (event.dob.isEmpty && event.password.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: true,
          isDob: true,
          isName: false,
          isMobile: false));
    } else if (event.password.isEmpty) {
      emit(const SignupError(
          message: "Field required",
          isPass: true,
          isDob: false,
          isName: false,
          isMobile: false));
    } else if (event.password.length < 4) {
      emit(const SignupError(
          message: "M-PIN must be 4 digit",
          isPass: true,
          isDob: false,
          isName: false,
          isMobile: false));
    } else {
      emit(SignupValidated());
      try {
        var result = await _loginRepository.registerUser(
            event.fullName, event.mobile, event.dob, event.password);
        if (result['status']) {
          UserModel user = UserModel.fromJson(result['data']['user']);
          var pref = await SharedPreferences.getInstance();
          await pref.setString(
            'currentUser',
            jsonEncode(user.toJson()),
          );
          await pref.setString('currentToken', result['data']['token']);
          await pref.setStringList('likeList', likeList);
          await pref.setStringList('commentList', commetList);
          await pref.setStringList('viewList', viewVideoList);
          await pref.setStringList('followList', followList);
          await pref.setStringList('favSound', favSound);
          await pref.setStringList('favTag', favHastag);
          emit(const SignupSuccess(message: 'success', status: true));
        } else {
          emit(SignupSuccess(
              message: result['message'].toString(), status: false));
        }
      } catch (e) {
        emit(SignupSuccess(message: e.toString(), status: false));
      }
    }
  }
}
