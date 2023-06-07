import 'package:whos_next/networking.dart';
import 'package:flutter/material.dart';
import 'package:whos_next/pages/leaderboard.dart';
import 'package:whos_next/pages/profile.dart';
import 'package:whos_next/pages/user_home.dart';
import 'package:whos_next/globals.dart' as globals;
import 'package:whos_next/game_group.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    String? name,
    List<Group>? groups,
  });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int selectedIndex = 1;

  void navigateBottomBar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> pages = [
    const LeaderBoard(),
    const UserHome(),
    const Profile(),
  ];

  Widget loadingScreen() {
    return Stack(children: const [
      Center(child: CircularProgressIndicator()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: globals.finishedLoadingUserController.stream,
          builder: (context, snapshot) {
            if (!globals.finishedLoadingUser && (!snapshot.hasData || !snapshot.data)) return loadingScreen();
            return Stack(children: [
              pages[selectedIndex],
              if (selectedIndex < 3)
                SafeArea(
                  child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, right: 4),
                        child: InkWell(child: const Icon(Icons.refresh, size: 45), onTap: () => refresh()),
                      )),
                ),
            ]);
          }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: navigateBottomBar,
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
