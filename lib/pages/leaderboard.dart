import 'package:flutter/material.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/components/leaderboard_element.dart';
import '../player.dart';
import '../game_group.dart';
import '../networking.dart';

import '../globals.dart' as globals;

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({Key? key}) : super(key: key);

  static GlobalKey<_LeaderboardState> leaderboardKey = GlobalKey();

  //_LeaderboardState? myState;

  void reload(BuildContext context) async {
    print("Testing reload 1");
    await reloadSelectedGroup();
    print("Testing reload 2: " + globals.selectedGroup.toString());

    // TODO: figure out how to reload the state
  }

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

void sortPlayers() {
  globals.selectedGroup.players.sort((a, b) => b.points.compareTo(a.points));
}

class _LeaderboardState extends State<LeaderBoard> {
  final List<Widget> _players = [];

  @override
  Widget build(BuildContext context) {
    _players.clear();
    for (int i = 0; i < globals.selectedGroup.players.length; i++) {
      Player cur_player = globals.selectedGroup.players[i];

      String player_name = cur_player.get_name();
      int player_points = cur_player.points;
      var newElement = LeaderboardElement(
          playerName: player_name ?? "unknown",
          playerPoints: player_points ?? 0);
      _players.add(newElement);
    }

    // TODO: sort everytime read from Firebase, need to figure out where in ListView.builder
    _players.sort((a, b) => int.parse((b as LeaderboardElement).getPoints())
        .compareTo(int.parse((a as LeaderboardElement).getPoints())));

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // top info
              const Padding(padding: EdgeInsets.only(top: 10)),
              leaderboardTopInfo(),
              // list of players
              leaderboardPlayerInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded leaderboardPlayerInfo() {
    return Expanded(
      child: ListView.builder(
        itemCount: _players.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: Color.fromARGB(255, 204, 204, 204))),
            ),
            child: ListTile(
              title: _players[index],
              contentPadding:
                  const EdgeInsets.only(top: 5, bottom: 5, right: 15, left: 15),
            ),
          );
        },
      ),
    );
  }

  Column leaderboardTopInfo() {
    return Column(
      children: [
        const Text('Leaderboard',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
        const Padding(padding: EdgeInsets.only(bottom: 10)),
        const Text('Respawn in: xx:xx:xx'),
        const Padding(padding: EdgeInsets.only(bottom: 15)),
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 20, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Players'), Text('Score')],
          ),
        ),
      ],
    );
  }
}
