import 'package:flutter/material.dart';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top bar
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('game a'), // could have names of each game, or game code
      ),
      // a list of all games currently in, 3 lines on left
      // TODO: each listTile will change the center and the appBar title
      drawer: Drawer(
        child: ListView(children: [
          ListTile(
            title: Text('data'),
          )
        ]),
      ),
      // TODO  target info
      body: const Center(
        child: Text('HOme page'),
      ),
    );
  }
}
