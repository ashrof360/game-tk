import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

enum GameType { shadowMatching, spellingTapping, listenPick, counting }

class GameProvider extends ChangeNotifier {
  Category? _selectedCategory;
  GameType? _currentGameType;
  int _currentScore = 0;
  final Map<String, Set<GameType>> _progress =
      {}; // category name -> completed games

  Category? get selectedCategory => _selectedCategory;
  GameType? get currentGameType => _currentGameType;
  int get currentScore => _currentScore;
  Map<String, Set<GameType>> get progress => _progress;

  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectGameType(GameType gameType) {
    _currentGameType = gameType;
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

  void completeGame() {
    if (_selectedCategory != null && _currentGameType != null) {
      _progress[_selectedCategory!.name] ??= {};
      _progress[_selectedCategory!.name]!.add(_currentGameType!);
      _saveProgress();
      notifyListeners();
    }
  }

  bool isGameCompleted(String categoryName, GameType gameType) {
    return _progress[categoryName]?.contains(gameType) ?? false;
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressString = prefs.getString('game_progress') ?? '{}';
    final progressJson = jsonDecode(progressString) as Map<String, dynamic>;
    _progress.clear();
    progressJson.forEach((key, value) {
      final set = (value as List<dynamic>)
          .map((e) => GameType.values.firstWhere((gt) => gt.toString() == e))
          .toSet();
      _progress[key] = set;
    });
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = _progress.map(
      (key, value) => MapEntry(key, value.map((e) => e.toString()).toList()),
    );
    final progressString = jsonEncode(progressJson);
    await prefs.setString('game_progress', progressString);
  }
}
