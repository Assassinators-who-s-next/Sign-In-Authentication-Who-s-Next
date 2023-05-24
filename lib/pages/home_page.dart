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

  void _navigateBottomBar(int index, {bool fetchAgain = true}) {
    setState(() {
      print("Navigate 1");
      _selectedIndex = index;
      if (_pages[_selectedIndex] is LeaderBoard) {
        if (fetchAgain) {
          fetchAndReload();
        }
      }
      print("Navigate 2");
    });
  }

  Future<void> fetchAndReload() async {
    await reloadSelectedGroup();

    int oldIndex = _selectedIndex;
    // _navigateBottomBar(1, fetchAgain: false);
    Future.delayed(Duration(milliseconds: 20), () {
      _navigateBottomBar(1, fetchAgain: false);
      _navigateBottomBar(oldIndex, fetchAgain: false);
      // Navigator.push(context, MaterialPageRoute(builder: (_) => Screen2()));
    });
    // _navigateBottomBar(oldIndex, fetchAgain: false);
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

  void Refresh() async {
    SetFinishedLoadingState(false);
    await reloadSelectedGroup();
    SetFinishedLoadingState(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: finishedLoadingUserController.stream,
          builder: (context, snapshot) {
            if (!finishedLoadingUser && (!snapshot.hasData || !snapshot.data))
              return LoadingScreen();
            return Stack(children: [
              _pages[_selectedIndex],
              if (_selectedIndex < 2)
                SafeArea(
                  child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, right: 4),
                        child: InkWell(
                            child: Icon(Icons.refresh, size: 45),
                            onTap: () => Refresh()),
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
