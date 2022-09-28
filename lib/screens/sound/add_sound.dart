import 'dart:convert';
import 'dart:io';

import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/models/sound_category_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';

class AddSound extends StatefulWidget {
  const AddSound({Key? key}) : super(key: key);
  static const String routeName = '/addSound';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const AddSound(),
    );
  }

  @override
  State<AddSound> createState() => _AddSoundState();
}

class _AddSoundState extends State<AddSound> {
  int selectedTab = 0;
  List<SoundCategoryModel> discoverList =
      List<SoundCategoryModel>.empty(growable: true);
  bool isLoading = true;

  @override
  void initState() {
    getSoundCat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          addSound,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.close)),
      ),
      body: Column(
        children: [
          DefaultTabController(
            length: 2,
            initialIndex: selectedTab,
            child: TabBar(
                onTap: (int index) {
                  setState(() {
                    selectedTab = index;
                  });
                },
                indicatorColor: ColorManager.cyan,
                tabs: [
                  Tab(
                    child: Text(
                      discover,
                      style: TextStyle(
                          fontSize: 17,
                          color: selectedTab == 0
                              ? ColorManager.cyan
                              : Colors.grey),
                    ),
                  ),
                  Tab(
                    child: Text(
                      myFavourites,
                      style: TextStyle(
                          fontSize: 17,
                          color: selectedTab == 1
                              ? ColorManager.cyan
                              : Colors.grey),
                    ),
                  ),
                ]),
          ),
          const SizedBox(
            height: 5,
          ),
          tabview(),
        ],
      ),
    );
  }

  tabview() {
    if (selectedTab == 0) {
      return discoverLayout();
    } else if (selectedTab == 1) {
      return myFavouritesLayout();
    }
  }

  Widget discoverLayout() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (discoverList.isEmpty) {
        return const Center(child: Text("Sounds not found..."));
      } else {
        return Expanded(
            child: GridView.builder(
                itemCount: discoverList.length,
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20),
                itemBuilder: (BuildContext context, int index) {
                  return ElevatedButton(
                      onPressed: () async {
                        await Navigator.pushNamed(context, "/newSong")
                            .then((value) async {
                          if (value != null) {
                            AddSoundModel? addSoundModelTemp =
                                value as AddSoundModel?;
                            File file = File(
                                '$saveCacheDirectory${addSoundModelTemp?.sound}');
                            try {
                              if (await file.exists()) {
                                Navigator.pop(context, addSoundModelTemp);
                              } else {
                                progressDialogue(context);
                                await FileSupport().downloadCustomLocation(
                                  url:
                                      "${RestUrl.downloadSound}${addSoundModelTemp?.sound}",
                                  path: saveCacheDirectory,
                                  filename:
                                      addSoundModelTemp!.sound.split('.')[0],
                                  extension:
                                      ".${addSoundModelTemp.sound.split('.')[1]}",
                                  progress: (progress) async {},
                                );
                                closeDialogue(context);
                                Navigator.pop(context, addSoundModelTemp);
                              }
                            } catch (e) {
                              closeDialogue(context);
                              showErrorToast(context, e.toString());
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          side: const BorderSide(color: Colors.grey, width: 1)),
                      child: Text(
                        discoverList[index].name,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ));
                }));
      }
    }
  }

  Widget myFavouritesLayout() {
    return Column(
      children: const [
        SizedBox(
          height: 50,
        ),
        Text('Nothing to display yet...')
      ],
    );
  }

  getSoundCat() async {
    try {
      var response = await RestApi.getSoundCategories();
      var json = jsonDecode(response.body);
      var jsonList = json['data'] as List;
      discoverList =
          jsonList.map((e) => SoundCategoryModel.fromJson(e)).toList();
      isLoading = false;
      setState(() {});
    } catch (e) {
      showErrorToast(context, e.toString());
      setState(() => isLoading = false);
    }
  }
}
