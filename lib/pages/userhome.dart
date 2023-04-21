import 'package:flutter/material.dart';
import 'dart:convert';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    // for sizing the image
    var screenWidth = MediaQuery.of(context).size.width;

    // if the orientation is landscape, size changes to the height of the device
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      screenWidth = MediaQuery.of(context).size.height;
    }

    // TODO: make scrollable when in landscape mode
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
            children: [
              ListTile(
                title: Text('data'),
              )
            ],
          ),
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
              // TODO: increase the font size
              Padding(
                padding: const EdgeInsetsDirectional.all(40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 238, 127, 119),
                      minimumSize: Size.fromHeight(50),
                      textStyle: TextStyle(fontSize: 25)),
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
