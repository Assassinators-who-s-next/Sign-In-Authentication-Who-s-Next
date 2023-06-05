import 'package:basic_auth/networking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:basic_auth/pages/leaderboard.dart';
import 'package:basic_auth/pages/profile.dart';
import 'package:basic_auth/pages/user_home.dart';
import '../globals.dart' as globals;

import '../game_group.dart';
import '../globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    String? name,
    List<Group>? groups,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    LeaderBoard(),
    UserHome(),
    Profile(),
  ];

  Widget LoadingScreen() {
    return Stack(children: [
      /*
        const Opacity(
        opacity: 0.8,
        child: ModalBarrier(dismissible: false, color: Colors.black),
      ),*/
      Center(child: const CircularProgressIndicator()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: finishedLoadingUserController.stream,
          builder: (context, snapshot) {
            if (!finishedLoadingUser && (!snapshot.hasData || !snapshot.data)) return LoadingScreen();
            return Stack(children: [
              _pages[_selectedIndex],
              //if (_selectedIndex < 2)
              if (_selectedIndex < 3)
                SafeArea(
                  child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, right: 4),
                        child: InkWell(child: Icon(Icons.refresh, size: 45), onTap: () => Refresh()),
                      )),
                ),
            ]);
          }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
