import 'package:basic_auth/pages/create_game_page.dart';
import 'package:basic_auth/pages/join_create_game_page.dart';
import 'package:flutter/material.dart';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  List<String> numActiveGames = [
    'Game A',
    'Game B',
    'Game C',
    'Game D',
    'Game E',
    'Game F',
    'Game G',
    'Game H',
    'Game I',
    'Game J',
  ];

  bool? isCheckedBox = false;

  @override
  Widget build(BuildContext context) {
    // for sizing the image
    var screenWidth = MediaQuery.of(context).size.width;

    // if the orientation is landscape, size changes to the height of the device
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      screenWidth = MediaQuery.of(context).size.height;
    }

    return Scaffold(
      // top bar
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('game a'), // could have names of each game, or game code
      ),
      // a list of all games currently in, 3 lines on left
      // TODO: each listTile will change the center and the appBar title
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              GameList(numActiveGames: numActiveGames),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinCreatePage(),
                    ),
                  );
                  //print('go to join/create page');
                },
                child: Text('Join/Create Game'),
              ),
            ],
          ),
        ),
      ),
      // Column wrapped with Widget SingleChildScrollView, so the users can scroll in landscapemode
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: maybe send in the name of the target here?
              TargetName(),
              CircleAvatar(
                maxRadius: screenWidth * 0.35,
                child: Icon(Icons.person, size: screenWidth * 0.4),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.all(40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 238, 127, 119),
                    minimumSize: Size.fromHeight(50),
                    textStyle: TextStyle(fontSize: 25),
                  ),
                  onPressed: () {
                    print('pressed elim button');
                  },
                  child: Text('Eliminate'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GameList extends StatelessWidget {
  const GameList({
    super.key,
    required this.numActiveGames,
  });

  final List<String> numActiveGames;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i in numActiveGames)
          Padding(
            padding: const EdgeInsetsDirectional.all(15),
            child: Text(
              i.toString(),
              style: const TextStyle(fontSize: 17),
              textAlign: TextAlign.right,
            ),
          ),
      ],
    );
  }
}

class TargetName extends StatelessWidget {
  const TargetName({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.all(40),
      child: Text('Target: Username',
          style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
    );
  }
}
