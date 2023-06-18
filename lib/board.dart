import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snake_game/snake.dart';
import 'package:snake_game/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Board extends StatefulWidget {
  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  List snakeposition;
  String movedirection;
  Timer t1, t2, t3, t4;
  Random randomfeed = Random();
  int feedposition;
  int score;

//some parameters
  int firstdigit;
  int topborder;
  int bottomborder;
  int leftborder;
  int rightborder;

  //determine the border of board matrix based on the snake position
  showborder() {
    int first = snakeposition[snakeposition.length - 1] % 10; //7
    int second = snakeposition[snakeposition.length - 1] - first; //40
    //determine borders of the grid view matrix
    topborder = first;
    bottomborder = first + 110;
    rightborder = (second) + 9; // 49
    leftborder = second; //40
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //initilize the game
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
          leadingWidth: 150,
          leading: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Score: ${score}',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
          actions: [
            FloatingActionButton(
              onPressed: (() => startGame()),
              child: Icon(
                Icons.refresh_rounded,
                size: 30,
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
        body: Stack(
          children: [
            Opacity(
              opacity: 0.2,
              child: SvgPicture.asset(
                'assets/images/snake.svg',
                alignment: Alignment.center,
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: Colors.amber,
                          width: 0.5,
                          style: BorderStyle.solid,
                        )
                      )
                    ),
                    child: GridView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 120,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 10,
                          mainAxisSpacing: 0.0,
                          crossAxisSpacing: 0.0,
                          childAspectRatio: 1.25,
                        ),
                        itemBuilder: (context, index) {
                          if (snakeposition.contains(index)) {
                            return Snakebody(index: index);
                          } else if (index == feedposition) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  index.toString(),
                                  style: TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            );
                          } else
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  index.toString(),
                                  style: TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            );
                        }),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Table(
                    defaultColumnWidth: FixedColumnWidth(45),
                    children: [
                      TableRow(children: [
                        Text(''),
                        FloatingActionButton(
                          onPressed: () {
                            if (movedirection != 'up' &&
                                movedirection != 'down') {
                              movedirection = 'up';
                              movetop();
                            }
                          },
                          child: Icon(Icons.arrow_upward),
                        ),
                        Text(''),
                      ]),
                      TableRow(children: [
                        FloatingActionButton(
                          onPressed: () {
                            if (movedirection != 'left' &&
                                movedirection != 'right') {
                              movedirection = 'left';
                              moveleft();
                            }
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                        Text(''),
                        FloatingActionButton(
                          onPressed: () {
                            if (movedirection != 'right' &&
                                movedirection != 'left') {
                              movedirection = 'right';
                              moveright();
                            }
                          },
                          child: Icon(Icons.arrow_forward),
                        ),
                      ]),
                      TableRow(children: [
                        Text(''),
                        FloatingActionButton(
                          onPressed: () {
                            if (movedirection != 'down' &&
                                movedirection != 'up') {
                              movedirection = 'down';
                              movebottom();
                            }
                          },
                          child: Icon(Icons.arrow_downward),
                        ),
                        Text(''),
                      ]),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

////functions should be separated
//game initilization
  startGame() {
    setState(() {
      snakeposition = [0, 1, 2, 3];
    });
    if (movedirection != 'right' && movedirection != 'left') {
      movedirection = 'right';
      moveright();
    }
    feedposition = randomfeed.nextInt(119);
    score = 0;
  }

//game over when snakes head crash with it's body instead of neeck it's impossible
  gameover() {
    var snakebody = snakeposition.getRange(0, snakeposition.length - 3);
    print(snakeposition);
    if (snakebody.contains(snakeposition.last)) {
      print("here crashed ${snakeposition}");
      playAgain();
      movedirection = '';

      t1.cancel();
      t1 = null;
      t2.cancel();
      t2 = null;
      t3.cancel();
      t3 = null;
      t4.cancel();
      t4 = null;
    }
  }

//feed position
//if snake head is equal to food position then re-initilize the position of food
//and add the food position onto the head on snake
  feed() {
    //repositioning feed
    if (snakeposition.last == feedposition) {
      setState(() {
        snakeposition.insert(snakeposition.length, feedposition);
        feedposition = randomfeed.nextInt(119);
        score += 5;
      });
    }
    if (snakeposition.contains(feedposition)) {
      setState(() {
        feedposition = randomfeed.nextInt(119);
      });
    }
  }

//move right for each move remove first list item and add last++ into my list
// this will change list forward the snake to the right side
//the same process and logic for another move directions just change last item.
  moveright() {
    t1 = Timer.periodic(Duration(milliseconds: 400), (timer) {
      feed();
      showborder();
      gameover();
      if (movedirection == 'right') {
        if (snakeposition.last < rightborder) {
          setState(() {
            snakeposition.removeAt(0);
            snakeposition.insert(snakeposition.length, snakeposition.last + 1);
          });
        } else {
          setState(() {
            snakeposition.removeAt(0);
            snakeposition.insert(snakeposition.length, snakeposition.last - 9);
          });
        }
      } else {
        t1.cancel();
      }
    });
  }

  //move left
  moveleft() {
    t2 = Timer.periodic(Duration(milliseconds: 400), (timer) {
      feed();
      showborder();
      gameover();
      if (movedirection == 'left') {
        if (snakeposition.last > leftborder) {
          setState(() {
            snakeposition.removeAt(0);
            snakeposition.insert(snakeposition.length, snakeposition.last - 1);
          });
        } else {
          setState(() {
            snakeposition.removeAt(0);
            snakeposition.insert(snakeposition.length, snakeposition.last + 9);
          });
        }
      } else {
        t2.cancel();
      }
    });
  }

  //move top
  movebottom() {
    t3 = Timer.periodic(Duration(milliseconds: 400), (timer) {
      feed();
      showborder();
      gameover();

      if (movedirection == 'down') {
        if (snakeposition.last < bottomborder) {
          setState(() {
            snakeposition.removeAt(0);
            snakeposition.insert(snakeposition.length, snakeposition.last + 10);
          });
        } else {
          setState(() {
            snakeposition.removeAt(0);
            snakeposition.insert(
                snakeposition.length, snakeposition.last - 110);
          });
        }
      } else {
        t3.cancel();
      }
    });
  }

  //move top
  movetop() {
    Timer.periodic(Duration(milliseconds: 400), (timer) {
      feed();
      showborder();
      gameover();

      if (movedirection == 'up') {
        if (snakeposition.last > topborder) {
          setState(() {
            snakeposition.removeAt(0);
            snakeposition.insert(snakeposition.length, snakeposition.last - 10);
          });
        } else {
          setState(() {
            snakeposition.removeAt(0);
            snakeposition.insert(
                snakeposition.length, snakeposition.last + 110);
          });
        }
      } else {
        t4.cancel();
      }
    });
  }

//play again dialogBox
  playAgain() => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
          title: Text('You Lost'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You achived score: ${score.toString()}'),
              MaterialButton(
                color: Theme.of(context).primaryColor,
                child: Text('Play Again'),
                onPressed: (() {
                  Navigator.pop(context);
                  return startGame();
                }),
              ),
            ],
          ))));
}
