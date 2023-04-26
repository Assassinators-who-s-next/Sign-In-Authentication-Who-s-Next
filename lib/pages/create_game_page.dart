import 'package:flutter/material.dart';

class CreateGamePage extends StatefulWidget {
  @override
  State<CreateGamePage> createState() => _CreateGamePage();
}

class _CreateGamePage extends State<CreateGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Create Game'),
          backgroundColor: Colors.orange),
      body: SafeArea(
//        child: Column(
//          textDirection: TextDirection.ltr,
//          children: [
//            Text('hello'),
//          ],
//        ),
        child: ListView(
          padding: EdgeInsets.only(left: 20, top: 20),
          children: [
            Text(
              'Time:',
              style: TextStyle(fontSize: 20),
            ),
//            Padding(
//              padding: EdgeInsets.only(left: 20, top: 20),
//              child: Text(
//                'hello',
//                style: TextStyle(fontSize: 20),
//              ),
//            ),
          ],
        ),
      ),
    );
  }
}
