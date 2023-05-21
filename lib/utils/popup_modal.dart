import 'package:flutter/material.dart';

Future showPopup(BuildContext context, {Widget? title, Widget? content, List<Widget>? bottomWidgets, double? height, double? width, bool allowDismissalByTappingOutOfWindow = true})
{
  return showDialog(
    barrierDismissible: allowDismissalByTappingOutOfWindow,
    context: context,
    builder: (_) => AlertDialog(
    title: title,
    content: content != null ? SizedBox(height: height, width: width, child: content) : null,
    actions: bottomWidgets,
    ));
}

Future showSimplePopupWithCancel(BuildContext context, {String? title, String? contentText, double? height, double? width, bool allowDismissalByTappingOutOfWindow = true})
{
  return showSimplePopup(
    context,
    title: title,
    contentText: contentText,
    bottomWidgets: [closeButton(context)], 
    height: height, 
    width: width);
}

Future showSimplePopup(BuildContext context, {String? title, String? contentText, List<Widget>? bottomWidgets, double? height, double? width, bool allowDismissalByTappingOutOfWindow = true})
{
  return showPopup(
    context,
    title: title != null ? Text(title!, style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)) : null,
    content: contentText != null ? Text(contentText!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)) : null,
    bottomWidgets: bottomWidgets, 
    height: height, 
    width: width);
}

Widget closeButton(BuildContext context) => TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(fontSize: 18)));
