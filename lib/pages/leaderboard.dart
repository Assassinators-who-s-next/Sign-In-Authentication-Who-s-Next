import 'package:flutter/material.dart';
import 'package:basic_auth/networking.dart';
import 'package:basic_auth/components/leaderboard_element.dart';
import '../player.dart';

import '../globals.dart' as globals;

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({Key? key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<LeaderBoard> {
  final List<Widget> _players = [];

  @override
  void initState() {
    for (int i = 0; i < globals.selectedGroup.players.length; i++) {
      player cur_player = globals.selectedGroup.players[i];
      _players.add(LeaderboardElemnt(
          playerName: cur_player.name, playerPoints: cur_player.points));
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
              Column(
                children: [
                  const Text('Leaderboard',
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                  const Padding(padding: EdgeInsets.only(bottom: 10)),
                  const Text('Respawn in: xx:xx:xx'),
                  const Padding(padding: EdgeInsets.only(bottom: 15)),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 5, left: 20, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Players'), Text('Score')],
                    ),
                  ),
                ],
              ),

              // list of players
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color.fromARGB(255, 204, 204, 204))),
                      ),
                      child: ListTile(
                        title: _players[index],
                        contentPadding: const EdgeInsets.only(
                            top: 5, bottom: 5, right: 15, left: 15),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
