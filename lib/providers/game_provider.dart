import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_service.dart';

enum GameType { shadowMatching, spellingTapping, listenPick, counting, mixed }

class GameProvider extends ChangeNotifier {
  Category? _selectedCategory;
  GameType? _currentGameType;
  int _currentLevel = 1;
  int _currentScore = 0;
  bool _isIndonesian = true;
  final Map<String, int> _levelProgress = {};

  // Read defaults from Hive directly
  void _syncFromDatabase() {
    final profile = DatabaseService.getProfile();
    _currentScore = profile.globalScore;
    _isIndonesian = profile.isIndonesian;
    _levelProgress.clear();
    _levelProgress.addAll(profile.levelProgress);
    notifyListeners();
  }

  Category? get selectedCategory => _selectedCategory;
  GameType? get currentGameType => _currentGameType;
  int get currentLevel => _currentLevel;
  int get currentScore => _currentScore;
  bool get isIndonesian => _isIndonesian;

  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectGameType(GameType gameType) {
    _currentGameType = gameType;
    _currentScore = 0;
    notifyListeners();
  }

  void selectLevel(int level) {
    _currentLevel = level;
    _currentScore = 0;
    notifyListeners();
  }

  void incrementScore() {
    _currentScore++;
    DatabaseService.updateScore(1); 
    notifyListeners();
  }

  void resetScore() {
    _currentScore = 0;
    notifyListeners();
  }

  void completeLevel() {
    if (_selectedCategory != null) {
      final categoryName = _selectedCategory!.name;
      
      final completedLevel = _levelProgress[categoryName] ?? 0;
      
      if (_currentLevel > completedLevel) {
        _levelProgress[categoryName] = _currentLevel;
        DatabaseService.updateLevel(categoryName, _currentLevel);
      }
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _isIndonesian = !_isIndonesian;
    DatabaseService.setLanguage(_isIndonesian);
    notifyListeners();
  }

  int getHighestLevelCompleted(String categoryName) {
    return _levelProgress[categoryName] ?? 0;
  }

  bool isLevelUnlocked(String categoryName, int level) {
    if (level == 1) return true;
    final highest = getHighestLevelCompleted(categoryName);
    return level <= highest + 1;
  }

  Future<void> loadProgress() async {
    _syncFromDatabase();
  }
}
