import 'package:flutter/material.dart';

Future showPopup(BuildContext context, Widget title, Widget content, List<Widget> bottomWidgets, double height, double width, {bool allowDismissalByTappingOutOfWindow = true})
{
  return showDialog(
    barrierDismissible: allowDismissalByTappingOutOfWindow,
    context: context,
    builder: (_) => AlertDialog(
    title: title,
    content: Container(child: content, width: height, height: width),
    actions: bottomWidgets,
    ));
}

Future showPopupSimple(BuildContext context, String title, String contentText, List<Widget> bottomWidgets, double height, double width, {bool allowDismissalByTappingOutOfWindow = true})
{
  return showPopup(
    context,
    Text(title, style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    SizedBox(width: height, height: width, child: Text(contentText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    bottomWidgets, 
    height, 
    width);
}

Widget closeButton(BuildContext context) => TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(fontSize: 18)));
