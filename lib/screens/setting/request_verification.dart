import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/user.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

class RequestVerification extends StatefulWidget {
  const RequestVerification({Key? key}) : super(key: key);

  @override
  State<RequestVerification> createState() => _RequestVerificationState();

  static const String routeName = '/requestVerification';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const RequestVerification(),
    );
  }
}

class _RequestVerificationState extends State<RequestVerification> {
  File? image;
  TextEditingController userNameCtr = TextEditingController();
  TextEditingController fullNameCtr = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          requestVerification,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              //Get.back();
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            const Text(
              applyForVerification,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'A verified Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'A submitted Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: userNameCtr,
              decoration: const InputDecoration(label: Text(username)),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: fullNameCtr,
              decoration: const InputDecoration(label: Text(fullName)),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    applyForVerification,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      pickImage(context);
                    },
                    child: const Text(
                      chooseFile,
                      style: TextStyle(color: ColorManager.cyan),
                    ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  sendVerification();
                },
                style: ElevatedButton.styleFrom(
                    primary: ColorManager.deepPurple,
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * .90, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                child: const Text(
                  send,
                  style: TextStyle(fontSize: 20),
                )),
            const SizedBox(
              height: 30,
            )
          ],
        )
            .h(MediaQuery.of(context).size.height - kToolbarHeight)
            .scrollVertical(),
      ),
    );
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

  void loadData() async {
    try {
      var instance = await SharedPreferences.getInstance();
      var loginData = instance.getString('currentUser');
      var user = UserModel.fromJson(jsonDecode(loginData!));
      userNameCtr.text = user.username;
      fullNameCtr.text = user.name;
      isLoading = false;
    } on Exception catch (_) {
      isLoading = false;
    }
    setState(() {});
  }

  void sendVerification() async {
    if (userNameCtr.text.isEmpty || fullNameCtr.text.isEmpty || image == null) {
      showErrorToast(context, "Username,FullName and File required");
    } else {
      progressDialogue(context);
      var result = await RestApi.sendVerification(
          fullNameCtr.text, image != null ? image!.path : "", userNameCtr.text);
      var json = jsonDecode(result.body);
      if (json['status']) {
        closeDialogue(context);
        showSuccessToast(context, json['message']);
      } else {
        closeDialogue(context);
        showErrorToast(context, json['message']);
      }
    }
  }
}
