import 'package:flutter/material.dart';
import 'admin_panel.dart';
import 'labels.dart';
import 'beginlabelling.dart';
import 'tindermode.dart';
import 'author_info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMART-Swipe 2.0',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const MainTabs(),
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({Key? key}) : super(key: key);

  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFolderSelected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  void _handleFolderSelection(bool isSelected) {
    setState(() {
      isFolderSelected = isSelected;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMART Swipe 2.0'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin Panel'),
            Tab(icon: Icon(Icons.label), text: 'Labels'),
            Tab(
              icon: isFolderSelected ? Icon(Icons.check_box) : Icon(Icons.lock),
              text: 'Review Labels',
            ),
            Tab(
              icon: isFolderSelected ? Icon(Icons.edit) : Icon(Icons.lock),
              text: 'Label Images',
            ),
            Tab(icon: Icon(Icons.person), text: 'Developer Info'),
          ],
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AdminPanel(onFolderSelected: _handleFolderSelection),
          const LabelsPage(),
          isFolderSelected
              ? const BeginLabellingPage()
              : Center(
                  child: Text("Choose an image folder first",
                      style: TextStyle(fontSize: 18))),
          isFolderSelected
              ? const TinderModeLabellingPage()
              : Center(
                  child: Text("Choose an image folder first",
                      style: TextStyle(fontSize: 18))),
          const AuthorInfoPage(),
        ],
      ),
    );
  }
}
