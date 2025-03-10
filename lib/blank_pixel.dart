import 'package:flutter/material.dart';

class BlankPixel extends StatefulWidget {
  const BlankPixel({super.key});

  @override
  State<BlankPixel> createState() => _BlankPixelState();
}

class _BlankPixelState extends State<BlankPixel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
       padding: const EdgeInsets.all(2.0),//space between the grids
       child: Container(
         decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(4)
         ),
      ),
    );
  }
}