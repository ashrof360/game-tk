import 'package:hive_flutter/hive_flutter.dart';
import '../models/database/player_profile.dart';

class DatabaseService {
  static const String _boxName = 'player_profile_box';

  /// 1. SETUP DATABASE (Dijalankan di main.dart)
  static Future<void> initDatabase() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PlayerProfileAdapter());
    await Hive.openBox<PlayerProfile>(_boxName);
  }

  /// 2. READ / CREATE (Mengambil data atau membuat baru jika HP baru)
  static PlayerProfile getProfile() {
    var box = Hive.box<PlayerProfile>(_boxName);
    if (box.isEmpty) {
      final defaultProfile = PlayerProfile();
      box.add(defaultProfile);
      return defaultProfile;
    }
    return box.getAt(0)!; // Selalu ambil index 0 karena ini single player
  }

  /// 3. UPDATE DATA
  static Future<void> updateScore(int addedScore) async {
    var profile = getProfile();
    profile.globalScore += addedScore;
    await profile.save(); 
  }

  static Future<void> updateLevel(String categoryName, int newLevel) async {
    var profile = getProfile();
    
    // Pastikan Map diinisialisasi jika masih null
    // ignore: unnecessary_null_comparison
    if (profile.levelProgress == null) {
       profile.levelProgress = {};
    }

    int currentCompleted = profile.levelProgress[categoryName] ?? 0;
    if (newLevel > currentCompleted) {
      profile.levelProgress[categoryName] = newLevel;
      await profile.save();
    }
  }

  static Future<void> recordAnswer({required bool isCorrect}) async {
    var profile = getProfile();
    if (isCorrect) {
      profile.totalCorrectAnswers += 1;
    } else {
      profile.totalWrongAnswers += 1;
    }
    await profile.save();
  }

  static Future<void> setLanguage(bool isIndonesian) async {
    var profile = getProfile();
    profile.isIndonesian = isIndonesian;
    await profile.save();
  }

  static Future<void> setSound(bool isOn) async {
    var profile = getProfile();
    profile.isSoundOn = isOn;
    await profile.save();
  }

  /// 4. DELETE (Mereset progres pemain menjadi 0)
  static Future<void> resetProgress() async {
    var box = Hive.box<PlayerProfile>(_boxName);
    await box.clear();
    // Buat ulang profil default
    box.add(PlayerProfile());
  }
}
