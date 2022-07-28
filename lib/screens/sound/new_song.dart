import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/rest/rest_url.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

class NewSong extends StatefulWidget {
  const NewSong({Key? key}) : super(key: key);
  static const String routeName = '/newSong';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const NewSong(),
    );
  }

  @override
  State<NewSong> createState() => _NewSongState();
}

class _NewSongState extends State<NewSong> {
  bool isLoading = true;
  List<AddSoundModel> newSongList = List<AddSoundModel>.empty(growable: true);
  List<int> bookmarkedIndexes = List.empty(growable: true);

  @override
  void initState(){
    super.initState();
    getSounds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          title: const Text(
            "Choose Music",
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3'], allowMultiple: false);
              if(result!=null){
                File file = File(result.files.single.path!);
                double size = file.lengthSync()/1000000;
                String name = file.path.split('/').last.split('.').first;
                if(size < 101){
                  if(size > 0.1){
                    AddSoundModel addSoundModel = AddSoundModel(0, 0, file.path, name, '', '');
                    Navigator.pop(context, addSoundModel);
                  } else {
                    showErrorToast(context, "File Size too Small!!");
                  }
                } else {
                  showErrorToast(context, "Max File Size is 100 MB");
                }
              }
            },
            style: ElevatedButton.styleFrom(
                primary: ColorManager.cyan,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.music_note),
                Text(
                  "Choose From Device",
                  style: TextStyle(fontSize: 16),
                )
              ],
            )),
        body: isLoading?
            const Center(child: CircularProgressIndicator(),): newSongList.isEmpty?
            const Center(child: Text("No Songs Found!"),):
        ListView.builder(
            itemCount: newSongList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: (){
                  //setState(()=>checkBoxIndex=index);
                  downloadSound(index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        color: ColorManager.cyan,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/play.svg',
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newSongList[index].name,
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if(bookmarkedIndexes.contains(index)){
                                        bookmarkedIndexes.remove(index);
                                      } else {
                                        bookmarkedIndexes.add(index);
                                      }
                                    });
                                  },
                                  child: Material(
                                    borderRadius: BorderRadius.circular(50),
                                    elevation: 10,
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1)),
                                        child: Icon(
                                          bookmarkedIndexes.contains(index)?
                                              Icons.bookmark_outlined:
                                            Icons.bookmark_outline_sharp)),
                                  ),
                                ),
                                // Visibility(
                                //   visible: checkBoxIndex==index?true:false,
                                //   child: Padding(
                                //     padding: const EdgeInsets.only(left: 10),
                                //     child: Material(
                                //         borderRadius: BorderRadius.circular(50),
                                //         elevation: 10,
                                //         child: Container(
                                //           padding: const EdgeInsets.symmetric(
                                //               horizontal: 10, vertical: 5),
                                //           decoration: BoxDecoration(
                                //               borderRadius:
                                //                   BorderRadius.circular(50),
                                //               border: Border.all(
                                //                   color: Colors.grey.shade300,
                                //                   width: 1)),
                                //           child: Checkbox(
                                //             activeColor: ColorManager.cyan,
                                //             materialTapTargetSize:
                                //             MaterialTapTargetSize
                                //                 .shrinkWrap,
                                //             visualDensity: const VisualDensity(
                                //                 horizontal: -4, vertical: -4),
                                //             onChanged: (val) {
                                //               setState(() =>checkBoxIndex=99999999);
                                //             },
                                //             value: true,
                                //           ),
                                //         )),
                                //   ),
                                // ),
                              ],
                            ),
                            // const Text(
                            //   '00:10',
                            //   style: TextStyle(color: Colors.grey),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  getSounds() async {
    try{
      var response = await RestApi.getSoundList();
      var json = jsonDecode(response.body);
      var jsonList = json['data'] as List;
      newSongList = jsonList.map((e) => AddSoundModel.fromJson(e)).toList();
      isLoading = false;
      setState(() {});
    } catch(e){
      showErrorToast(context, e.toString());
      setState(()=>isLoading=false);
    }
  }
  downloadSound(int index)async{
    File file = File('$saveCacheDirectory${newSongList[index].sound}');
    try{
      if(await file.exists()){
        AddSoundModel addSoundModel = newSongList[index];
        addSoundModel.sound = "$saveCacheDirectory${newSongList[index].sound}";
        Navigator.pop(context, addSoundModel);
      } else {
        progressDialogue(context);
        await FileSupport().downloadCustomLocation(
          url: "${RestUrl.awsSoundUrl}${newSongList[index].sound}",
          path: saveCacheDirectory,
          filename: newSongList[index].sound.split('.').first,
          extension: ".${newSongList[index].sound.split('.').last}",
          progress: (progress) async {},
        );
        AddSoundModel addSoundModel = newSongList[index];
        addSoundModel.sound = "$saveCacheDirectory${newSongList[index].sound}";
        closeDialogue(context);
        Navigator.pop(context, addSoundModel);
      }
    } catch(e){
      closeDialogue(context);
      showErrorToast(context, e.toString());
    }
  }
}
