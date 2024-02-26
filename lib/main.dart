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
      title: 'SMART-Swipe 2.0', // Set your custom title here
      themeMode: ThemeMode.dark, // Use dark theme mode
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // You can customize your dark theme further if needed
      ),
      home: const MainTabs(),
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
            const Tab(text: 'Admin Panel'),
            const Tab(text: 'Labels'),
            Tab(
              icon: isFolderSelected ? null : const Icon(Icons.lock),
              text: 'Normal Labelling',
            ),
            Tab(
              icon: isFolderSelected ? null : const Icon(Icons.lock),
              text: 'Tinder Mode',
            ),
            const Tab(text: 'Developer Info'),
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
