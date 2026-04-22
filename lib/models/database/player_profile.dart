import 'package:hive/hive.dart';

part 'player_profile.g.dart';

@HiveType(typeId: 0)
class PlayerProfile extends HiveObject {
  @HiveField(0)
  Map<String, int> levelProgress;

  @HiveField(1)
  int globalScore;

  @HiveField(2)
  int totalCorrectAnswers;

  @HiveField(3)
  int totalWrongAnswers;

  @HiveField(4)
  bool isSoundOn;

  @HiveField(5)
  bool isIndonesian;

  PlayerProfile({
    Map<String, int>? levelProgress,
    this.globalScore = 0,
    this.totalCorrectAnswers = 0,
    this.totalWrongAnswers = 0,
    this.isSoundOn = true,
    this.isIndonesian = true,
  }) : levelProgress = levelProgress ?? {};
}
