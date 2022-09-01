import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/models/add_sound_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/widgets/gradient_elevated_button.dart';
import '../../models/user.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';
import '../../widgets/video_item.dart';

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
  List<AddSoundModel> favSound = List<AddSoundModel>.empty(growable: true);
  List<int> bookmarkedIndexes = List.empty(growable: true);
  late UserModel userModel;

  @override
  void initState(){
    super.initState();
    loadUserModel();
    getSounds();
    try{
      reelsPlayerController?.pause();
    }catch(_){}
  }

  loadUserModel() async {
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    userModel = UserModel.fromJson(jsonDecode(currentUser!));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF2F8897),
                    Color(0xff1F2A52),
                    Color(0xff1F244E)]),
            ),
          ),
          elevation: 0.5,
          title: const Text(
            chooseMusic,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.white,
              icon: const Icon(Icons.close)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:GradientElevatedButton(

          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3'], allowMultiple: false);
            if(result!=null){
              File file = File(result.files.single.path!);
              double size = file.lengthSync()/1000000;
              String name = file.path.split('/').last.split('.').first;
              if(size < 101){
                if(size > 0.1){
                  AddSoundModel addSoundModel = AddSoundModel(0, userModel.id ,0, file.path, name, '', '',true);
                  Navigator.pop(context, addSoundModel);
                } else {
                  showErrorToast(context, "File Size too Small!!");
                }
              } else {
                showErrorToast(context, "Max File Size is 100 MB");
              }
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min
            ,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.music_note),
              SizedBox(width: 20,),
              Text(
                chooseFromDevice,
                style: TextStyle(fontSize: 16),
              )
            ],
          )),
        body: isLoading?
            const Center(child: CircularProgressIndicator(),): newSongList.isEmpty?
            Center(child: Text(noSoundFound, style: Theme.of(context).textTheme.headline3,),):
        ListView.builder(
            itemCount: newSongList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(children: [GestureDetector(
                  onTap: (){
                //setState(()=>checkBoxIndex=index);
                downloadSound(index);
              },
              child: Container(

              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.white,
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Container(
              decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(49)),
              gradient: LinearGradient(colors: <Color>[Color(0xFF2F8897),
              Color(0xff1F2A52),
              Color(0xff1F244E)])),
              height: 50,
              width: 50,
              child: Icon(Icons.play_circle,color: Colors.white,)
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
              style: const TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              ),

              Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

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
              ,  GestureDetector(
              onTap: () async {
              if(favSound.contains(newSongList[index])){
              setState(()=>favSound.remove(newSongList[index]));
              await RestApi.addAndRemoveFavariteSoundHastag(newSongList[index].id, "sound", 0);
              } else {
              setState(()=>favSound.add(newSongList[index]));
              await RestApi.addAndRemoveFavariteSoundHastag(newSongList[index].id, "sound", 1);
              }
              setState(() {});
              },
              child: Material(
              borderRadius: BorderRadius.circular(5),
              elevation: 10,
              child: Container(
              padding: const EdgeInsets.symmetric(
              horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
              color: Colors.grey.shade300,
              width: 1)),
              child: Icon(
              isFav(index)?
              Icons.bookmark_outlined:
              Icons.bookmark_outline_sharp,size: 20,)),
              ),
              ),
              ],
              ),
              ),
              ),Divider(thickness: 2,)],);
            }));
  }

  getSounds() async {
    try{
      var response = await RestApi.getSoundList();
      var result = await RestApi.getFavriteItems();
      var json = jsonDecode(response.body);
      var jsonSound = jsonDecode(result.body);
      var jsonList = json['data'] as List;
      List jsonSoundList = jsonSound['data']['sounds'] as List;
      newSongList = jsonList.map((e) => AddSoundModel.fromJson(e)).toList();
      favSound = jsonSoundList.map((e) => AddSoundModel.fromJson(e)).toList();
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

  bool isFav(int index){
    bool fav = false;
    for(AddSoundModel aSM in favSound){
      if(aSM.id==newSongList[index].id){
        fav = true;
        break;
      }
    }
    return fav;
  }
}
