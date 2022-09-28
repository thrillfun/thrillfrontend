import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../models/earnSpin_model.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

class EarnSpins extends StatefulWidget {
  const EarnSpins({Key? key}) : super(key: key);

  @override
  State<EarnSpins> createState() => _EarnSpinsState();

  static const String routeName = '/earnSpin';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const EarnSpins(),
    );
  }
}

class _EarnSpinsState extends State<EarnSpins> {
  bool isLoading = true;

  List<EarnSpin> earnList = List<EarnSpin>.empty(growable: true);

  @override
  void initState() {
    loadEarnSpins();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        centerTitle: true,
        title: const Text(
          earnSpins,
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox(
                  height: getHeight(context),
                  child: ListView.builder(
                      itemCount: earnList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Level for ${earnList[index].name}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            card(earnList[index]),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        );
                      }),
                ),
        ),
      ),
    );
  }

  Widget card(EarnSpin earnModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
          boxShadow: kElevationToShadow[2],
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: earnModel.conditions + '\n\n',
                      style: const TextStyle(color: Colors.black)),
                  const TextSpan(
                      text: earnedSpins, style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: '${earnModel.earned_spins}/${earnModel.total_spin}',
                      style: const TextStyle(color: Colors.black))
                ]),
              )),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: ColorManager.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: const Text(
                    spinWheel,
                    style: TextStyle(fontSize: 16),
                  )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width * .80,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300, width: 1)),
            child: Row(
              children: [
                Container(
                  height: 25,
                  width: 25,
                  margin: const EdgeInsets.only(left: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade900, shape: BoxShape.circle),
                  child: Text(
                    earnModel.current_level,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: SliderComponentShape.noThumb,
                        trackHeight: 3),
                    child: Slider(
                        max: 100,
                        min: 0,
                        value: double.parse(earnModel.current_level) * 10,
                        activeColor: ColorManager.cyan,
                        onChanged: (val) {}),
                  ),
                ),
                Container(
                  height: 25,
                  width: 25,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: Text(
                    earnModel.next_level,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void loadEarnSpins() async {
    try {
      var result = await RestApi.getWheelEarnedDetails();
      var json = jsonDecode(result.body);
      if (json['status']) {
        earnList.clear();
        earnList = List<EarnSpin>.from(
                json['data']['activities'].map((i) => EarnSpin.fromJson(i)))
            .toList(growable: true);
      }
      setState(() {
        isLoading = false;
      });
    } catch (_) {}
  }
}
