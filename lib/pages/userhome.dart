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
                // TODO: link button to join/create game page
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinCreatePage(),
                      //builder: (context) => CreateGamePage(),
                    ),
                  );
                  //print('go to join/create page');
                },
                child: Text('Join/Create Game'),
              ),
//            Expanded(
//              child: Align(
//                alignment: Alignment.bottomCenter,
//                child: Checkbox(
//                  value: isCheckedBox,
//                  onChanged: (bool? clickedChecked) {
//                    setState(() {
//                      isCheckedBox = clickedChecked;
//                    });
//                  },
//                ),
//              ),
//            ),

//            Checkbox(
//                value: isCheckedBox,
//                onChanged: (bool? clickedChecked) {
//                  setState(() {
//                    isCheckedBox = clickedChecked;
//                  });
//                })
            ],
          ),
          //child: GameList(),
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
//    return ListView.builder(
//      // TODO: num of games the player is it
//      // TODO: receive information on the number of games the player is in
//      itemCount: numActiveGames.length,
//      itemBuilder: (BuildContext context, int index) {
//        return ListTile(
//          //title: Text('game ${index + 1}'),
//          title: Text('${numActiveGames[index]}'),
//        );
//        // need button widget for "create/join game"
//      },
//    );
//    return (for (var i = 0; i < numActiveGames.length; ++i) {
//      Text('${numActiveGames[i]}');
//    }
//    return Text('finished');
//    return Text('$numActiveGames');
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

//class GameList extends StatelessWidget {
//  const GameList({
//    super.key,
//  });
//
//  final numActiveGames = 10;
//  @override
//  Widget build(BuildContext context) {
//    return ListView.builder(
//      // TODO: num of games the player is it
//      // TODO: receive information on the number of games the player is in
//      itemCount: numActiveGames,
//      itemBuilder: (BuildContext context, int index) {
//        return ListTile(
//          title: Text('game ${index + 1}'),
//        );
//        // need button widget for "create/join game"
//      },
//    );
//  }
//}

//class EliminateButton extends StatelessWidget {
//  const EliminateButton({
//    super.key,
//  });
//
//  @override
//  Widget build(BuildContext context) {
//    return const Padding(
//      padding: EdgeInsetsDirectional.all(40),
//      child: Card(
//        color: Color.fromARGB(255, 234, 118, 110),
//        child: Padding(
//          padding: EdgeInsets.all(30),
//          child: FittedBox(
//            fit: BoxFit.fitWidth,
//            child: Text('Eliminate'),
//          ),
//        ),
//      ),
//    );
//  }
//}

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
