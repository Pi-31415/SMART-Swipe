import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TinderModeLabellingPage extends StatefulWidget {
  const TinderModeLabellingPage({Key? key}) : super(key: key);

  @override
  _TinderModeLabellingPageState createState() =>
      _TinderModeLabellingPageState();
}

class _TinderModeLabellingPageState extends State<TinderModeLabellingPage> {
  List<File> _imageFiles = [];
  late List<String> _labels;
  late int _currentLabelIndex;
  late int _currentImageIndex;
  late SharedPreferences _prefs;
  late Set<String> _selectedLabels;
  late int _totalSteps;
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();

    _labels = await _loadLabels();
    _imageFiles = await _loadImageFiles();

    // Change this to load the last step instead of the last labelled image index
    _currentStep = _prefs.getInt('lastStep') ?? 0;
    _currentLabelIndex = _currentStep ~/ _imageFiles.length;
    _currentImageIndex = _currentStep % _imageFiles.length;

    _selectedLabels =
        await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
    _totalSteps = _labels.length * _imageFiles.length;

    setState(() {});
  }

  Future<void> _goToNextStep() async {
    if (_currentStep < _totalSteps - 1) {
      _currentStep++;
      _updateStepIndices();
      await _prefs.setInt('lastStep', _currentStep);
      _selectedLabels =
          await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
      setState(() {});
    }
  }

  Future<void> _goToPreviousStep() async {
    if (_currentStep > 0) {
      _currentStep--;
      _updateStepIndices();
      await _prefs.setInt('lastStep', _currentStep);
      _selectedLabels =
          await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
      setState(() {});
    }
  }

  void _updateStepIndices() {
    _currentLabelIndex = _currentStep ~/ _imageFiles.length;
    _currentImageIndex = _currentStep % _imageFiles.length;
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

  Future<void> _goToPreviousImage() async {
    if (_currentImageIndex > 0) {
      _currentImageIndex--;
      _selectedLabels =
          await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
      setState(() {});
    }
  }

  Future<void> _goToNextImage() async {
    if (_currentImageIndex < _imageFiles.length - 1) {
      _currentImageIndex++;
      _selectedLabels =
          await _loadSelectedLabels(_imageFiles[_currentImageIndex]);
      setState(() {});
    }
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

  Future<void> _handleLabelResponse(bool labelApplies) async {
    String currentLabel = _labels[_currentLabelIndex];
    if (labelApplies) {
      _selectedLabels.add(currentLabel);
    } else {
      _selectedLabels.remove(currentLabel);
    }

    await _saveLabelsToFile();
    await _goToNextStep();
  }

  Future<void> _saveLabelsToFile() async {
    if (_selectedLabels.isNotEmpty) {
      String txtFilePath = _imageFiles[_currentImageIndex]
          .path
          .replaceAll(RegExp(r'\.[^\.]+$'), '.txt');
      File txtFile = File(txtFilePath);
      await txtFile.writeAsString(_selectedLabels.join('\n'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinder Mode Labelling'),
      ),
      body: _imageFiles.isEmpty || _labels.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _currentStep / (_totalSteps - 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: _goToPreviousStep,
                          child: const Text('Previous'),
                          // rest of the button styling
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: _goToNextStep,
                          child: const Text('Next'),
                          // rest of the button styling
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'Does this image contain "${_labels[_currentLabelIndex]}"?'),
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 5,
                    child: Image.file(
                      _imageFiles[_currentImageIndex],
                      fit: BoxFit.contain,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: () => _handleLabelResponse(true),
                          child: const Text('Yes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedLabels
                                    .contains(_labels[_currentLabelIndex])
                                ? Colors.green
                                : null,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton(
                          onPressed: () => _handleLabelResponse(false),
                          child: const Text('No'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_selectedLabels
                                    .contains(_labels[_currentLabelIndex])
                                ? Colors.red
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
