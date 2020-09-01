import 'dart:async';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/TempGame/Background.dart';
import 'package:gbsalternative/TempGame/Ui.dart';
import 'package:gbsalternative/TempGame/Floor.dart';
import 'package:flame/animation.dart'
    as animation; // imports the Animation class under animation.Animation
import 'package:flame/position.dart' as position; // imports the Position class

class TempGame extends Game {
  Size screenSize;
  bool inTouch = false;
  Background background;
  BottomFloor bottomFloor;
  SpriteComponent swimmer;
  double tileSize;
  bool redFilter;
  bool start;
  bool gameOver;
  bool isConnected;
  int counterHigh;
  bool isTooHigh;
  bool isInit;

  //Red Player
  bool isWaiting;
  bool isRunning;
  bool isJumping;

  int score = 0;
  bool pauseGame = false;
  bool isMoving = false;
  bool posMax;
  String swimmerPic;
  double creationTimer = 0.0;
  double scoreTimer = 0.0;
  double tempPosY = 0;
  double tempPosX = 0;
  double pos = 0;
  int i = 0;
  double difficulte = 0.50;

  double size = 100.0;
  static List<String> run = [
    'temp/run1.png',
    'temp/run2.png',
    'temp/run3.png',
    'temp/run4.png',
    'temp/run5.png',
    'temp/run6.png',
    'temp/run7.png',
    'temp/run8.png',
    'temp/run9.png',
    'temp/run10.png',
    'temp/run11.png',
    'temp/run12.png',
    'temp/run13.png',
    'temp/run14.png',
    'temp/run15.png',
    'temp/run16.png',
    'temp/run17.png',
    'temp/run18.png'
  ];

  static List<String> jump = ['temp/jump1.png', 'temp/jump2.png'];

  static List<String> waiting = [
    'temp/run1.png',];

  List<List<String>> tab = [jump, run, waiting];

  double Function() getData;
  User user;
  int j = 1;
  double posBottomLine;
  double posTopLine;
  bool isTopPosition;
  UI gameUI;
  AppLanguage appLanguage;
  animation.Animation a;

  TempGame(this.getData, User _user, AppLanguage _appLanguage) {
    user = _user;
    appLanguage = _appLanguage;
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    background = Background(this);
    bottomFloor = BottomFloor(this);
    gameUI = UI();

    isTooHigh = false;
    counterHigh = 0;
    isTopPosition = false;
    posMax = false;
    gameOver = false;
    isConnected = true;
    start = false;
    redFilter = false;
    isInit = false;
    posBottomLine = bottomFloor.getDownPosition();
    posTopLine = bottomFloor.getDownPosition();

    isWaiting = false;
    isRunning = true;
    isJumping = false;
  }

  void render(Canvas canvas) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    canvas.drawRect(bgRect, bgPaint);

    //String btData = _onDataReceiver();

    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;

    /*
    if (hasWon) {
      boxPaint.color = Color(0xff00ff00);
      hasWon = false;

    } else {
      boxPaint.color = Color(0xffffffff);
    }*/

