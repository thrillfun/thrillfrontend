
import 'package:thrill/models/add_sound_model.dart';

class PostData{
  String filePath, filterName;
  AddSoundModel? addSoundModel;
  bool isDuet, isDefaultSound, isUploadedFromGallery;
  String? duetPath, newPath, newName, duetFrom, duetSoundName, duetSound;
  String speed;
  int trimStart, trimEnd;

  PostData({
    required this.speed,
    required this.filePath,
    required this.filterName,
    this.addSoundModel,
    required this.trimStart,
    required this.isDuet,
    this.duetPath,
    required this.isDefaultSound,
    required this.trimEnd,
    required this.isUploadedFromGallery,
    this.newPath,
    this.newName,
    this.duetFrom,
    this.duetSoundName,
    this.duetSound
  });
}
