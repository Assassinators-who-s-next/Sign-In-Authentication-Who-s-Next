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
  //ScrollController _scrollController = new ScrollController();
  final List<Widget> _players = [];

  @override
  void initState() {
    //for (var cur_player in globals.selectedGroup) {
    for (int i = 0; i < globals.selectedGroup.players.length; i++) {
      player cur_player = globals.selectedGroup.players[i];
      _players.add(LeaderboardElemnt(
          playerName: cur_player.name, playerPoints: cur_player.points));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) => _players[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
