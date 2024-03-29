import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for key events
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeginLabellingPage extends StatefulWidget {
  const BeginLabellingPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BeginLabellingPageState createState() => _BeginLabellingPageState();
}

class _BeginLabellingPageState extends State<BeginLabellingPage> {
  List<File> _imageFiles = [];
  late List<String> _labels;
  late int _currentImageIndex;
  late Set<String> _selectedLabels;
  late SharedPreferences _prefs;
  late FocusNode _focusNode; // For Key Bindings
  @override
  void initState() {
    super.initState();
    _initialize();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _resetIndices() async {
    // Reset the current image index
    _currentImageIndex = 0;
    // Save the reset index in shared preferences
    await _prefs.setInt('lastLabelledImageIndex', _currentImageIndex);
    // Reload selected labels for the first image
    _selectedLabels =
        await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
    // Update the UI
    setState(() {});
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _currentImageIndex = _prefs.getInt('lastLabelledImageIndex') ?? 0;
    // Load labels and image files
    _labels = await _loadLabels();
    _imageFiles = await _loadImageFiles();
    _selectedLabels =
        await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
    setState(() {});
  }

  Future<List<String>> _loadLabels() async {
    final directory = await getApplicationDocumentsDirectory();
    final labelsFile = File('${directory.path}/labels.txt');
    if (await labelsFile.exists()) {
      List<String> labels = await labelsFile.readAsLines();
      return labels;
    }
    return [];
  }

  Future<List<File>> _loadImageFiles() async {
    // Retrieve the saved image folder path
    final folderPathFile = await _getLocalFile('folder_path.txt');
    if (!await folderPathFile.exists()) {
      _showAlert('Folder path is not set.');
      return [];
    }

    String folderPath = await folderPathFile.readAsString();
    final imageDirectory = Directory(folderPath);

    if (!await imageDirectory.exists()) {
      _showAlert('Selected folder does not exist.');
      return [];
    }

    return imageDirectory
        .listSync()
        .whereType<File>()
        .where((file) => _isImageFile(file.path))
        .toList();
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
        );
      },
    );
  }

  bool _isImageFile(String filePath) {
    var extension = filePath.split('.').last.toLowerCase();
    return ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].contains(extension);
  }

  Future<Set<String>> _loadSelectedLabels(File image) async {
    String txtFilePath = image.path.replaceAll(RegExp(r'\.[^\.]+$'), '.txt');
    File txtFile = File(txtFilePath);
    if (await txtFile.exists()) {
      List<String> labels = await txtFile.readAsLines();
      return labels.toSet();
    }
    return {};
  }

  Future<void> _toggleLabel(String label) async {
    if (_selectedLabels.contains(label)) {
      _selectedLabels.remove(label);
    } else {
      _selectedLabels.add(label);
    }
    await _saveLabelsToFile();
    setState(() {});
  }

  Future<void> _saveLabelsToFile() async {
    String txtFilePath = _imageFiles[_currentImageIndex]
        .path
        .replaceAll(RegExp(r'\.[^\.]+$'), '.txt');
    File txtFile = File(txtFilePath);
    await txtFile.writeAsString(_selectedLabels.join('\n'));
  }

  Future<void> _goToNextImage() async {
    if (_currentImageIndex < _imageFiles.length - 1) {
      _currentImageIndex++;
      await _prefs.setInt('lastLabelledImageIndex', _currentImageIndex);
      _selectedLabels =
          await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
      setState(() {});
    }
  }

  Future<void> _goToPreviousImage() async {
    if (_currentImageIndex > 0) {
      _currentImageIndex--;
      await _prefs.setInt('lastLabelledImageIndex', _currentImageIndex);
      _selectedLabels =
          await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
      setState(() {});
    }
  }

  // New method to handle key events
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyP) {
        _goToNextImage();
      } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
        _goToPreviousImage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Labelling Area'),
        ),
        body: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          autofocus: true,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                print("KeyboardListener has focus");
              } else {
                print("KeyboardListener lost focus");
              }
            },
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: _imageFiles.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      // Added to ensure the page is scrollable
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(
                              value:
                                  _currentImageIndex / (_imageFiles.length - 1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Wrap(
                              spacing: 8.0, // Space between chips
                              children: _labels.map((label) {
                                bool isSelected =
                                    _selectedLabels.contains(label);
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    _toggleLabel(label);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _goToPreviousImage,
                                  child: const Text('Previous Image (I)'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      _resetIndices, // The new reset button
                                  child: const Text('Go to first image'),
                                ),
                                ElevatedButton(
                                  onPressed: _goToNextImage,
                                  child: const Text('Next Image (P)'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AspectRatio(
                              aspectRatio: 16 / 4,
                              child: Image.file(
                                _imageFiles[_currentImageIndex],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ));
  }
}
