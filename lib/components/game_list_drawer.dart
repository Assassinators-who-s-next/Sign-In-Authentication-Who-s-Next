import 'package:whos_next/globals.dart';
import 'package:whos_next/networking.dart';
import 'package:flutter/material.dart';
import 'package:whos_next/pages/join_create_game_page.dart';
import 'package:whos_next/game_group.dart';

class GameListDrawer extends StatelessWidget {
  const GameListDrawer(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.content,
      required this.onSelectGroup});

  final double screenWidth;
  final double screenHeight;
  final Widget content;
  final void Function(Group) onSelectGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedGroup
            .groupName),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              gameList(context),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JoinCreatePage(),
                      ));
                },
                child: const Text('Join/Create Game'),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(child: content),
    );
  }

  void onClickGameListItem(BuildContext context, Group group) async {
    Navigator.pop(context);
    if (selectedGroup == group) return;
    if (group.state == GroupState.running) {
      await setCurrTarget(await getCurrTargetUid(playerUID: myUserData.uid, groupCode: group.groupName));
    }

    onSelectGroup.call(group);
  }

  Column gameList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (Group group in myGroups)
          GameListItem(
              group: group,
              onPressed: (game) => onClickGameListItem(context, group))
      ],
    );
  }
}

class GameListItem extends StatelessWidget {
  const GameListItem({super.key, required this.group, required this.onPressed});

  final Group group;
  final void Function(Group) onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
            child: TextButton(
                onPressed: () => onPressed(group),
                child: SizedBox(
                  height: 45,
                  child: Center(
                      child: Text(group.groupName,
                          style: const TextStyle(fontSize: 25))),
                ))),
        const Divider(
          height: 0,
        ),
      ],
    );
  }
}
