import 'package:flutter/material.dart';

class ProfileTextField extends StatefulWidget{
    final String label;
    final String text;
    final ValueChanged<String> onChanged;

    const ProfileTextField({
      Key? key,
      required this.label,
      required this.text,
      required this.onChanged,
    }) : super(key: key);

    @override
    TextFieldWidgetState createState() => TextFieldWidgetState(); 
}

class TextFieldWidgetState extends State<ProfileTextField> {
  late final TextEditingController controller;
  
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        TextField(
          controller: controller,
        ),
    ],
  );
}