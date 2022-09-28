part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileValidation extends ProfileEvent {
  final String userName, firstName, lastName, fullName, bio, gender;
  final String websiteUrl;
  final List<SocialUrlModel> list;
  final String profileImage;

  const ProfileValidation(
      this.userName,
      this.firstName,
      this.lastName,
      this.fullName,
      this.bio,
      this.profileImage,
      this.gender,
      this.websiteUrl,
      this.list);

  @override
  List<Object> get props => [
        userName,
        firstName,
        lastName,
        fullName,
        bio,
        profileImage,
        gender,
        websiteUrl,
        list
      ];
}

class ProfileLoading extends ProfileEvent {
  const ProfileLoading();

  @override
  List<Object> get props => [];
}
