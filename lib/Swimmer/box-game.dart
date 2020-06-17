import 'dart:async';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Swimmer/Background.dart';
import 'package:gbsalternative/Swimmer/Swimmer.dart';
import 'package:gbsalternative/Swimmer/Ui.dart';
import 'package:gbsalternative/Swimmer/WaterLines.dart';

class BoxGame extends Game {
  Size screenSize;
  bool inTouch = false;
  Background background;
  BottomLine bottomLine;
  TopLine topLine;
  SpriteComponent player;
  double tileSize;
  bool redFilter;
  bool start;
  bool gameOver;

  int score = 0;
  bool pauseGame = false;
  String swimPic;
  double creationTimer = 0.0;
  double scoreTimer = 0.0;
  double tempPos = 0;
  double pos = 0;
  int i = 0;
  double difficulte = 1.0;

  double size = 230.0;
  List<String> tab = [
    'swimmer/swim0.png',
    'swimmer/swim1.png',
    'swimmer/swim2.png',
    'swimmer/swim3.png',
    'swimmer/swim4.png',
    'swimmer/swim5.png',
    'swimmer/swim6.png',
    'swimmer/swim7.png',
    'swimmer/swim8.png',
    'swimmer/swim9.png',
    'swimmer/swim10.png',
    'swimmer/swim11.png',
    'swimmer/swim12.png',
    'swimmer/swim13.png',
    'swimmer/swim14.png',
    'swimmer/swim15.png',
    'swimmer/swim16.png',
    'swimmer/swim17.png',
    'swimmer/swim18.png',
    'swimmer/swim19.png',
    'swimmer/swim20.png',
    'swimmer/swim21.png',
    'swimmer/swim22.png',
    'swimmer/swim23.png'
  ];

  double Function() getData;
  User user;
  int j = 0;
  double posBottomLine;
  double posTopLine;
  bool position;
  UI gameUI;

  BoxGame(this.getData, User _user) {
    user = _user;
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    background = Background(this);
    bottomLine = BottomLine(this);
    topLine = TopLine(this);
    gameUI = UI();

    position = false;
    gameOver = false;
    start = false;
    redFilter = false;
    posBottomLine = bottomLine.getDownPosition();
    posTopLine = bottomLine.getDownPosition();
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
      if (background != null) background.render(canvas);

      canvas.save();

      if (!gameOver) {
        //Ligne basse
        if (bottomLine != null) bottomLine.render(canvas, pauseGame);

        //Ligne haute
        if (topLine != null) topLine.render(canvas);

        //Nageur
        if (player != null) {
          player.render(canvas);

          pos = player.y + player.height / 2;
          //print("Position joueur: " + tempPos.toString());
        }

        if (pos < bottomLine.getDownPosition()) {
          //TODO Conditions de défaite, début d'un timer
          //print("Attention au bord bas !");
          //setColorFilter(true);
          position = true;
          //Rentre une fois dans la timer
          if (!start) {
            startTimer(start = true);
          }
        } else if (pos > topLine.getUpPosition()) {
          //TODO Conditions de défaite, début d'un timer
          //print("Attention au bord haut !");
          //setColorFilter(true);
          position = false;
          if (!start) {
            startTimer(start = true);
          }
        } else {
          setColorFilter(false);
          startTimer(start = false);
        }
      }
    }
  }

  void update(double t) async {
    creationTimer += t;
    scoreTimer += t;

    if (!gameOver) {
      //Timer
      if (creationTimer >= 0.04) {
        if (i == 23)
          i = 0;
        else
          i++;

        if(pauseGame)
          i--;

        swimPic = tab[i];

        creationTimer = 0.0;

        Sprite sprite = Sprite(swimPic);

        player = SpriteComponent.fromSprite(
            size, size, sprite); // width, height, sprite

        player.x = screenSize.width / 2 - player.width / 2;
        //Définition des bords haut et bas de l'écran

        //Bas
        if (tempPos >= screenSize.height - size / 2) {
          player.y = tempPos;
        }
        //Haut
        else if (tempPos < -size / 2) {
          tempPos = -size / 2;
          player.y = tempPos;
        }
        //Sinon on fait descendre le nageur
        else {
          player.y += tempPos;
          tempPos = player.y + difficulte * 2.0;
          if(pauseGame)
            tempPos = player.y;
        }

        //component = new Component(dimensions);
        //add(component);
      }

      //On incrémente le score tous les x secondes
      if(!pauseGame){
        if (scoreTimer >= 0.5) {
          score++;
          scoreTimer = 0.0;
        }

        //getData = données reçues par le Bluetooth

        double.tryParse("2.3");
        if (getData() > double.parse(user.userInitialPush)) {
          //print(player.y);
          player.y -= difficulte;
          tempPos = player.y;
          inTouch = false;
        }

        if (inTouch) {
          print(player.y);
          player.y -= 20.0;
          tempPos = player.y;
          inTouch = false;
        }
      }
    }
    //super.update(t);
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
    if (redFilter){
      return ColorFilter.mode(Colors.redAccent, BlendMode.hue);
    }
    else
      return ColorFilter.mode(Colors.transparent, BlendMode.luminosity);
  }

  bool getColorFilterBool(){
    return redFilter;
  }

  bool getGameOver(){
    return gameOver;
  }

  bool getPosition(){
    //True: position haut
    //False: position basse
    return position;
  }

  void startTimer(bool boolean) async {
    Timer _timer;
    double _start = 5.0;

    if (!boolean) {
      _start = 5.0;
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
          if (_start < 0.5) {
            //TODO Display menu ?
            setColorFilter(true);
            timer.cancel();
            gameOver = true;
          } else {
            setColorFilter(!redFilter);
            _start = _start - 0.5;
            print(_start);
          }
        },
      );
    }
  }
}
