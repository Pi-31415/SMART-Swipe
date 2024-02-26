import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class AdminPanel extends StatefulWidget {
  final Function(bool) onFolderSelected;
  const AdminPanel({Key? key, required this.onFolderSelected})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with AutomaticKeepAliveClientMixin {
  String _imageFolderPath = 'No folder selected';
  List<File> _imageFiles = [];
  int _currentPage = 0;
  static const int _imagesPerPage = 12;

  @override
  bool get wantKeepAlive => true;

  // ignore: unnecessary_overrides, unnecessary_overrides
  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadImages(String folderPath) async {
    Directory dir = Directory(folderPath);
    List<File> imageFiles = [];
    var files = dir.listSync();
    for (var file in files) {
      if (file is File && _isImageFile(file.path)) {
        imageFiles.add(file);
        await _createTextFileForImage(file);
      }
    }
    if (mounted) {
      setState(() {
        _imageFiles = imageFiles;
      });
    }
  }

  bool _isImageFile(String filePath) {
    var extension = filePath.split('.').last.toLowerCase();
    return ['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(extension);
  }

  Future<void> _createTextFileForImage(File imageFile) async {
    String txtFilePath =
        imageFile.path.replaceAll(RegExp(r'\.[^\.]+$'), '.txt');
    File txtFile = File(txtFilePath);
    if (!await txtFile.exists()) {
      await txtFile.create();
    }
  }

  Future<File> _saveFolderPath(String path) async {
    final file = await _getLocalFile('folder_path.txt');
    return file.writeAsString(path);
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  Future<void> _selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _imageFolderPath = selectedDirectory;
        _currentPage =
            0; // Reset to the first page whenever a new folder is selected
      });
      await _saveFolderPath(selectedDirectory);
      await _loadImages(selectedDirectory);
      widget.onFolderSelected(true); // Notify that folder is selected
    } else {
      // Handle the case when selectedDirectory is null
      // For example, show an error message or set a default value
      widget.onFolderSelected(false); // Notify that folder is not selected
    }
  }

  List<File> _getImagesForCurrentPage() {
    int startIndex = _currentPage * _imagesPerPage;
    int endIndex = startIndex + _imagesPerPage;
    return _imageFiles.sublist(
        startIndex, endIndex.clamp(0, _imageFiles.length));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is required for AutomaticKeepAliveClientMixin

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              if (_imageFiles.isEmpty) const Text('Welcome to SMART Swipe.'),
              const SizedBox(height: 10),
              // Show text if image Folder is empty
              if (_imageFiles.isEmpty)
                const Text(
                    'First, select an Image folder, then edit your labels. Then you may begin labelling.'),
              const SizedBox(height: 10),
              Text('Image Folder Path: $_imageFolderPath'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectFolder,
                child: const Text('Select Image Folder'),
              ),
              const SizedBox(height: 20),
              _buildImageGrid(),
              _buildPaginationControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    var imagesToShow = _getImagesForCurrentPage();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // Adjust number for grid column count
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: imagesToShow.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: const EdgeInsets.all(4),
          child: Image.file(
            imagesToShow[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              _currentPage > 0 ? () => setState(() => _currentPage--) : null,
        ),
        Text(
            'Page ${_currentPage + 1} of ${(_imageFiles.length / _imagesPerPage).ceil()}'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed:
              _currentPage < (_imageFiles.length / _imagesPerPage).ceil() - 1
                  ? () => setState(() => _currentPage++)
                  : null,
        ),
      ],
    );
  }
}
