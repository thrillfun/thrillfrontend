import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:thrill/models/banner_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../common/strings.dart';
import '../../models/vidio_discover_model.dart';

class Discover extends StatefulWidget {
  const Discover({Key? key}) : super(key: key);

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  String searchValue = '';
  bool isLoading = true;
  String query = '';

  List<BannerModel> bannerList = List<BannerModel>.empty(growable: true);
  List<DiscoverVideo> videoList = List<DiscoverVideo>.empty(growable: true);

  @override
  void initState() {
    loadAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          maxLength: 10,
                          textInputAction: TextInputAction.next,
                          onChanged: (txt) {
                            setState(() {
                              query = txt;
                            });
                          },
                          decoration: InputDecoration(
                              hintText: search,
                              counterText: '',
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 2),
                                  borderRadius: BorderRadius.circular(50)),
                              constraints: BoxConstraints(
                                  maxHeight: 45,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * .90),
                              prefixIcon: const Icon(Icons.search, size: 30,)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CarouselSlider.builder(
                          options: CarouselOptions(
                            autoPlayAnimationDuration:
                                const Duration(seconds: 7),
                            autoPlayCurve: Curves.easeIn,
                            viewportFraction: 1,
                            height: 200,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            autoPlay: true,
                          ),
                          itemCount: bannerList.length,
                          itemBuilder: (context, index, realIndex) {
                            return Stack(
                              children: [
                                Container(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      imageUrl:
                                          '${RestUrl.bannerUrl}${bannerList[index].image}',
                                    )),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        for (int i = 0;
                                            i < bannerList.length;
                                            i++)
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8, bottom: 8),
                                              height: 13,
                                              width: 13,
                                              decoration: BoxDecoration(
                                                  color: i == index
                                                      ? Colors.white
                                                      : Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                      ]),
                                )
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    child: Builder(builder: (context) {
                      if (query.trim().isNotEmpty) {
                        List<DiscoverVideo> searchList = [];

                        for (DiscoverVideo discover in videoList) {
                          if (discover.hashtag_name
                              .toLowerCase()
                              .contains(query.toLowerCase())) {
                            searchList.add(discover);
                          }
                        }

                        if (searchList.isEmpty) {
                          return Container(
                            height: 180,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            child: const Text(
                              'No Hashtag Found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: searchList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return listWidget(searchList[index], index);
                          },
                        );
                      }

                      return ListView.builder(
                          itemCount: videoList.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return listWidget(videoList[index], index);
                          });
                    }),
                  )
                ],
              ),
      ),
    );
  }

  void loadAllData() async {
    try {
      var bannerResult = await RestApi.getDiscoverBanner();
      var json = jsonDecode(bannerResult.body);
      bannerList.clear();
      bannerList =
          List<BannerModel>.from(json.map((i) => BannerModel.fromJson(i)))
              .toList(growable: true);

      var videoResult = await RestApi.getVideoWithHash();
      var jsonResult = jsonDecode(videoResult.body);
      videoList.clear();
      videoList = List<DiscoverVideo>.from(
              jsonResult['data'].map((i) => DiscoverVideo.fromJson(i)))
          .toList(growable: true);

      setState(() {
        isLoading = false;
      });
    } catch (_) {}
  }

  Widget listWidget(DiscoverVideo discoverVideo, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/tagDetails',arguments: discoverVideo);
          },
          child: Row(
            children: [
              Container(
                height: 20,
                width: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: const Text('#'),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: '${discoverVideo.hashtag_name}\n'
                          .allWordsCapitilize(),
                      style: const TextStyle(color: Colors.black)),
                  const TextSpan(
                      text: 'Trending HashTag',
                      style: TextStyle(color: Colors.grey))
                ])),
              ),
              Container(
                height: 20,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(5)),
                child: Text("${discoverVideo.video_count}"),
              )
            ],
          ).w(getWidth(context) * .90),
        ),
        SizedBox(
          height: 140,
          width: getWidth(context),
          child: ListView.builder(
            itemCount: discoverVideo.hashVideo.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context2, int index2) {
              return Container(
                margin: const EdgeInsets.all(2),
                width: 112,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl:
                  discoverVideo.hashVideo[index2].gif_image.isEmpty
                  ? '${RestUrl.thambUrl}thumb-not-available.png'
                  : '${RestUrl.gifUrl}${discoverVideo.hashVideo[index2].gif_image}',
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
