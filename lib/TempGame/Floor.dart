import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';
import 'package:gbsalternative/TempGame/TempGame.dart';

class Floor {}

double balloonPosition = 0.1;
int j = 0;
int k = 0;
int screenSpeed = 2;

double grassSize;
double firstFloorY;

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
  bool hasChanged;

  BottomFloor(this.game) {
    grass = Sprite('temp/grass.png');
    grassRight = Sprite('temp/grass_right.png');
    //width: 500
    //height: 300
    grassSize = game.screenSize.width * 0.1;

    j = 0;
    hasChanged = false;

    List<double> grassOffset = [
      game.screenSize.width * 0.0,
      game.screenSize.width * 0.1,
      game.screenSize.width * 0.2,
      game.screenSize.width * 0.3,
      game.screenSize.width * 0.4,
      game.screenSize.width * 0.5,
      game.screenSize.width * 0.6,
      game.screenSize.width * 0.7,
      game.screenSize.width * 0.8,
      game.screenSize.width * 0.9,
      game.screenSize.width * 1.0,
    ];

    rectGrass0 = Rect.fromLTWH(
        grassOffset[0],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass1 = Rect.fromLTWH(
        grassOffset[1],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass2 = Rect.fromLTWH(
        grassOffset[2],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass3 = Rect.fromLTWH(
        grassOffset[3],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass4 = Rect.fromLTWH(
        grassOffset[4],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass5 = Rect.fromLTWH(
        grassOffset[5],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass6 = Rect.fromLTWH(
        grassOffset[6],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass7 = Rect.fromLTWH(
        grassOffset[7],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass8 = Rect.fromLTWH(
        grassOffset[8],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass9 = Rect.fromLTWH(
        grassOffset[9],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);

    rectGrassRight = Rect.fromLTWH(
        grassOffset[10],
        game.screenSize.height - game.screenSize.width * 0.1,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
  }

  void render(Canvas c, bool pause, bool isMoving) {
/*    if(isMoving)
      c.translate(-game.screenSize.width / 2,
          -game.screenSize.height * (1 - balloonPosition));*/

    if (isMoving) {

      if (!pause)
        j -= screenSpeed;

      //Premier vide à sauter
      if (j <= 5.5 * (-grassSize) && !game.hasJumped) {
        j += screenSpeed;
        isMoving = false;
        if (!hasChanged) {
          //Waiting
          game.setPlayerState(2);
          hasChanged = true;
        }
      }
      //Deuxième vide
      else if( j <= 5.5 * (-grassSize) &&  j >= 8.5 * (-grassSize) && game.hasJumped){
        j -= 3*screenSpeed;
        game.setPlayerState(1);

      }
      else if(j <= 18.5 * (-grassSize) && !pause) {
        isMoving = false;
        j += screenSpeed;
        game.setPlayerState(2);
        hasChanged = true;
      }


      //-1190

      c.translate(j.toDouble(),
          -game.screenSize.width * 0.1 + game.screenSize.width * 0.1);
      /*if (j < -game.screenSize.width) {
        j = -game.screenSize.width.toInt();
      }*/
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
    //c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void update(double t) {}
}

class FirstFloor {
  final TempGame game;
  Sprite grass;
  Sprite grassRight;
  Sprite grassLeft;
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
  Rect rectGrassLeft;
  Rect rectGrassRight;
  bool hasChanged;

  FirstFloor(this.game) {
    grass = Sprite('temp/grass.png');
    grassRight = Sprite('temp/grass_right.png');
    grassLeft = Sprite('temp/grass_left.png');
    //width: 500
    //height: 300
    firstFloorY = game.screenSize.height - game.screenSize.width * 0.3;

    k = 0;
    hasChanged = false;

    List<double> grassOffset = [
      game.screenSize.width * 1.3,
      game.screenSize.width * 1.4,
      game.screenSize.width * 1.5,
      game.screenSize.width * 1.6,
      game.screenSize.width * 1.7,
      game.screenSize.width * 1.8,
      game.screenSize.width * 1.9,
      game.screenSize.width * 2.0,
      game.screenSize.width * 2.1,
      game.screenSize.width * 2.2,
      game.screenSize.width * 2.3,
    ];

    rectGrassLeft = Rect.fromLTWH(
        grassOffset[0],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass0 = Rect.fromLTWH(
        grassOffset[1],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass1 = Rect.fromLTWH(
        grassOffset[2],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass2 = Rect.fromLTWH(
        grassOffset[3],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass3 = Rect.fromLTWH(
        grassOffset[4],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass4 = Rect.fromLTWH(
        grassOffset[5],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass5 = Rect.fromLTWH(
        grassOffset[6],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass6 = Rect.fromLTWH(
        grassOffset[7],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass7 = Rect.fromLTWH(
        grassOffset[8],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
    rectGrass8 = Rect.fromLTWH(
        grassOffset[9],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);

    rectGrassRight = Rect.fromLTWH(
        grassOffset[10],
        game.screenSize.height - game.screenSize.width * 0.3,
        game.screenSize.width * 0.1,
        game.screenSize.width * 0.1);
  }

  void render(Canvas c, bool pause, bool isMoving) {
    if (isMoving) {
      //j.toDouble() - j.toDouble()
      c.translate(0,
          -game.screenSize.width * 0.1 + game.screenSize.width * 0.1);


      //if(j < -(game.screenSize.width)*1.5)
        //j=0;
        //print("oui");

    }

    grassLeft.renderRect(c, rectGrassLeft);
    grass.renderRect(c, rectGrass0);
    grass.renderRect(c, rectGrass1);
    grass.renderRect(c, rectGrass2);
    grass.renderRect(c, rectGrass3);
    grass.renderRect(c, rectGrass4);
    grass.renderRect(c, rectGrass5);
    grass.renderRect(c, rectGrass6);
    grass.renderRect(c, rectGrass7);
    grass.renderRect(c, rectGrass8);
    grassRight.renderRect(c, rectGrassRight);
    // restore original state
    c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void update(double t) {}
}
