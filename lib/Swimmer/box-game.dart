import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/BluetoothSync.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Menu.dart';
import 'package:gbsalternative/Swimmer/WaterLines.dart';
import 'package:path/path.dart';
import 'Ui.dart';

class BoxGame extends Game {
  Size screenSize;
  bool inTouch = false;
  Background background;
  Close closeButton;
  DownLine downLine;
  UpLine upLine;
  double tileSize;

  bool pauseGame = false;
  String swimPic;
  double creationTimer = 0.0;
  double tempPos = 0;
  int i = 0;
  int difficulte = 5;
  SpriteComponent player;

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

  BoxGame(this.getData, User _user) {
    user = _user;
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    background = Background(this);
    closeButton = Close(this);
    downLine = DownLine(this);
    upLine = UpLine(this);
  }

  void render(Canvas canvas) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    canvas.drawRect(bgRect, bgPaint);

    //String btData = _onDataReceiver();


    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;
    Rect boxRect =
    Rect.fromLTWH(screenCenterX - 75, screenCenterY - 75, 150, 150);
    Paint boxPaint = Paint();

    /*
    if (hasWon) {
      boxPaint.color = Color(0xff00ff00);
      hasWon = false;

    } else {
      boxPaint.color = Color(0xffffffff);
    }*/

    if (canvas != null) {
      //Background
      background.render(canvas);

      //Close button
      closeButton.render(canvas);

      canvas.save();

      //Ligne basse
      downLine.render(canvas);

      //Ligne haute
      upLine.render(canvas);

      //Nageur
      player.render(canvas);

    }
  }

  void update(double t) async {
    creationTimer += t;
    //Timer
    if (creationTimer >= 0.04) {
      if (i == 23)
        i = 0;
      else
        i++;

      swimPic = tab[i];

      creationTimer = 0.0;

      Sprite sprite = Sprite(swimPic);

      const size = 230.0;
      //player = AnimationComponent(size, size, new flanim.Animation.spriteList(sprites, stepTime: 0.01));

      player = SpriteComponent.fromSprite(
          size, size, sprite); // width, height, sprite

      player.x = screenSize.width / 2;
      //Définition des bords haut et bas de l'écran
      //Bas
      if (tempPos >= screenSize.height - size/2) {
        player.y = tempPos;
      }
      //Haut
      else if(tempPos < -size/2){
        print("SALUT " + player.y.toString());
        tempPos = -size/2;
        player.y = tempPos;
      }
      //Sinon on fait descendre le nageur
      else {
        player.y += tempPos;
        tempPos = player.y + difficulte;
      }

      //component = new Component(dimensions);
      //add(component);
    }


    //print(getData());

    //getData = données reçues par le Bluetooth
    if (getData() > double.parse(user.userInitialPush)) {
      //print(player.y);
      player.y -= 1.0;
      tempPos = player.y;
      inTouch = false;
    }

    if (inTouch) {
      print(player.y);
      player.y -= 20.0;
      tempPos = player.y;
      inTouch = false;
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

}