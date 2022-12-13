import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uassnake/blank_pixel.dart';
import 'package:uassnake/food_pixel.dart';
import 'package:uassnake/highscore.dart';
import 'package:uassnake/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, RIGHT, LEFT }

class _HomePageState extends State<HomePage> {
  //gridDimensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  //skor user
  int currentScore = 0;

  //snakeposition
  List<int> snakePos = [0, 1, 2];

  //arah ular
  var currentDirection = snake_Direction.RIGHT;

  //food position
  int foodPos = 55;

  //list highscore
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    // TODO: implement initState
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  //game settings
  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  //start the game
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        //snakenya gerak
        moveSnake();

        //cek kalo udah gameover
        if (gameOver()) {
          timer.cancel();

          //tampilin popup
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text('Game Over'),
                  content: Column(
                    children: [
                      Text('Your score is: ' + currentScore.toString()),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Enter Name'),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        submitScore();
                        newGame();
                      },
                      child: Text('Submit'),
                      color: Colors.pink,
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void submitScore() {
    //akses database
    var database = FirebaseFirestore.instance;

    //tambah data ke firebase
    database
        .collection('highscores')
        .add({"name": _nameController.text, "score": currentScore});
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [0, 1, 2];
      foodPos == 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          //tambah kepala
          //kalo lagi kekanan,bikin dia nongol dr kiri lgi
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case snake_Direction.LEFT:
        {
          //tambah kepala
          //kalo lagi kekanan,bikin dia nongol dr kiri lgi
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snake_Direction.UP:
        {
          //tambah kepala
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snake_Direction.DOWN:
        {
          //tambah kepala
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }

    //snake mam
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      //hapus ekor
      snakePos.removeAt(0);
    }
  }

  //gameover
  bool gameOver() {
    //gameover kalo kepala snake nabrak dirinya
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    //sesuain lebar web
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != snake_Direction.UP) {
            currentDirection = snake_Direction.DOWN;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != snake_Direction.DOWN) {
            currentDirection = snake_Direction.UP;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != snake_Direction.RIGHT) {
            currentDirection = snake_Direction.LEFT;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != snake_Direction.LEFT) {
            currentDirection = snake_Direction.RIGHT;
          }
        },
        child: SizedBox(
          width: screenWidth > 414 ? 414 : screenWidth,
          child: Column(
            children: [
              //highscores
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //skor sekarang
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Current Score',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            currentScore.toString(),
                            style: TextStyle(fontSize: 42, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    //highscore
                    Expanded(
                      child: gameHasStarted
                          ? Container()
                          : FutureBuilder(
                              future: letsGetDocIds,
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  itemCount: highscore_DocIds.length,
                                  itemBuilder: ((context, index) {
                                    return HighscoreTile(
                                        documentId: highscore_DocIds[index]);
                                  }),
                                );
                              },
                            ),
                    )
                  ],
                ),
              ),
              //gamegrid
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDirection != snake_Direction.UP) {
                      currentDirection = snake_Direction.DOWN;
                    } else if (details.delta.dy < 0 &&
                        currentDirection != snake_Direction.DOWN) {
                      currentDirection = snake_Direction.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDirection != snake_Direction.LEFT) {
                      currentDirection = snake_Direction.RIGHT;
                    } else if (details.delta.dx < 0 &&
                        currentDirection != snake_Direction.RIGHT) {
                      currentDirection = snake_Direction.LEFT;
                    }
                  },
                  child: GridView.builder(
                      itemCount: totalNumberOfSquares,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowSize),
                      itemBuilder: (context, index) {
                        if (snakePos.contains(index)) {
                          return const SnakePixel();
                        } else if (foodPos == index) {
                          return const FoodPixel();
                        } else {
                          return const BlankPixel();
                        }
                      }),
                ),
              ),
              //playbutton

              Expanded(
                child: Container(
                  child: Center(
                    child: MaterialButton(
                      child: Text('PLAY'),
                      color: gameHasStarted ? Colors.grey : Colors.pink,
                      onPressed: gameHasStarted ? () {} : startGame,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
