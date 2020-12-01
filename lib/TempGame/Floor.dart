import 'dart:async';
import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
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
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  int j = 0;
  List<double> grassXOffset = [];

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

    setGrassXOffset(0);

    grassXOffset = getGrassXOffset();

    grassYOffset = game.screenSize.height - grassSize;

    updateRect();
  }

  void setGrassXOffset(double offset) {
    grassXOffset = [
      0 + offset,
      1 * grassSize + offset,
      2 * grassSize + offset,
      3 * grassSize + offset,
      4 * grassSize + offset,
      5 * grassSize + offset,
      6 * grassSize + offset,
      7 * grassSize + offset,
      8 * grassSize + offset,
      9 * grassSize + offset
    ];
  }

  List<double> getGrassXOffset() {
    return grassXOffset;
  }

  int getLength() {
    return grassXOffset.length;
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
/*
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
        jump();
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

        game.tabFloor[0].setOpacity(1);
        game.tabFloor[1].setOpacity(1);
        game.tabFloor[2].setOpacity(1);
        blockOne = !blockOne;
        firstFloorY = game.floorPosition[0];
        grassYOffset1 = firstFloorY;
        game.tabFloor[0].updateRect();
        firstFloorY = game.floorPosition[1];
        grassYOffset1 = firstFloorY;
        game.tabFloor[1].updateRect();
        firstFloorY = game.floorPosition[2];
        grassYOffset1 = firstFloorY;
        game.tabFloor[2].updateRect();
      }

      //-1190

      c.translate(-j.toDouble(), 0);
    } else
      isInit = false;
    */

    if (isMoving) c.translate(0, 0);

    grassLeft.renderRect(c, rectGrassLeft, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass0, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass1, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass2, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass3, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass4, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass5, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass6, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass7, overridePaint: getOpacity());
    grassRight.renderRect(c, rectGrassRight, overridePaint: getOpacity());

    // restore original state
    //c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void setOpacity(double _opacity) {
    if (_opacity <= 0) _opacity = 0;

    opacity = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  Paint getOpacity() {
    return opacity;
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
  bool isPassed = false;
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  List<double> grassXOffset = [];

  FirstFloor(this.game) {
    grass = Sprite('temp/grass.png');
    grassRight = Sprite('temp/grass_right.png');
    grassLeft = Sprite('temp/grass_left.png');
    //width: 500
    //height: 300

    grassYOffset1 = firstFloorY;

    setGrassXOffset(0);

    grassXOffset = getGrassXOffset();

    k = 0;
    hasChanged = false;

    updateRect();
  }

  void setGrassXOffset(double offset) {
    grassXOffset = [
      12 * grassSize + offset,
      13 * grassSize + offset,
      14 * grassSize + offset,
      15 * grassSize + offset,
      16 * grassSize + offset,
      17 * grassSize + offset,
      18 * grassSize + offset,
      19 * grassSize + offset,
      20 * grassSize + offset,
      21 * grassSize + offset
    ];
  }

  List<double> getGrassXOffset() {
    return grassXOffset;
  }

  int getLength() {
    return grassXOffset.length;
  }

  void updateRect() {
    rectGrassLeft = Rect.fromLTWH(grassXOffset[0], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass0 = Rect.fromLTWH(grassXOffset[1], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass1 = Rect.fromLTWH(grassXOffset[2], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass2 = Rect.fromLTWH(grassXOffset[3], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass3 = Rect.fromLTWH(grassXOffset[4], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass4 = Rect.fromLTWH(grassXOffset[5], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass5 = Rect.fromLTWH(grassXOffset[6], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass6 = Rect.fromLTWH(grassXOffset[7], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass7 = Rect.fromLTWH(grassXOffset[8], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);

    rectGrassRight = Rect.fromLTWH(grassXOffset[9], grassYOffset1,
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

    grassLeft.renderRect(c, rectGrassLeft, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass0, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass1, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass2, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass3, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass4, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass5, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass6, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass7, overridePaint: getOpacity());
    grassRight.renderRect(c, rectGrassRight, overridePaint: getOpacity());
    // restore original state
    c.restore();
  }

  void setOpacity(double _opacity) {
    if (_opacity <= 0) _opacity = 0;

    opacity = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  Paint getOpacity() {
    return opacity;
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void update(double t) {}
}

//Classe qui gère le déplacement horizontal des plateformes
class ManageFloors {
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
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  int j = 0;

  ManageFloors(this.game) {
    grassSize = game.screenSize.width * 0.1;

    j = 0;
    hasChanged = false;
    blockOne = false;
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
      if (j >=
              game.tabBottomFloor[0]
                      .grassXOffset[game.tabBottomFloor[0].getLength() - 1] -
                  offset -
                  grassSize / 2 &&
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
              game.tabBottomFloor[0]
                      .grassXOffset[game.tabBottomFloor[0].getLength() - 1] -
                  offset -
                  grassSize / 2 &&
          j <= game.tabFloor[0].grassXOffset[0] - offset - grassSize / 2 &&
          game.hasJumped &&
          !isTheFirstPlatform) {
        jump();
      }

      //Marche jusqu'au bout de la plateforme
      if (j >=
              game.tabBottomFloor[game.getFloor() - 1]
                      .grassXOffset[game.tabBottomFloor[game.getFloor() - 1].getLength() - 1] -
                  offset -
                  grassSize / 2 &&
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
              game.tabFloor[game.getFloor() - 1].grassXOffset[
                      game.tabFloor[game.getFloor() - 1].getLength() - 1] -
                  offset -
                  grassSize / 2 &&
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
              game.tabBottomFloor[game.getFloor() - 1].grassXOffset[
                      game.tabBottomFloor[game.getFloor() - 1].getLength() - 1] -
                  offset -
                  grassSize / 2 &&
          j <=
              game.tabFloor[game.getFloor() - 1].grassXOffset[0] -
                  offset -
                  grassSize / 2 &&
          game.hasJumped &&
          !blockOne) {
        jump();
        //blockOne = true;
      } else if (j >=
              game.tabFloor[game.getFloor() - 1].grassXOffset[
                      game.tabBottomFloor[game.getFloor() - 1].getLength() - 1] -
                  offset -
                  grassSize / 2 &&
          j <=
              game.tabBottomFloor[game.getFloor() - 1].grassXOffset[0] -
                  offset -
                  grassSize / 2 &&
          game.hasJumped &&
          blockOne) {
        jump();
        //blockOne = false;
      }

      //Déplacement du bloc à la suite de l'ancien
      //BlockOne = True
      if (j > game.tabBottomFloor[game.getFloor() - 1].grassXOffset[
                  game.tabBottomFloor[game.getFloor() - 1].getLength() - 1] + grassSize * 1) {
        game.tabBottomFloor[0].setOpacity(1);
        game.tabBottomFloor[1].setOpacity(1);
        game.tabBottomFloor[2].setOpacity(1);
        blockOne = !blockOne;
        print(blockOne);

        firstFloorY = game.floorPosition[1];
        grassYOffset = firstFloorY;
        //for (int i = 0; i < game.tabBottomFloor[game.getFloor()].getLength(); i++) {

        List<double> temps = game.tabFloor[game.getFloor() - 1].getGrassXOffset();

        game.tabBottomFloor[0].setGrassXOffset(temps[game.tabFloor[game.getFloor() - 1].getLength() - 1] + 3 * grassSize);
        //game.tabBottomFloor[0].setGrassXOffset(grassSize * 24);
        //}
        game.tabBottomFloor[0].updateRect();

        temps = game.tabBottomFloor[0].getGrassXOffset();

        firstFloorY = game.floorPosition[2];
        grassYOffset = firstFloorY;
        //for (int i = 0; i < game.tabBottomFloor[game.getFloor()].getLength(); i++) {
        game.tabBottomFloor[1].setGrassXOffset(temps[game.tabBottomFloor[0].getLength() - 1] + grassSize/2);
        //  game.tabBottomFloor[1].setGrassXOffset(grassSize * 24 + grassSize/2);
          //grassXOffset[i] += grassSize / 2;
        //}
        game.tabBottomFloor[1].updateRect();

        //TODO Check changement position en fonction des anciens
        temps = game.tabBottomFloor[0].getGrassXOffset();
        firstFloorY = game.floorPosition[3];
        grassYOffset = firstFloorY;
        game.tabBottomFloor[1].setGrassXOffset(temps[game.tabBottomFloor[1].getLength() - 1] + grassSize);
        //game.tabBottomFloor[2].setGrassXOffset(grassSize * 24 + grassSize);
        //for (int i = 0; i < game.tabBottomFloor[game.getFloor()].getLength(); i++) {
        //  grassXOffset[i] += grassSize;
        //}
        game.tabBottomFloor[2].updateRect();
      } else if (j >  game.tabFloor[game.getFloor() - 1].grassXOffset[
      game.tabFloor[game.getFloor() - 1].getLength() - 1] + grassSize * 1) {
        game.tabFloor[0].setOpacity(1);
        game.tabFloor[1].setOpacity(1);
        game.tabFloor[2].setOpacity(1);
        blockOne = !blockOne;

        firstFloorY = game.floorPosition[1];
        grassYOffset1 = firstFloorY;
        //for (int i = 0; i < grassXOffset1.length; i++) {
        //  grassXOffset1[i] += grassSize * 24;
        //}
        game.tabFloor[0].setGrassXOffset(grassSize * 24);
        game.tabFloor[0].updateRect();

        firstFloorY = game.floorPosition[2];
        grassYOffset1 = firstFloorY;
        //for (int i = 0; i < grassXOffset1.length; i++) {
        //  grassXOffset1[i] += grassSize / 2;
        //}
        game.tabFloor[1].setGrassXOffset(grassSize * 24 + grassSize/2);
        game.tabFloor[1].updateRect();

        firstFloorY = game.floorPosition[3];
        grassYOffset1 = firstFloorY;
        //for (int i = 0; i < grassXOffset1.length; i++) {
        //  grassXOffset1[i] += grassSize;
        //}
        game.tabFloor[2].setGrassXOffset(grassSize * 24 + grassSize);
        game.tabFloor[2].updateRect();
      }
      //-1190

      c.translate(-j.toDouble(), 0);
      //-game.screenSize.width * 0.1 + game.screenSize.width * 0.1);
    } else
      isInit = false;
    // restore original state
    //c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void setOpacity(double _opacity) {
    if (_opacity <= 0) _opacity = 0;

    opacity = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  Paint getOpacity() {
    return opacity;
  }

  void jump() {
    j += 3 * screenSpeed;
    game.setPlayerState(1);
    hasChanged = false;
  }

  void update(double t) {}
}
