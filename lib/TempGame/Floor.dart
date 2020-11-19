import 'dart:async';
import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';
import 'package:gbsalternative/TempGame/TempGame.dart';

class Floor {}

double balloonPosition = 0.1;
int k = 0;
int screenSpeed = 2;
bool isInit;
bool isTheFirstPlatform;
double grassSize;
double firstFloorY;
double posFloorY;
int offset = 0;
List<double> grassXOffset = [];
List<double> grassXOffset1 = [];
bool blockOne;

double grassYOffset;
double grassYOffset1;

class BottomFloor {
  final TempGame game;
  Sprite grass;
  Sprite grassLeft;
  Rect rectGrass0;
  Rect rectGrass1;
  Rect rectGrass2;
  Rect rectGrass3;
  Rect rectGrass4;
  Rect rectGrass5;
  Rect rectGrass6;
  Rect rectGrass7;
  Sprite grassRight;
  Rect rectGrassRight;
  Rect rectGrassLeft;
  bool hasChanged;
  int j = 0;

  BottomFloor(this.game) {
    grass = Sprite('temp/grass.png');
    grassRight = Sprite('temp/grass_right.png');
    grassLeft = Sprite('temp/grass_left.png');
    //width: 500
    //height: 300
    grassSize = game.screenSize.width * 0.1;

    j = 0;
    hasChanged = false;
    blockOne = false;

    grassXOffset = [
      0,
      grassSize,
      2 * grassSize,
      3 * grassSize,
      4 * grassSize,
      5 * grassSize,
      6 * grassSize,
      7 * grassSize,
      8 * grassSize,
      9 * grassSize
    ];

    grassYOffset = game.screenSize.height - grassSize;

    updateRect();
  }

