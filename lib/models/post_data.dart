
import 'package:thrill/models/add_sound_model.dart';

class PostData{
  String filePath,filterName;
  AddSoundModel? addSoundModel;
  Map? map;
  bool isDuet;
  String? downloadedDuetFilePath;
  String speed;

  PostData({required this.speed, required this.filePath, required this.filterName, this.addSoundModel, this.map, required this.isDuet, this.downloadedDuetFilePath});
}
