import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

var searchValue = ''.obs;

class SearchGetx extends StatelessWidget {
  const SearchGetx({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(gradient: processGradient),
          ),
          GetX<DiscoverController>(
              builder: (discoverController) => discoverController
                      .isSearchingHashtags.value
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        searchBarLayout(discoverController),
                        Container(
                          height: 150,
                          child: DefaultTabController(
                              length: discoverController.searchList.length,
                              child: TabBarView(
                                  children: List.generate(
                                      discoverController.searchList.length,
                                      (index) => TabBarView(
                                            children: List.generate(
                                                discoverController
                                                    .searchList.length,
                                                (index) => TabBar(
                                                    tabs: List.generate(
                                                        discoverController
                                                            .searchList.length,
                                                        (index) => Tab(
                                                              icon: Icon(Icons
                                                                  .heart_broken),
                                                              child: Text(
                                                                  discoverController
                                                                      .searchList[
                                                                          index]
                                                                      .name!),
                                                            )))),
                                          )))),
                        ),
                        Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: ListView.builder(
                                  itemCount:
                                      discoverController.searchList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, mainIndex) =>
                                      Container(
                                        width: Get.width,
                                        height: Get.height,
                                        child: GridView(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  maxCrossAxisExtent: 200),
                                          children: List.generate(
                                            discoverController
                                                .searchList[mainIndex]
                                                .videos!
                                                .length,
                                            (index) => Container(
                                              child: CachedNetworkImage(
                                                imageUrl: RestUrl.gifUrl +
                                                    discoverController
                                                        .searchList[mainIndex]
                                                        .videos![index]
                                                        .gifImage
                                                        .toString(),
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                            ))
                      ],
                    ))
        ],
      ),
    );
  }

  searchBarLayout(DiscoverController discoverController) => Row(
        children: [
          IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              width: Get.width,
              decoration: BoxDecoration(
                  color: const Color(0xff353841),
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: TextFormField(
                onFieldSubmitted: (text) {
                  discoverController.searchHashtags(text);
                },
                // initialValue: user.username,

                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 25,
                    color: Colors.grey,
                  ),
                  hintText: "search",
                  hintStyle: const TextStyle(color: Colors.grey),
                  isDense: true,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          )
        ],
      );
}