  void updateRect() {
    rectGrassLeft = Rect.fromLTWH(grassXOffset[0], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass0 = Rect.fromLTWH(grassXOffset[1], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass1 = Rect.fromLTWH(grassXOffset[2], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass2 = Rect.fromLTWH(grassXOffset[3], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass3 = Rect.fromLTWH(grassXOffset[4], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass4 = Rect.fromLTWH(grassXOffset[5], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass5 = Rect.fromLTWH(grassXOffset[6], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass6 = Rect.fromLTWH(grassXOffset[7], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass7 = Rect.fromLTWH(grassXOffset[8], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrassRight = Rect.fromLTWH(grassXOffset[9], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
  }

  void render(Canvas c, bool pause, bool isMoving) {
/*    if(isMoving)
      c.translate(-game.screenSize.width / 2,
          -game.screenSize.height * (1 - balloonPosition));*/

    if (isMoving) {
      if (!pause) j += screenSpeed;

      if (!isInit) {
        offset = game.tempPosX.toInt();
        posFloorY = 0;
        isInit = true;
        isTheFirstPlatform = false;
      }

      //Marche jusquau premier vide
      // if (j <= 5.5 * (-grassSize) && !game.hasJumped) {
      if (j >= grassXOffset[grassXOffset.length - 1] - offset - grassSize / 2 &&
          !game.hasJumped &&
          !isTheFirstPlatform) {
        j -= screenSpeed;
        //isMoving = false;
        if (!hasChanged) {
          //Waiting
          game.setPlayerState(2);
          hasChanged = true;
        }
        //while(!game.hasJumped);

      }
      //Premier vide à sauter
      else if (j >=
              grassXOffset[grassXOffset.length - 1] - offset - grassSize / 2 &&
          j <= grassXOffset1[0] - offset - grassSize / 2 &&
          game.hasJumped &&
          !isTheFirstPlatform) {
        j += 3 * screenSpeed;
        game.setPlayerState(1);
        hasChanged = false;
      }

      //Marche jusqu'au bout de la plateforme
      if (j >= grassXOffset[grassXOffset.length - 1] - offset - grassSize / 2 &&
          !game.hasJumped &&
          !blockOne) {
        j -= screenSpeed;
        //isMoving = false;
        if (!hasChanged) {
          //Waiting
          game.setPlayerState(2);
          hasChanged = true;
        }
      }
      //Marche jusqu'au bout de l'autre plateforme
      else if (j >=
              grassXOffset1[grassXOffset.length - 1] - offset - grassSize / 2 &&
          !game.hasJumped &&
          blockOne) {
        j -= screenSpeed;
        //isMoving = false;
        if (!hasChanged) {
          //Waiting
          game.setPlayerState(2);
          hasChanged = true;
        }
      }

      //Vide à sauter
      else if (j >=
              grassXOffset[grassXOffset.length - 1] - offset - grassSize / 2 &&
          j <= grassXOffset1[0] - offset - grassSize / 2 &&
          game.hasJumped &&
          !blockOne) {
        jump();
        //blockOne = true;
      } else if (j >=
              grassXOffset1[grassXOffset.length - 1] - offset - grassSize / 2 &&
          j <= grassXOffset[0] - offset - grassSize / 2 &&
          game.hasJumped &&
          blockOne) {
        jump();
        //blockOne = false;
      }

      //Déplacement du bloc à la suite de l'ancien
      if (j > grassXOffset[grassXOffset.length - 1] + grassSize * 1) {
        for (int i = 0; i < grassXOffset.length; i++) {
          grassXOffset[i] += grassSize * 24;
        }
        blockOne = !blockOne;
        grassYOffset = firstFloorY;
        updateRect();
      } else if (j > grassXOffset1[grassXOffset1.length - 1] + grassSize * 1) {
        for (int i = 0; i < grassXOffset1.length; i++) {
          grassXOffset1[i] += grassSize * 24;
        }
        blockOne = !blockOne;
        grassYOffset1 = firstFloorY;
        game.firstFloor.updateRect();
      }

/*      else if (j >= grassXOffset1[10] - offset - grassSize/2  && !pause) {
        isMoving = false;
        j -= screenSpeed;
        game.setPlayerState(2);
        hasChanged = true;
      }
      else
        j++;*/

      //-1190

      c.translate(-j.toDouble(), 0);
      //-game.screenSize.width * 0.1 + game.screenSize.width * 0.1);
      /*if (j < -game.screenSize.width) {
        j = -game.screenSize.width.toInt();
      }*/
    } else
      isInit = false;
    grassLeft.renderRect(c, rectGrassLeft);
    grass.renderRect(c, rectGrass0);
    grass.renderRect(c, rectGrass1);
    grass.renderRect(c, rectGrass2);
    grass.renderRect(c, rectGrass3);
    grass.renderRect(c, rectGrass4);
    grass.renderRect(c, rectGrass5);
    grass.renderRect(c, rectGrass6);
    grass.renderRect(c, rectGrass7);
    grassRight.renderRect(c, rectGrassRight);

    // restore original state
    //c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void jump() {
    j += 3 * screenSpeed;
    game.setPlayerState(1);
    hasChanged = false;
  }

  void update(double t) {}
}

class FirstFloor {
  final TempGame game;
  Sprite grass;
  Sprite grassRight;
  Sprite grassLeft;

  Rect rectGrassLeft;
  Rect rectGrass0;
  Rect rectGrass1;
  Rect rectGrass2;
  Rect rectGrass3;

  Rect rectGrass4;
  Rect rectGrass5;
  Rect rectGrass6;
  Rect rectGrass7;
  Rect rectGrassRight;

  bool hasChanged;

  FirstFloor(this.game) {
    grass = Sprite('temp/grass.png');
    grassRight = Sprite('temp/grass_right.png');
    grassLeft = Sprite('temp/grass_left.png');
    //width: 500
    //height: 300
    firstFloorY = game.screenSize.height - 3 * grassSize;

    grassYOffset1 = firstFloorY;

    k = 0;
    hasChanged = false;

    grassXOffset1 = [
      game.screenSize.width * 1.2,
      game.screenSize.width * 1.3,
      game.screenSize.width * 1.4,
      game.screenSize.width * 1.5,
      game.screenSize.width * 1.6,
      game.screenSize.width * 1.7,
      game.screenSize.width * 1.8,
      game.screenSize.width * 1.9,
      game.screenSize.width * 2.0,
      game.screenSize.width * 2.1,
    ];
    updateRect();
  }

  void updateRect() {
    rectGrassLeft = Rect.fromLTWH(grassXOffset1[0], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass0 = Rect.fromLTWH(grassXOffset1[1], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass1 = Rect.fromLTWH(grassXOffset1[2], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass2 = Rect.fromLTWH(grassXOffset1[3], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass3 = Rect.fromLTWH(grassXOffset1[4], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass4 = Rect.fromLTWH(grassXOffset1[5], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass5 = Rect.fromLTWH(grassXOffset1[6], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass6 = Rect.fromLTWH(grassXOffset1[7], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass7 = Rect.fromLTWH(grassXOffset1[8], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);

    rectGrassRight = Rect.fromLTWH(grassXOffset1[9], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);

  }

  void render(Canvas c, bool pause, bool isMoving) {
    if (isMoving) {
      //j.toDouble() - j.toDouble()

      c.translate(0, 0);

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
    grassRight.renderRect(c, rectGrassRight);
    // restore original state
    c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void update(double t) {}
}
