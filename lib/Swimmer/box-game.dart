import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Swimmer/Background.dart';
import 'package:gbsalternative/Swimmer/Swimmer.dart';
import 'package:gbsalternative/Swimmer/WaterLines.dart';

class BoxGame extends Game {
  Size screenSize;
  bool inTouch = false;
  Background background;
  DownLine downLine;
  UpLine upLine;
  SpriteComponent player;
  double tileSize;

  int score = 0;
  bool pauseGame = false;
  String swimPic;
  double creationTimer = 0.0;
  double scoreTimer = 0.0;
  double tempPos = 0;
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

  BoxGame(this.getData, User _user) {
    user = _user;
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    background = Background(this);
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

      /*
      //Close button
      closeButton.render(canvas);*/

      canvas.save();

      //Ligne basse
      if (downLine != null) downLine.render(canvas);

      //Ligne haute
      if (upLine != null) upLine.render(canvas);

      //Nageur
      if (player != null) player.render(canvas);
    }
  }

  void update(double t) async {
    creationTimer += t;
    scoreTimer += t;

    //Timer
    if (creationTimer >= 0.04) {
      if (i == 23)
        i = 0;
      else
        i++;

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
        print("SALUT " + player.y.toString());
        tempPos = -size / 2;
        player.y = tempPos;
      }
      //Sinon on fait descendre le nageur
      else {
        player.y += tempPos;
        tempPos = player.y + difficulte * 2.0;
      }

      //component = new Component(dimensions);
      //add(component);
    }

    //On incrémente le score tous les x secondes
    if (scoreTimer >= 0.5) {
      score++;
      scoreTimer = 0.0;
    }

    //getData = données reçues par le Bluetooth
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
}
