import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:basic_auth/pages/join_create_game_page.dart';

class GameListDrawer extends StatelessWidget {
  const GameListDrawer({super.key, required this.numActiveGames, required this.screenWidth, required this.screenHeight, required this.content});

  final List<String> numActiveGames;
  final double screenWidth;
  final double screenHeight;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top bar
      appBar: AppBar(
        title: Text('game code should be here'), // could have names of each game, or game code
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

                  Navigator.pushReplacement(context,MaterialPageRoute(
                    builder: (context) => JoinCreatePage(),
                  ));
                  //print('go to join/create page');
                },
                child: Text('Join/Create Game'),
              ),
            ],
          ),
        ),
      ),
      // Column wrapped with Widget SingleChildScrollView, so the users can scroll in landscapemode
      body: SingleChildScrollView(child: content),
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
