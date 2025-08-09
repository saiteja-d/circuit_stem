import 'package:flutter/material.dart';

class HintChip extends StatelessWidget {
  final String hintText;
  final Color? color;

  const HintChip({Key? key, required this.hintText, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Fixed const
      padding: const EdgeInsets.all(8.0), // Fixed const
      decoration: BoxDecoration(
        color: color ?? Colors.amber,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(hintText),
    );
  }
}