import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user.dart';
import '../../repository/login/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository _loginRepository;
  LoginBloc({required LoginRepository loginRepository})
      : _loginRepository = loginRepository,
        super(LoginInitial()) {
    on<TextChangeEvent>(_onTextChange);
    on<PhoneValidation>(_onPhoneValidation);
    on<PassValidation>(_onPasswordValidation);
  }


void _onTextChange(TextChangeEvent event, Emitter<LoginState> emit) async {
  List<String> likeList=List<String>.empty(growable: true);
  likeList.add("0");
  List<String> commetList=List<String>.empty(growable: true);
  commetList.add("0");
  List<String> viewVideoList=List<String>.empty(growable: true);
  commetList.add("0");
  List<String> followList=List<String>.empty(growable: true);
  followList.add("0");
  List<String> favSound=List<String>.empty(growable: true);
  favSound.add("0");
  List<String> favHastag=List<String>.empty(growable: true);
  favHastag.add("0");
  if (event.loginType == 'normal') {
    if (event.email.isEmpty && event.password.isEmpty) {
      emit(const OnError(
          message: "Field required", isPass: true, isEmail: true));
    } else if (event.password.isEmpty) {
      emit(
          const OnError(
              message: "Field required", isPass: true, isEmail: false));
    } else if (event.email.isEmpty) {
      emit(
          const OnError(
              message: "Field required", isPass: false, isEmail: true));
    } else if (event.email.length < 10) {
      emit(const OnError(
          message: "Min Phone digit 10", isPass: false, isEmail: true));
    } else if (event.password.length < 4) {
      emit(const OnError(
          message: "M-PIN must be 4 digit", isPass: true, isEmail: false));
    } else {
      emit(LoginValidated());
      var result = await _loginRepository.loginUser(
          event.email, event.password);
      if (result['status']) {
        try {
          var pref = await SharedPreferences.getInstance();
          UserModel user = UserModel.fromJson(result['data']['user']);
          await pref.setString('currentUser', jsonEncode(user.toJson()),);
          await pref.setString('currentToken', result['data']['token']);
          await pref.setStringList('likeList', likeList);
          await pref.setStringList('commentList', commetList);
          await pref.setStringList('viewList', viewVideoList);
          await pref.setStringList('followList', followList);
          await pref.setStringList('favSound', favSound);
          await pref.setStringList('favTag', favHastag);
          emit(const LoginStatus(message: "Success", status: true));

          List<String> users = pref.getStringList('allUsers') ?? [];
          users.insert(0, pref.getString('currentUser')!);
          await pref.setStringList('allUsers', users);
          await pref.setString('${user.id}currentToken', result['data']['token']);
          await pref.setStringList('${user.id}likeList', likeList);
          await pref.setStringList('${user.id}commentList', commetList);
          await pref.setStringList('${user.id}viewList', viewVideoList);
          await pref.setStringList('${user.id}followList', followList);
          await pref.setStringList('${user.id}favSound', favSound);
          await pref.setStringList('${user.id}favTag', favHastag);
        } catch (e) {
          emit(LoginStatus(message: e.toString(), status: false));
        }
      } else {
        emit(LoginStatus(message: result['message'].toString(), status: false));
      }
    }
  }else if(event.loginType == 'google'){
    emit(LoginValidated());
    GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      var account = await googleSignIn.signIn();
      if (account != null) {
        var result = await _loginRepository.socialLoginRegister(account.id,'google', account.email,account.displayName ?? '');
        if (result['status']) {
          var pref = await SharedPreferences.getInstance();
          try {
            UserModel user = UserModel.fromJson(result['data']['user']);
            await pref.setString('currentUser', jsonEncode(user.toJson()),);
            await pref.setString('currentToken', result['data']['token']);
            await pref.setStringList('likeList', likeList);
            await pref.setStringList('commentList', commetList);
            await pref.setStringList('viewList', viewVideoList);
            await pref.setStringList('followList', followList);
            await pref.setStringList('favSound', favSound);
            await pref.setStringList('favTag', favHastag);
            emit(const LoginStatus(message: "Success", status: true));

            List<String> users = pref.getStringList('allUsers') ?? [];
            users.insert(0, pref.getString('currentUser')!);
            await pref.setStringList('allUsers', users);
            await pref.setString('${user.id}currentToken', result['data']['token']);
            await pref.setStringList('${user.id}likeList', likeList);
            await pref.setStringList('${user.id}commentList', commetList);
            await pref.setStringList('${user.id}viewList', viewVideoList);
            await pref.setStringList('${user.id}followList', followList);
            await pref.setStringList('${user.id}favSound', favSound);
            await pref.setStringList('${user.id}favTag', favHastag);
          } catch (e) {
            emit(LoginStatus(message: e.toString(), status: false));
          }
        } else {
          emit(LoginStatus(message: result['message'].toString(), status: false));
        }
      }else{
        emit(const LoginStatus(message: 'Try after sometime', status: false));
      }
    }catch(e){
      emit(LoginStatus(message: e.toString(), status: false));
    }

  }else if(event.loginType == 'facebook'){

    final LoginResult result = await FacebookAuth.instance.login(loginBehavior: LoginBehavior.webOnly);
    emit(LoginValidated());
    if (result.status.toString() == 'LoginStatus.success') {
      var userData = await FacebookAuth.instance.getUserData();
      String fbid = userData['id'].toString();
      String email = userData['email'].toString();
      String name = userData['name'].toString();
      var result = await _loginRepository.socialLoginRegister(
          fbid, 'facebook', email,name);
      if (result['status']) {
        try {
          UserModel user = UserModel.fromJson(result['data']['user']);
          var pref = await SharedPreferences.getInstance();
          await pref.setString('currentUser', jsonEncode(user.toJson()),);
          await pref.setString('currentToken', result['data']['token']);
          await pref.setStringList('likeList', likeList);
          await pref.setStringList('commentList', commetList);
          await pref.setStringList('viewList', viewVideoList);
          await pref.setStringList('followList', followList);
          await pref.setStringList('favSound', favSound);
          await pref.setStringList('favTag', favHastag);
          emit(const LoginStatus(message: "Success", status: true));

          List<String> users = pref.getStringList('allUsers') ?? [];
          users.insert(0, pref.getString('currentUser')!);
          await pref.setStringList('allUsers', users);
          await pref.setString('${user.id}currentToken', result['data']['token']);
          await pref.setStringList('${user.id}likeList', likeList);
          await pref.setStringList('${user.id}commentList', commetList);
          await pref.setStringList('${user.id}viewList', viewVideoList);
          await pref.setStringList('${user.id}followList', followList);
          await pref.setStringList('${user.id}favSound', favSound);
          await pref.setStringList('${user.id}favTag', favHastag);
        } catch (e) {
          emit(LoginStatus(message: e.toString(), status: false));
        }
      } else {
        emit(LoginStatus(message: result['message'].toString(), status: false));
      }
    }else{
      emit(const LoginStatus(message: 'Error Try after some time', status: false));
    }
    }
}

