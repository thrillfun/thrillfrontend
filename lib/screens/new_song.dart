import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/models/add_sound_model.dart';
import '../rest/rest_api.dart';
import '../utils/util.dart';

int newSongCategoryId = 0;

class NewSong extends StatefulWidget {
  const NewSong({Key? key, required this.categoryId}) : super(key: key);
  static const String routeName = '/newSong';
  final int categoryId;

  static Route route(int id) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => NewSong(categoryId: id,),
    );
  }

  @override
  State<NewSong> createState() => _NewSongState();
}

class _NewSongState extends State<NewSong> {
  int checkBoxIndex = 99999999;
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
            newSong,
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
          actions: [
            Visibility(
              visible: checkBoxIndex!=99999999?true:false,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context, newSongList[checkBoxIndex]);
                    },
                    color: Colors.black,
                    icon: const Icon(Icons.check)),
            ),
          ],
        ),
        body: isLoading?
            const Center(child: CircularProgressIndicator(),): newSongList.isEmpty?
            const Center(child: Text("No Songs Found!"),):
        ListView.builder(
            itemCount: newSongList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: (){
                  setState(()=>checkBoxIndex=index);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                                Visibility(
                                  visible: checkBoxIndex==index?true:false,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Material(
                                        borderRadius: BorderRadius.circular(50),
                                        elevation: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1)),
                                          child: Checkbox(
                                            activeColor: ColorManager.cyan,
                                            materialTapTargetSize:
                                            MaterialTapTargetSize
                                                .shrinkWrap,
                                            visualDensity: const VisualDensity(
                                                horizontal: -4, vertical: -4),
                                            onChanged: (val) {
                                              setState(() =>checkBoxIndex=99999999);
                                            },
                                            value: true,
                                          ),
                                        )),
                                  ),
                                ),
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
      var response = await RestApi.getSoundList(widget.categoryId);
      var json = jsonDecode(response.body);
      print(json);
      var jsonList = json['data'] as List;
      newSongList = jsonList.map((e) => AddSoundModel.fromJson(e)).toList();
      isLoading = false;
      setState(() {});
    } catch(e){
      showErrorToast(context, e.toString());
      setState(()=>isLoading=false);
    }
  }
}
