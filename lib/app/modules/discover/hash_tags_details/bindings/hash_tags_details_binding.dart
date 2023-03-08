import 'package:get/get.dart';

import '../controllers/hash_tags_details_controller.dart';

class HashTagsDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HashTagsDetailsController>(
      () => HashTagsDetailsController(),
    );
  }
}