void _onPhoneValidation(PhoneValidation event, Emitter<LoginState> emit) async {
    if (event.phone.isEmpty) {
      emit(const OnValidation(message: "Field required", status: false));
    } else if (event.phone.length < 10) {
      emit(const OnValidation(message: "Min Phone digit 10", status: false));
    } else {
      emit(LoginValidated());
      var result = await _loginRepository.isPhoneExist(event.phone);
      if (result['status']) {
        emit(const LoginStatus(message: "Success", status: true));
      } else {
        emit(LoginStatus(message: result['message'].toString(), status: false));
      }
    }

}

void _onPasswordValidation(PassValidation event, Emitter<LoginState> emit) async {
  if (event.pass.isEmpty && event.confirm.isEmpty) {
    emit(const OnPassValidation(message: "Field required", isPass: true,isConfirm: true));
  } else if (event.pass.length < 4) {
    emit(const OnPassValidation(message: "New M-Pin must be 4 digit", isPass: true,isConfirm: false));
  } else if (event.confirm.isEmpty) {
    emit(const OnPassValidation(message: "Field required", isPass: false,isConfirm: true));
  } else if (event.confirm.length < 4) {
    emit(const OnPassValidation(message: "Confirm M-Pin must be 4 digit", isPass: false,isConfirm: true));
  } else if (event.confirm != event.pass) {
    emit(const OnPassValidation(message: "M-Pin did`t match", isPass: false,isConfirm: true));
  } else {
    emit(LoginValidated());
    var result = await _loginRepository.resetPass(event.phone,event.pass);
    if (result['status']) {
      emit(LoginStatus(message: result['message'], status: true));
    } else {
      emit(LoginStatus(message: result['message'].toString(), status: false));
    }
  }

}

}