import 'package:flutter/material.dart';

class ProfileTextField extends StatefulWidget{
    final String label;
    final String text;
    final double width;
    final int? maxLines;
    final int? maxLength;
    final ValueChanged<String> onChanged;

    const ProfileTextField({
      Key? key,
      required this.label,
      required this.text,
      required this.width,
      required this.onChanged,
      this.maxLines = 1,
      this.maxLength,
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
  Widget build(BuildContext context)
  {
    var blockSizeHorizontal = widget.width / 100;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: blockSizeHorizontal * 45,
          child: Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
        ),
        SizedBox(
          width: blockSizeHorizontal * 55,
          child: TextField(
            controller: controller,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey
                        .shade400)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}