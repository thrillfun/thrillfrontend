
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/models/social_url_model.dart';
import '../../models/user.dart';
import '../../repository/login/login_repository.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final LoginRepository _loginRepository;
  ProfileBloc({required LoginRepository loginRepository}) : _loginRepository=loginRepository,
        super(ProfileInitial()) {
    on<ProfileValidation>(_onValidation);
    on<ProfileLoading>(_onProfileLoading);

  }

  void _onProfileLoading(ProfileLoading event, Emitter<ProfileState> emit) async {
    emit(ProfileInProcess());
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    UserModel current = UserModel.fromJson(jsonDecode(currentUser!));

    var result = await _loginRepository.getProfile(current.id);
    var resultLikes = await _loginRepository.getLikesVideo();
    var resultPrivate = await _loginRepository.getPrivateVideo();
    var resultPublic = await _loginRepository.getPublicVideo();

    if (result['status']) {
      try {
        UserModel user = UserModel.fromJson(result['data']['user']);
        await pref.setString('currentUser', jsonEncode(user.toJson()),);

        emit(ProfileLoaded(userModel: user, status: true, message: 'success'));
      } catch (e) {
        emit(ProfileLoaded(userModel:current,status: false, message: e.toString()));
      }
    } else {
      emit(ProfileLoaded(userModel:current, status: false, message: result['message']));
    }
  }

  void _onValidation(ProfileValidation event, Emitter<ProfileState> emit) async {
    emit(ValidationProcess());
    if(event.userName.isEmpty){
      emit(const ValidationStatus(message: "Username required", status: false));
    }else if(event.firstName.isEmpty){
      emit(const ValidationStatus(message: "FirstName required", status: false));
    }else if(event.lastName.isEmpty){
      emit(const ValidationStatus(message: "LastName required", status: false));
    }else if(event.gender.isEmpty || event.gender =='Gender'){
      emit(const ValidationStatus(message: "Select Gender", status: false));
    }else if(event.bio.isEmpty){
      emit(const ValidationStatus(message: "Bio required", status: false));
    }else{
        var result=await _loginRepository.updateProfile(event.userName, event.firstName, event.lastName, event.profileImage, event.gender, event.websiteUrl, event.bio, event.list);
         if(result['status']){
           UserModel user = UserModel.fromJson(result['data']['user']);
           var pref = await SharedPreferences.getInstance();
           await pref.setString('currentUser', jsonEncode(user.toJson()),);
           emit(ValidationStatus(message: result['message'], status: true));
         }else {
           emit(ValidationStatus(message:result['message'], status: false));
         }
    }
  }
}
