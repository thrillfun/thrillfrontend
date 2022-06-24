import 'add_sound_model.dart';

class PostData{
  String filePath,filterName;
  AddSoundModel? addSoundModel;
  Map? map;

  PostData({required this.filePath, required this.filterName, this.addSoundModel, this.map});
}