    if (canvas != null) {
      //Background
      if (background != null) background.render(canvas, pauseGame);

      canvas.save();

      if (!gameOver) {
        if (isConnected) {
          //Ligne basse
          if (bottomFloor != null)
            bottomFloor.render(canvas, pauseGame, isMoving);

          //Bonhomme rouge
          if (swimmer != null) {
            swimmer.render(canvas);

            pos = swimmer.y + swimmer.height / 2;
            //print("Position joueur: " + tempPos.toString());

          }

          //Conditions de défaite
          //N'a pas poussé assez et est tombé dans le vide
          if (pos < bottomFloor.getDownPosition()) {
            //print("Attention au bord bas !");
            //setColorFilter(true);
            isTopPosition = true;
            //Rentre une fois dans le timer
            if (!start) {
              counterHigh++;
              //Si le joueur pousse trop fort 5 fois dans le jeu, on demande à ce qu'il réajuste la toise
              if (counterHigh > 5) {
                isTooHigh = true;
                pauseGame = true;
              } else {
                isTooHigh = false;
                pauseGame = false;
              }

              startTimer(start = true, 10.0);
            }
          } else {
            setColorFilter(false);
            startTimer(start = false, 0.0);
          }
        }
      }
    }
  }

  void update(double t) async {
    creationTimer += t;
    scoreTimer += t;

    if (!gameOver) {
      if (getData() != -1.0)
        isConnected = true;
      else
        isConnected = false;

      if (isConnected) {
        //Timer
        if (creationTimer >= 0.02) {
          if (i == tab[j].length - 1)
            i = 0;
          else if (pauseGame)
            ;
          else
            i++;

          //if (pauseGame) i--;

          if (isJumping) {
            swimmerPic = jump[i];
            j = 0;
          } else if (isRunning) {
            swimmerPic = run[i];
            j = 1;
          } else if (isWaiting) {
            swimmerPic = waiting[i];
            j = 2;
          }

          creationTimer = 0.0;

          Sprite sprite = Sprite(swimmerPic);

          swimmer = SpriteComponent.fromSprite(
              size, size, sprite); // width, height, sprite
          swimmer.x = tempPosX;

          if (!isInit) {
            //Centrage du nageur en abscisses
            swimmer.x = -10;

            tempPosX = swimmer.x;
            //Centrage du nageur en ordonnées
            swimmer.y = screenSize.height - (size) - grassSize;

            isInit = true;
          }

          if (!pauseGame) {
            if (tempPosX < (screenSize.width - size) / 2) {
              tempPosX += 3;
              swimmer.x = tempPosX;
            }
            //Si le joueur atteint la moitié de l'écran, la "caméra" suit le joueur au centre de l'écran
            else
              isMoving = true;
          }
          //Définition des bords haut et bas de l'écran

          //Bas
          //Premier étage d'herbe
          if (tempPosY >= screenSize.height - (size) - grassSize) {
            swimmer.y = tempPosY;
          }

          //Sinon on fait descendre le nageur
          else if (!posMax) {
            swimmer.y += tempPosY;
            tempPosY = swimmer.y + difficulte * 4.0;
            if (pauseGame) tempPosY = swimmer.y;
          } else {
            if (swimmer.y == 0.0) {
              swimmer.y = tempPosY;
            }
            posMax = false;
          }
          //component = new Component(dimensions);
          //add(component);
        }

        //On incrémente le score tous les x secondes
        if (!pauseGame) {
          if (scoreTimer >= 0.5) {
            score++;
            scoreTimer = 0.0;
          }

          //getData = données reçues par le Bluetooth
          //Montée du nageur
          if (getData() > double.parse(user.userInitialPush) &&
              !posMax &&
              swimmer != null) {
            //print(swimmer.y);
            swimmer.y -= difficulte;
            tempPosY = swimmer.y;
            inTouch = false;
          }

          //print("tempPos: $tempPos \nSwimmer.y: ${swimmer.y}\n");

          //Pression sur l'écran avec le doigt
/*          if (inTouch) {
            print(swimmer.y);
            swimmer.y -= 20.0;
            tempPos = swimmer.y;
            inTouch = false;
          }*/
        }
      }
    }
    //super.update(t);
  }

  void setPlayerState(int state) {
    if (state == 0) {
      isJumping = true;
      isRunning = false;
      isWaiting = false;
      j = 0;
      i = 0;
    }
    if (state == 1) {
      isJumping = false;
      isRunning = true;
      isWaiting = false;
      j = 1;
      i = 0;
    }
    if (state == 2) {
      isJumping = false;
      isRunning = false;
      isWaiting = true;
      j = 2;
      i = 0;
    }
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void onTapDown(TapDownDetails d) {
    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;
    if (d.globalPosition.dx >= screenCenterX - screenSize.width &&
        d.globalPosition.dx <= screenCenterX + screenSize.width &&
        d.globalPosition.dy >= screenCenterY - screenSize.height &&
        d.globalPosition.dy <= screenCenterY + screenSize.height) {
      inTouch = true;
    }
  }

  int getScore() {
    return score;
  }

  void setColorFilter(bool boolean) {
    redFilter = boolean;
  }

  ColorFilter getColorFilter() {
    if (redFilter) {
      return ColorFilter.mode(Colors.transparent, BlendMode.luminosity);
      //return ColorFilter.mode(Colors.redAccent, BlendMode.hue);
    } else
      return ColorFilter.mode(Colors.transparent, BlendMode.luminosity);
  }

  bool getColorFilterBool() {
    return redFilter;
  }

  bool getGameOver() {
    return gameOver;
  }

  bool getConnectionState() {
    return isConnected;
  }

  bool getPosition() {
    //True: position haut
    //False: position basse
    return isTopPosition;
  }

  bool getPauseStatus() {
    return pauseGame;
  }

  void startTimer(bool isStarted, double _start) async {
    Timer _timer;

    if (!isStarted && isConnected) {
      //_start = 5.0;
      start = false;
    } else {
      const time = const Duration(milliseconds: 500);
      _timer = new Timer.periodic(
        time,
        (Timer timer) {
          // S'il ressort de la zone avant le timer, on reset le timer
          if (!start) {
            timer.cancel();
            return;
          }
          if (isConnected) {
            if (_start < 0.5) {
              //TODO Display menu ?
              setColorFilter(true);
              timer.cancel();
              gameOver = true;
            } else if (!pauseGame) {
              setColorFilter(!redFilter);
              _start = _start - 0.5;
              print(_start);
            }
          } else {
            setColorFilter(false);
            timer.cancel();
          }
        },
      );
    }
  }
}
