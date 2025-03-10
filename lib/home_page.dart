import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake/blank_pixel.dart';
import 'package:snake/food_pixel.dart';
import 'package:snake/highscore_tile.dart';
import 'package:snake/snake_pixel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


enum snake_Direction {UP, DOWN, LEFT, RIGHT}
class _MyHomePageState extends State<MyHomePage> {
  //storing grid dimensions as variables
  int rowSize = 10;    //our crossAxiscount
  int totalNumberOfSquares = 100;//this is our item count(instead of storing as variables)
  
  int currentScore = 0;

  //to make sure the play button is not clickable during play already..when game starts
  bool gameHasStarted = false;
  //this tracks whether the game is paused or not
  bool isPaused = false;
  final _nameController = TextEditingController();

  StreamSubscription? gameStream;  

 late StreamController gameStreamController;     //StreamController to manae the flow based on pause state

  //snake position
  List<int> snakePosition = [
    1,
    2,
    3,
  ];

  //snake direcctiom is initially to the right
  var currentDirection = snake_Direction.RIGHT;

  //food location
  int foodPosition = 67;

  @override
  void initState(){
    letsGetDocIds = getDocId();
    super.initState();
    gameStreamController= StreamController();
  }

 Future getDocId()async{
  await FirebaseFirestore.instance
  .collection('highscores')
  .orderBy('score',descending: true )
  .limit(10)
  .get()
  .then((value) => value.docs.forEach((element) {
    highscoreDocsIds.add(element.reference.id);
  })); 
 }
  @override
  void dispose(){   
    gameStream?.cancel(); //cancelling the timer in dispose method to handle resource leaks

    super.dispose();
  
  }
  //method to swth thepause state of te game
  void togglePause(){
    setState(() {
      isPaused=!isPaused;
    });
  }

  //M3THOD TO SART GAME
  void startGame(){
    gameHasStarted = true;
    isPaused = false;
    //EVERY 200mS we add a new head and remove the tail
    gameStream = Stream.periodic(const Duration(milliseconds: 150)).listen((_) {  // subsribing to the stream by listening to it
      if(isPaused) return;  //it skips the game logic update..it skips the rest of thwe function when..if is paused return nothing..return ends the function immediately
      setState(() {
        //keep the snake moving
       moveSnake();  

       //check if the game is over
       if (gameOver()) {   //if its true end game by cancelling the gameStream..the game starts with a timer initially
        
         gameStream?.cancel(); //timer.cancel()  
         gameStream = null;

        //   newGame();   //making sure we reset the gameState also so we cann start a new one without pressing the submit button e.g phone back button 
        
        //display a message to the user also
        showDialog(
          barrierDismissible:  false,
          context: context,
         builder: (context){
           return  WillPopScope(
            onWillPop: ()async{
              newGame();
              return true;
            },
             child: AlertDialog(
              title:  Text('Game Over'),
              content: Container(width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text('Your Score is ${currentScore.toString()}'),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Name',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: (){
                    if (_nameController.text.isNotEmpty){
                    submitScore();    //when game is over we submit score
                    Navigator.pop(context); //navigate back to the game screen(HomePage)
                    _nameController.clear();
                    newGame(); 
                      }  else{      //we also start new game
/*SNACKBAR*/            ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                         content: Text('Name cannot be empty!'),
                         duration: Duration(seconds: 2),
                         ),
                        );
                      }
                  },
                  child: Text('Submit'),
                  color: Colors.pink,
                  )
              ],
             ),
           );
         }
         );

     /*     Future.delayed(Duration(seconds: 1),(){ //using a future so the current score can display before it restarts 
            newGame(); //making sure we reset the gameState also so we cann start a new one without pressing the submit button e.g phone back button 
        
          });*/
       }  
       
      });
    });
  }

  //submit score
  void submitScore(){
  
   if (_nameController.text.trim().isEmpty) {
    // Show a SnackBar with an error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Name cannot be empty!'),
        duration: const Duration(seconds: 2),
      ),
    );
    return; // Exit the method if the name is empty
  }else{

     

     //get access to collection
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      'name': _nameController.text,
      'score': currentScore,
     }     
    );
 
  }
  }

  //highscore list
  List<String> highscoreDocsIds =[];
  late final Future? letsGetDocIds;

