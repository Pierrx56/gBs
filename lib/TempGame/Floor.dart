import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';
import 'package:gbsalternative/TempGame/TempGame.dart';

class Floor {}

double balloonPosition = 0.1;
int j = 0;
int balloonSpeed = 2;

double grassSize;

class BottomFloor {
  final TempGame game;
  Sprite grass;
  Sprite grassRight;
  Rect rectGrass0;
  Rect rectGrass1;
  Rect rectGrass2;
  Rect rectGrass3;
  Rect rectGrass4;
  Rect rectGrass5;
  Rect rectGrass6;
  Rect rectGrass7;
  Rect rectGrass8;
  Rect rectGrass9;
  Rect rectGrassRight;

  BottomFloor(this.game) {
    grass = Sprite('temp/grass.png');
    grassRight = Sprite('temp/grass_right.png');
    //width: 500
    //height: 300
    grassSize = game.screenSize.width * 0.1;

    j = 0;

    rectGrass0 = Rect.fromLTWH(
        game.screenSize.width * 0.0,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass1 = Rect.fromLTWH(
        game.screenSize.width * 0.1,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass2 = Rect.fromLTWH(
        game.screenSize.width * 0.2,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass3 = Rect.fromLTWH(
        game.screenSize.width * 0.3,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass4 = Rect.fromLTWH(
        game.screenSize.width * 0.4,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass5 = Rect.fromLTWH(
        game.screenSize.width * 0.5,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass6 = Rect.fromLTWH(
        game.screenSize.width * 0.6,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass7 = Rect.fromLTWH(
        game.screenSize.width * 0.7,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass8 = Rect.fromLTWH(
        game.screenSize.width * 0.8,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass9 = Rect.fromLTWH(
        game.screenSize.width * 0.9,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);

    rectGrassRight = Rect.fromLTWH(
        game.screenSize.width,
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);

  }

  void render(Canvas c, bool pause, bool isMoving) {
/*    if(isMoving)
      c.translate(-game.screenSize.width / 2,
          -game.screenSize.height * (1 - balloonPosition));*/


    if (isMoving) {
      j -= balloonSpeed;
      if(pause)
        j += balloonSpeed;

      if(j == 5.5*(-grassSize)) {
        j += balloonSpeed;
        isMoving = false;
        game.setPlayerState(2);
      }

      c.translate(j.toDouble(),
          -game.screenSize.width * 0.1 + game.screenSize.width * 0.1);
      if(j < -game.screenSize.width )
        j =  -game.screenSize.width.toInt();

    }
    grass.renderRect(c, rectGrass0);
    grass.renderRect(c, rectGrass1);
    grass.renderRect(c, rectGrass2);
    grass.renderRect(c, rectGrass3);
    grass.renderRect(c, rectGrass4);
    grass.renderRect(c, rectGrass5);
    grass.renderRect(c, rectGrass6);
    grass.renderRect(c, rectGrass7);
    grass.renderRect(c, rectGrass8);
    grass.renderRect(c, rectGrass9);
    grassRight.renderRect(c, rectGrassRight);
    // restore original state
    c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void update(double t) {}
}

class TopLine {
  final TempGame game;
  Sprite topLine;
  Rect rectTop;

  TopLine(this.game) {
    topLine = Sprite('swimmer/up_line.png');
    //width: 500
    //height: 300
    rectTop = Rect.fromLTWH(
        0, 0, game.screenSize.width, game.screenSize.height * 0.05);
  }

  void render(Canvas c) {
    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(-game.screenSize.width / 2,
        -game.screenSize.height * (1 - balloonPosition));

    if (j >= game.screenSize.width) j = 0;

    c.translate(game.screenSize.width - j.toDouble(), 0);
    j += balloonSpeed;

    topLine.renderRect(c, rectTop);

    c.translate(-game.screenSize.width, 0);

    topLine.renderRect(c, rectTop);

    // restore original state
    c.restore();
  }

  double getUpPosition() {
    return game.screenSize.height * (1 - balloonPosition);
  }

  void update(double t) {}
}
