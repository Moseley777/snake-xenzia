import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighScoreTile extends StatelessWidget {
  final String documentId;
  const HighScoreTile({super.key,required this.documentId});

  @override
  Widget build(BuildContext context) {
    //get collection of high scores
    CollectionReference highscores = FirebaseFirestore.instance.collection('highscores');
    return FutureBuilder(
      future: highscores.doc(documentId).get(),
       builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          Map<String,dynamic> data = snapshot.data!.data() as  Map<String,dynamic>;
          return Row(
            children: [
              Text(data['score'].toString()),
              SizedBox(width: 10,),
               Text(data['name'])
            ],
          );
        }else{
          return Text('loading...');
        }
       }
       ) ;
  }
}