import 'package:basic_auth/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:basic_auth/pages/join_create_game_page.dart';

import '../game_group.dart';
import '../game_group.dart';

class GameListDrawer extends StatelessWidget {
  const GameListDrawer({super.key, required this.screenWidth, required this.screenHeight, required this.content, required this.onSelectGroup});

  final double screenWidth;
  final double screenHeight;
  final Widget content;
  final void Function(Group) onSelectGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top bar
      appBar: AppBar(
        title: Text(selectedGroup.group_name), // could have names of each game, or game code
      ),
      // a list of all games currently in, 3 lines on left
      // TODO: each listTile will change the center and the appBar title
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              GameList(context),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,MaterialPageRoute(
                    builder: (context) => JoinCreatePage(),
                  ));
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

  void OnClickGameListItem(BuildContext context, Group group)
  {
    Navigator.pop(context);
    onSelectGroup.call(group);
  }

  Column GameList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: 
      [
        for (Group group in myGroups)
          GameListItem(group: group, onPressed:(game) => OnClickGameListItem(context, group))
      ],
    );
  }
}

class GameListItem extends StatelessWidget {
  const GameListItem({
    super.key,
    required this.group,
    required this.onPressed
  });

  final Group group;
  final void Function(Group) onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(child: TextButton(onPressed: () => onPressed(group), child: SizedBox(child: Center(child: Text(group.group_name, style: TextStyle(fontSize: 25))), height: 45,))),
        Divider(height: 0,),
      ],
    );
  }
}