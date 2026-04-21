import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

enum GameType { shadowMatching, spellingTapping, listenPick, counting, mixed }

class GameProvider extends ChangeNotifier {
  Category? _selectedCategory;
  GameType? _currentGameType;
  int _currentLevel = 1;
  int _currentScore = 0;
  bool _isIndonesian = true; // default language
  
  
  // category name -> max level completed
  final Map<String, int> _levelProgress = {};

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
        _saveProgress();
      }
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _isIndonesian = !_isIndonesian;
    _saveProgress(); // Use same prefs persistence function
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
    final prefs = await SharedPreferences.getInstance();
    final progressString = prefs.getString('level_progress_v3') ?? '{}';
    try {
      final progressJson = jsonDecode(progressString) as Map<String, dynamic>;
      _levelProgress.clear();
      progressJson.forEach((catKey, levelVal) {
        if (catKey == 'isIndonesian_setting') {
           _isIndonesian = levelVal as bool;
        } else {
           _levelProgress[catKey] = levelVal as int;
        }
      });
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Create a copy of map to append settings since we are serializing everything together for simplicity
    final Map<String, dynamic> dataToSave = Map<String, dynamic>.from(_levelProgress);
    dataToSave['isIndonesian_setting'] = _isIndonesian;

    final progressString = jsonEncode(dataToSave);
    await prefs.setString('level_progress_v3', progressString);
  }
}
