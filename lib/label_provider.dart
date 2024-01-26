import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelProvider extends ChangeNotifier {
  List<String> _labels = [];

  List<String> get labels => _labels;

  LabelProvider() {
    loadLabels();
  }

  Future<void> loadLabels() async {
    final prefs = await SharedPreferences.getInstance();
    _labels = prefs.getStringList('labels') ?? [];
    notifyListeners();
  }

  void addLabel(String label) {
    if (label.isNotEmpty) {
      _labels.add(label);
      saveLabels();
    }
  }

  void updateLabel(int index, String newLabel) {
    if (newLabel.isNotEmpty) {
      _labels[index] = newLabel;
    } else {
      _labels.removeAt(index);
    }
    saveLabels();
  }

  void removeLabel(int index) {
    _labels.removeAt(index);
    saveLabels();
  }

  Future<void> saveLabels() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('labels', _labels);
    notifyListeners();
  }
}
