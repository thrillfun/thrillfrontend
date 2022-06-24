part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileValidation extends ProfileEvent {
  final String userName, firstName, lastName, bio, gender;
  final String websiteUrl;
  List<SocialUrlModel> list;
  final String profileImage;

  ProfileValidation(this.userName, this.firstName, this.lastName, this.bio,
      this.profileImage, this.gender, this.websiteUrl, this.list);

  @override
  List<Object> get props => [
        userName,
        firstName,
        lastName,
        bio,
        profileImage,
        gender,
        websiteUrl,
        list
      ];
}

class ProfileLoading extends ProfileEvent {
  ProfileLoading();
  @override
  List<Object> get props => [];
}

