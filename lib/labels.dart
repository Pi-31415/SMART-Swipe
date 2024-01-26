import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LabelsPage extends StatefulWidget {
  const LabelsPage({Key? key}) : super(key: key);

  @override
  _LabelsPageState createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  List<String> _labels = [];
  final _controller = TextEditingController();
  bool _isEditing = false;
  int _editingIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadLabels();
  }

  Future<void> _loadLabels() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/labels.txt');
  if (await file.exists()) {
    String fileContents = await file.readAsString();
    List<String> labels = fileContents.split('\n');
    setState(() => _labels = labels.where((label) => label.isNotEmpty).toList());
  }
}


  Future<void> _saveLabels() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/labels.txt');
    await file.writeAsString(_labels.join('\n'));
  }

  void _addOrEditLabel(String label) {
    if (_isEditing) {
      setState(() {
        _labels[_editingIndex] = label;
        _isEditing = false;
      });
    } else {
      setState(() => _labels.add(label));
    }
    _controller.clear();
    _saveLabels();
  }

  void _startEditing(int index) {
    setState(() {
      _controller.text = _labels[index];
      _editingIndex = index;
      _isEditing = true;
    });
  }

  void _deleteLabel(int index) {
    setState(() => _labels.removeAt(index));
    _saveLabels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labels')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: _addOrEditLabel,
              decoration: InputDecoration(
                hintText: 'Add your label here',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _addOrEditLabel(_controller.text),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _labels.length,
                separatorBuilder: (_, __) => const Divider(height: 10),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_labels[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _startEditing(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteLabel(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
