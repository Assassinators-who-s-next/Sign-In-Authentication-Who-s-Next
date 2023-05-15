import 'package:flutter/material.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/components/leaderboard_element.dart';
import '../player.dart';
import '../game_group.dart';
import '../networking.dart';

import '../globals.dart' as globals;

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({Key? key}) : super(key: key);

  void reload() {
    reloadGroup();
    // leaderboardState?.updatePlayers();
  }

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

void sortPlayers() {
  globals.selectedGroup.players.sort((a, b) => b.points.compareTo(a.points));
}

void reloadGroup() async {
  String groupID = globals.selectedGroup.group_name;
  group fetchedGroup = await loadGroup(groupID);
  globals.selectedGroup = fetchedGroup;

  //replace old instance of group with new one
  for (int i = 0; i < globals.myGroups.length; i++) {
    if (globals.myGroups[i].group_name == groupID) {
      globals.myGroups[i] = fetchedGroup;
    }
  }

  // load names on this group
  applyName(globals.selectedGroup.players);

  print("finished reloading group");
}

class _LeaderboardState extends State<LeaderBoard> {
  final List<Widget> _players = [];

  void updatePlayers() {
    setState(() {
      _players.clear();
      for (int i = 0; i < globals.selectedGroup.players.length; i++) {
        player cur_player = globals.selectedGroup.players[i];
        _players.add(LeaderboardElemnt(
            playerName: cur_player.get_name(),
            playerPoints: cur_player.points));
      }
    });
  }

  @override
  void initState() {
    for (int i = 0; i < globals.selectedGroup.players.length; i++) {
      player cur_player = globals.selectedGroup.players[i];
      _players.add(LeaderboardElemnt(
          playerName: cur_player.get_name(), playerPoints: cur_player.points));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: sort everytime read from Firebase, need to figure out where in ListView.builder
    _players.sort((a, b) => int.parse((b as LeaderboardElemnt).getPoints())
        .compareTo(int.parse((a as LeaderboardElemnt).getPoints())));

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
