import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/screen/search_screen.dart';
import 'package:untitled1/src/features/screen/user_profile_screen.dart';
import '../constants.dart';
import 'home_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // Replace with your own page widgets
    SearchScreen(),
    UserProfile(),
  ];

  final List<String> _appBarTitles = [kHomeAppBarText, kSearchSongAppBarText, kProfileAppBarText];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(kOpeningBG),
      appBar: CommonAppBar(appBarText:_appBarTitles[_selectedIndex]),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black45,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
