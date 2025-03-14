import 'package:flutter/material.dart';

class FoodPixel extends StatelessWidget {
  const FoodPixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
       padding: const EdgeInsets.all(2.0),//space between the grids
       child: Container(
         decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(4)
         ),
      ),
    );
  }
}