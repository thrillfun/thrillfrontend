// import 'package:flutter/material.dart';
//
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// import '../../../../rest/rest_urls.dart';
// import '../../../../routes/app_pages.dart';
// import '../../../../utils/utils.dart';
// import '../controllers/select_sound_controller.dart';
//
// class SelectSoundView extends GetView<SelectSoundController> {
//   const SelectSoundView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: controller.obx(
//           (state) => state!.isEmpty
//               ? Column(
//                   children: [emptyListWidget()],
//                 )
//               : ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: state!.length,
//                   itemBuilder: (context, index) => InkWell(
//                         child: Container(
//                           margin: const EdgeInsets.all(10),
//                           padding: const EdgeInsets.all(10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       Image.asset(
//                                         "assets/Image.png",
//                                         height: 80,
//                                         width: 80,
//                                       ),
//                                       Container(
//                                         height: 40,
//                                         width: 40,
//                                         child: imgProfile(
//                                             state[index].soundOwner != null
//                                                 ? state[index]
//                                                     .soundOwner!
//                                                     .avtars
//                                                     .toString()
//                                                 : RestUrl.placeholderImage),
//                                       )
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     width: 10,
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         state[index].sound.toString(),
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.w700,
//                                             fontSize: 18),
//                                       ),
//                                       Text(
//                                         state[index]
//                                             .soundOwner!
//                                             .name
//                                             .toString(),
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: 14),
//                                       ),
//                                       Text(
//                                         state[index]
//                                             .soundOwner!
//                                             .name
//                                             .toString(),
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 state[index]
//                                     .soundOwner!
//                                     .followersCount
//                                     .toString(),
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w600, fontSize: 14),
//                               )
//                             ],
//                           ),
//                         ),
//                         onTap: () async {
//
//                           Get.back(result: {
//                             "selected_sound": state[index].sound.obs
//                           });
//                           GetStorage().write("selected_sound", state[index].sound.obs
//                           );
//                         },
//                       )),
//           onEmpty: Column(
//             children: [emptyListWidget()],
//           ),
//           onLoading: Container(
//             child: loader(),
//             height: Get.height,
//             width: Get.width,
//           )),
//     );
//   }
// }
