import 'package:flutter/material.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/components/leaderboard_element.dart';
import '../player.dart';
import '../globals.dart' as globals;

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({Key? key}) : super(key: key);

  static GlobalKey<LeaderboardState> leaderboardKey = GlobalKey();

  void reload(BuildContext context) async {
    await reloadSelectedGroup();
  }

  @override
  LeaderboardState createState() => LeaderboardState();
}

class LeaderboardState extends State<LeaderBoard> {
  List<LeaderboardElement> players = [];

  LeaderboardState() {
    addGroupUpdateListener(onGroupUpdate);
  }

  @override
  void dispose() {
    removeGroupUpdateListener(onGroupUpdate);
    super.dispose();
  }

  void onGroupUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    players.clear();
    List<Player> playerList = globals.selectedGroup.players.values.toList();
    for (int i = 0; i < playerList.length; i++) {
      Player curPlayer = playerList[i];

      String playerName = curPlayer.getName();
      int playerPoints = curPlayer.points;
      var newElement = LeaderboardElement(
          player: curPlayer,
          playerName: playerName,
          playerPoints: playerPoints,
          eliminated: curPlayer.state == PlayerState.dead);
      players.add(newElement);
    }

    players.sort((a, b) => int.parse((b).getPoints()).compareTo(int.parse((a).getPoints())));

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 10)),
              leaderboardTopInfo(),
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
        itemCount: players.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: players[index].eliminated
                  ? const Color.fromARGB(255, 209, 209, 209)
                  : const Color.fromARGB(255, 255, 255, 255),
              border: const Border(
                  bottom: BorderSide(
                      color: Color.fromARGB(255, 204, 204, 204), width: 1)),
            ),
            child: ListTile(
              title: players[index],
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
        const Padding(padding: EdgeInsets.only(bottom: 15)),
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 20, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text('Players'), Text('Eliminations')],
          ),
        ),
      ],
    );
  }
}
