import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

enum GameType { shadowMatching, spellingTapping, listenPick, counting }

class GameProvider extends ChangeNotifier {
  Category? _selectedCategory;
  GameType? _currentGameType;
  int _currentLevel = 1;
  int _currentScore = 0;
  
  // category name -> { game type description -> max level completed }
  final Map<String, Map<String, int>> _levelProgress = {};

  Category? get selectedCategory => _selectedCategory;
  GameType? get currentGameType => _currentGameType;
  int get currentLevel => _currentLevel;
  int get currentScore => _currentScore;

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
    notifyListeners();
  }

  void resetScore() {
    _currentScore = 0;
    notifyListeners();
  }

  void completeLevel() {
    if (_selectedCategory != null && _currentGameType != null) {
      final categoryName = _selectedCategory!.name;
      final gameTypeName = _currentGameType!.toString();
      
      _levelProgress[categoryName] ??= {};
      final completedLevel = _levelProgress[categoryName]![gameTypeName] ?? 0;
      
      if (_currentLevel > completedLevel) {
        _levelProgress[categoryName]![gameTypeName] = _currentLevel;
        _saveProgress();
      }
      notifyListeners();
    }
  }

  int getHighestLevelCompleted(String categoryName, GameType gameType) {
    return _levelProgress[categoryName]?[gameType.toString()] ?? 0;
  }

  bool isLevelUnlocked(String categoryName, GameType gameType, int level) {
    if (level == 1) return true;
    final highest = getHighestLevelCompleted(categoryName, gameType);
    return level <= highest + 1;
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressString = prefs.getString('level_progress_v2') ?? '{}';
    try {
      final progressJson = jsonDecode(progressString) as Map<String, dynamic>;
      _levelProgress.clear();
      progressJson.forEach((catKey, catValue) {
        final gameMap = (catValue as Map<String, dynamic>).map(
          (gameKey, levelVal) => MapEntry(gameKey, levelVal as int),
        );
        _levelProgress[catKey] = gameMap;
      });
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressString = jsonEncode(_levelProgress);
    await prefs.setString('level_progress_v2', progressString);
  }
}
