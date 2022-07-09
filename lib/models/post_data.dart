
import 'package:thrill/models/add_sound_model.dart';

class PostData{
  String filePath,filterName;
  AddSoundModel? addSoundModel;
  Map? map;
  bool isDuet;
  String? downloadedDuetFilePath;

  PostData({required this.filePath, required this.filterName, this.addSoundModel, this.map, required this.isDuet, this.downloadedDuetFilePath});
}