//anytime we click new game,we reload the data
  Future newGame()async{  //just ressetting the values to the original
    highscoreDocsIds =[];
    await getDocId();
   setState(() {
      //snake position
   snakePosition = [
    1,
    2,
    3,
  ];
    });
    foodPosition = 67;
    currentDirection = snake_Direction.RIGHT;
    gameHasStarted = false;
    currentScore =0;
  }

  //moveSbnake method
  void moveSnake(){
    switch(currentDirection){
      case snake_Direction.RIGHT: {
        //ADD HEAD..taking into consideration at the edges
        //if snake is at the right wall,we need to readjuast
        if(snakePosition.last % rowSize==9){
           snakePosition.add(snakePosition.last + 1 - rowSize);
        }else{
           //Aadd a head 
        snakePosition.add(snakePosition.last + 1);
        }
        
       
      }
      break;

      case snake_Direction.LEFT: { 
        if(snakePosition.last % rowSize== 0){
         snakePosition.add(snakePosition.last - 1 + rowSize);
        }else{
          snakePosition.add(snakePosition.last - 1);
        }
      
      }
      break;
      
      case snake_Direction.UP: {
        if (snakePosition.last < rowSize){
          snakePosition.add(snakePosition.last - rowSize + totalNumberOfSquares);
        }else{
           snakePosition.add(snakePosition.last - rowSize);//row size is 10,when you move up thats like -10 n this case,e.g from index index12 to index2 is just onre upward movement in the gridview
        }
       
        
      }
      break;
     
      case snake_Direction.DOWN: {
        if(snakePosition.last + rowSize >= totalNumberOfSquares){
          snakePosition.add(snakePosition.last + rowSize - totalNumberOfSquares);
        }else {
          snakePosition.add(snakePosition.last + rowSize);
        }
        
      }

      break;
      default:
    }
    //snake eating food
    if(snakePosition.last == foodPosition){
        eatFood();
    }else{
       //remove tail
        snakePosition.removeAt(0);
    }
     
  
  }
  
  void eatFood(){
    currentScore++;
    //making sure the new food is not where the snake is
    while(snakePosition.contains(foodPosition)) {  //as long as the food position is in the Snake Position list
      foodPosition = Random().nextInt(totalNumberOfSquares);
    }
  }

  //gameOver method when snake hits itself
  bool gameOver(){
    //the game is over when snake runs into itself
    //that means in the list of Snake Positions there is a duplicate number

    //this list is the body of the snake(no head)
    List<int> bodySnake = snakePosition.sublist(0,snakePosition.length-1);

    if (bodySnake.contains(snakePosition.last)){  //does the head of the Snake include the body,if t
       return true;                        //because its true
    }
    // else just
     return false;
  }

  

  @override
  Widget build(BuildContext context) {
   // final screenWidth = MediaQuery.of(context).size.width;
  //  final screenHeight=MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:  Colors.transparent,
       // title:   Icon(icon)
       // centerTitle: true,
      ),
     body: RawKeyboardListener(   //tO ALLOW KEYBOARD CONTROLS
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event){
          if(event.isKeyPressed(LogicalKeyboardKey.arrowDown )&& currentDirection!= snake_Direction.UP){
            currentDirection= snake_Direction.DOWN;
          }else if(event.isKeyPressed(LogicalKeyboardKey.arrowUp)&& currentDirection!= snake_Direction.DOWN){
            currentDirection= snake_Direction.UP;
          }else if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft)&& currentDirection!= snake_Direction.RIGHT){
            currentDirection= snake_Direction.LEFT;
          }else if(event.isKeyPressed(LogicalKeyboardKey.arrowRight)&& currentDirection!= snake_Direction.LEFT){
            currentDirection= snake_Direction.RIGHT;
          }
        },
       child: Column(
            children: [      
              //high scores
              Expanded(
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //to display the user current score
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         const Text(
                          'current score',
                         ),
                          Text(currentScore.toString(),
                            style: const TextStyle(fontSize: 36,color: Colors.greenAccent),
                          ),
                        ],
                      ),
                    ),
        
                    //on the RhS the highScores
                  Expanded(
                    child: gameHasStarted 
                    ? Container()
                    :FutureBuilder(
                      future: letsGetDocIds, 
                      builder: (context,snapshot){
                        return ListView.builder(
                          itemCount: highscoreDocsIds.length,
                          itemBuilder: (context,index){
                        return HighScoreTile(documentId: highscoreDocsIds[index]);
                        });
                      }
                      ),
                  )
                  ],
                ),
              ),
        
              //game grid
               Expanded(  
                flex: 3,
                child:  GestureDetector(  //wrapping the gris with gesture detector for user input
                  onVerticalDragUpdate: (details) {
                    if(details.delta.dy >0  && currentDirection!= snake_Direction.UP){
                      print('moving down');
                      currentDirection = snake_Direction.DOWN;
                    }else if(details.delta.dy<0 && currentDirection != snake_Direction.DOWN){
                      print('moving up');
                      currentDirection = snake_Direction.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details){
                    if(details.delta.dx>0 && currentDirection!= snake_Direction.LEFT){
                      print('moving right');
                      currentDirection = snake_Direction.RIGHT;
                    }else if(details.delta.dx<0 && currentDirection != snake_Direction.RIGHT){
                      print('moving left');
                      currentDirection = snake_Direction.LEFT;
                    }
                  },
                  child: AspectRatio( //aspect ratio is the proportion of width to height 
                    aspectRatio: 1, //the game will remain square regarless of screen dimension. So the 
                    child: SizedBox(
                      width: double.infinity,//takes the full width but since aspect atio makes the height limit the width,the widt will still expand but remain a square leaving equal spaces on both sides
                      child: GridView.builder(
                        itemCount: totalNumberOfSquares,
                        physics: const NeverScrollableScrollPhysics(), //making sure the grid is unscrollable
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),//how many do i wanty in a row,that is crossAxiscount
                        itemBuilder: (contex,index){
                                  //snake position is a list.index check the value of each bock in the gridview in this case
                         if (snakePosition.contains(index)){ //so if the snake position(list of 0,1,2) is in the index,return the pixel on them
                          return SnakePixel();
                         }else if(foodPosition ==index){
                          return FoodPixel();
                         }
                          else{
                         return BlankPixel();
                         }
                        }
                       // retu
                      ),
                    ),
                  ),
                )
              ),
              //play button
               Expanded(
                child:  Container(
                   child: Center(
                     child:  MaterialButton(
                      color:gameHasStarted? (isPaused? Colors.lightBlue: Colors.pink) : Colors.green, 
                      onPressed: gameHasStarted? togglePause : startGame,
                      child: gameHasStarted? (isPaused? const Text('RESUME'): const Text('PAUSE')): const Text('PLAY'),   //if game as started do nothing
                      ),
                   ),
                ),
              ),
            ],
          ),
     ),
      );
    }  
  }


//separate game logic fro ui....game logic in another class

