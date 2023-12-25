import 'package:flutter/material.dart';
import 'styles.dart';

// ignore: must_be_immutable
class InputLayout extends StatefulWidget {
  String label;
  StatefulWidget inputField;

  InputLayout(
    this.label,
    this.inputField, {
    super.key,
  });

  @override
  State<InputLayout> createState() => _InputLayoutState();
}

class _InputLayoutState extends State<InputLayout> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: headerStyle(level: 3)),
        const SizedBox(height: 5),
        Container(
          child: widget.inputField,
        ),
        const SizedBox(height: 15)
      ],
    );
  }
}

InputDecoration customInputDecoration(String hintText, {Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hintText,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: primaryColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: greyColor),
    ),
  );
}
