import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thrill/blocs/profile/profile_bloc.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/social_url_model.dart';
import '../../repository/login/login_repository.dart';
import '../../rest/rest_url.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();

  static const String routeName = '/editProfile';

  static Route route({required UserModel user}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider(
        create: (context) => ProfileBloc(loginRepository: LoginRepository()),
        child: EditProfile(user: user),
      ),
    );
  }

  final UserModel user;
}

class _EditProfileState extends State<EditProfile> {
  String dropDownGender = '';
  TextEditingController controller = TextEditingController();
  TextEditingController userNameCtr = TextEditingController();
  TextEditingController firstNameCtr = TextEditingController();
  TextEditingController lastNameCtr = TextEditingController();
  TextEditingController websiteCtr = TextEditingController();
  TextEditingController bioCtr = TextEditingController();

  File? image;

  List<SocialUrlModel> socialList = List<SocialUrlModel>.empty(growable: true);
  List<String> genderList = List<String>.empty(growable: true);

  @override
  void initState() {
    setState(() {
      userNameCtr.text = widget.user.username;
      firstNameCtr.text = widget.user.first_name;
      lastNameCtr.text = widget.user.last_name;
      websiteCtr.text = widget.user.website_url;
      bioCtr.text = widget.user.bio;
      dropDownGender=widget.user.gender;

      socialList.add(SocialUrlModel('youtube', widget.user.youtube));
      socialList.add(SocialUrlModel('facebook', widget.user.facebook));
      socialList.add(SocialUrlModel('instagram', widget.user.instagram));
      socialList.add(SocialUrlModel('twitter', widget.user.twitter));

      genderList.addAll({"Male","Female","Other"});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          editProfile,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          TextButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                BlocProvider.of<ProfileBloc>(context).add(
                  ProfileValidation(
                      userNameCtr.text,
                      firstNameCtr.text,
                      lastNameCtr.text,
                      bioCtr.text,
                      image != null ? image!.path : "",
                      dropDownGender,
                      websiteCtr.text,
                      socialList),
                );
              },
              style: TextButton.styleFrom(primary: ColorManager.cyan),
              child: const Text(
                save,
                style: TextStyle(fontSize: 16),
              ))
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ValidationProcess) {
            progressDialogue(context);
          } else if (state is ValidationStatus) {
            closeDialogue(context);
            if (state.status) {
              showSuccessToast(context, state.message);
              BlocProvider.of<ProfileBloc>(context).add(ProfileLoading());
              Future.delayed(const Duration(milliseconds: 150)).then((value) {
                Navigator.pop(context, "/profile");
              });
            } else {
              showErrorToast(context, state.message);
            }
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        pickImage(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        height: 111,
                        width: 111,
                        decoration:  BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorManager.spinColorDivider),
                        ),
                        child: image != null
                            ? ClipOval(
                              child: Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                height: 100,width: 100,
                                ),
                            )
                            : widget.user.avatar.isEmptyOrNull
                                ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset('assets/profile.svg'),
                                )
                                : ClipOval(
                                  child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      height: 100,width: 100,
                                      imageUrl:
                                          '${RestUrl.profileUrl}${widget.user.avatar}',
                                      placeholder: (a, b) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      maxLength: 30,
                      controller: userNameCtr,
                      decoration: InputDecoration(
                          isDense: true,
                          constraints:
                              BoxConstraints(maxWidth: getWidth(context) * .90),
                          label: const Text(username)),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameCtr,
                            decoration: const InputDecoration(
                                isDense: true, label: Text(firstName)),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameCtr,
                            decoration: const InputDecoration(
                                isDense: true, label: Text(lastName)),
                          ),
                        ),
                      ],
                    ).w(getWidth(context) * .90),
                    const SizedBox(
                      height: 15,
                    ),
                    DropdownButton(
                      value:dropDownGender,
                      style: const TextStyle(color: Colors.grey, fontSize: 17),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 35,
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          setState(() {
                            dropDownGender = value!;
                          });
                        });
                      },
                      items: genderList.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                    ).w(getWidth(context) * .90),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: websiteCtr,
                      decoration: InputDecoration(
                          isDense: true,
                          constraints:
                              BoxConstraints(maxWidth: getWidth(context) * .90),
                          label: const Text(websiteURL)),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: bioCtr,
                      minLines: 3,
                      maxLines: 3,
                      maxLength: 100,
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          constraints:
                              BoxConstraints(maxWidth: getWidth(context) * .90),
                          label: const Text(yourBio)),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          linkSocialAccounts,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 25,
                        ),
                        IconButton(
                          onPressed: () {
                             linkDialog(linkYouTube, youtubeURL,widget.user.youtube,"youtube");
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(),
                          iconSize: 20,
                          icon: SvgPicture.asset('assets/youtube.svg'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: (){
                            linkDialog(linkFacebook, facebookURL,widget.user.facebook,"facebook");
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(),
                          iconSize: 20,
                          icon: SvgPicture.asset('assets/facebook.svg'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: (){
                            linkDialog(linkInstagram, instagramURL,widget.user.instagram,"instagram");
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(),
                          iconSize: 20,
                          icon: SvgPicture.asset('assets/insta.svg'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: (){
                             linkDialog(linkTwitter, twitterURL,widget.user.twitter,"twitter");
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(),
                          iconSize: 20,
                          icon: SvgPicture.asset('assets/twitter.svg'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

 linkDialog(String title, String link,String setTitle,String name)  {
    controller.clear();
    controller.text=setTitle;
    showDialog(
        context: context,
        builder: (_) => Center(
              child: Material(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(link),
                        Expanded(
                            child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                              isDense: true,
                              suffixIcon: TextButton(
                                onPressed: () {
                                  controller.clear();
                                },
                                child: const Text(
                                  clear,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: (){
                              Navigator.pop(context);
                              FocusScope.of(context).requestFocus(FocusNode());
                              setData(name,);
                              BlocProvider.of<ProfileBloc>(context).add(
                                ProfileValidation(
                                    userNameCtr.text,
                                    firstNameCtr.text,
                                    lastNameCtr.text,
                                    bioCtr.text,
                                    "",
                                    dropDownGender,
                                    websiteCtr.text,
                                    socialList),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                primary: ColorManager.cyan),
                            child: const Text(
                              save,
                              style: TextStyle(fontSize: 16),
                            )),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                primary: ColorManager.red),
                            child: const Text(
                              cancel,
                              style: TextStyle(fontSize: 16),
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ).w(getWidth(context) * .90),
            ));
  }
void setData(String name) {
  switch (name) {
    case "youtube":
      final tile = socialList.firstWhere(
              (item) => item.title == 'youtube');
      setState(() => tile.url = controller.text);
      break;
    case "facebook":
      final tile = socialList.firstWhere(
              (item) => item.title == 'facebook');
      setState(() => tile.url = controller.text);
      break;
    case "instagram":
      final tile = socialList.firstWhere(
              (item) => item.title == 'instagram');
      setState(() => tile.url = controller.text);
      break;
    case "twitter":
      final tile = socialList.firstWhere(
              (item) => item.title == 'twitter');
      setState(() => tile.url = controller.text);
      break;
  }

}

  void pickImage(BuildContext context) async {
    var source = await imagePickerSheet(context);
    if (source != null) {
      var picker = ImagePicker.platform;
      var file = await picker.pickImage(
        source: source,
        maxHeight: 1080,
        maxWidth: 1080,
        imageQuality: 90,
      );
      setState(() {
        image = File(file!.path);
      });
    }
  }

  Future<ImageSource?> imagePickerSheet(BuildContext context) async {
    ImageSource? source = await showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.only(bottom: 16, top: 16),
            color: Colors.white,
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.camera_rounded,
                          size: 55,
                        ),
                        Text('Camera'),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.photo_rounded,
                          size: 55,
                        ),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
    return source;
  }
}
