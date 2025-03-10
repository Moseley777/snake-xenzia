import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake/home_page.dart';

class SplashScreen extends StatefulWidget {
   SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double boxWidth = 100;

  double boxheight = 100;

  Color boxColor = Colors.deepPurple;
  

  void _changeBoxSize(){
    setState(() {
      boxWidth = Random().nextInt(400).toDouble();
    });
  }

  void _changeBoxColor(){
    setState(() {
      boxColor = Color.fromRGBO(
        Random().nextInt(256), Random().nextInt(256), Random().nextInt(256),1
      );
    });
  }

   void _changeRadius(){
    setState(() {
      BorderRadius.circular(Random().nextInt(80).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5),(){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyHomePage() ));
    });
    return Center(
      child: AnimatedContainer(
        width: boxWidth,
        height: boxheight,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        decoration:  BoxDecoration(
          color:  boxColor,
          borderRadius: BorderRadius.circular(12)
        ),
      ),
    );
  
  }
}