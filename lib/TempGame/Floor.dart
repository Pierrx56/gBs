import 'dart:async';
import 'dart:ui';
import 'package:flame/anchor.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
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
double coinSize;
double firstFloorY;
double posFloorY;
int offset = 0;
bool blockOne;

double grassYOffset;
double grassYOffset1;

class BottomFloor {
  final TempGame game;
  List<Sprite> coinSprite;
  Sprite flag;
  Sprite grass;
  Sprite grassLeft;
  Sprite grassRight;

  Rect rectCoin0;
  Rect rectCoin1;
  Rect rectCoin2;
  Rect rectGrassLeft;
  Rect rectGrass0;
  Rect rectGrass1;
  Rect rectGrass2;
  Rect rectGrass3;
  Rect rectGrass4;
  Rect rectFlag;
  Rect rectGrass5;
  Rect rectGrass6;
  Rect rectGrass7;
  Rect rectGrass8;
  Rect rectGrass9;
  Rect rectGrass10;
  Rect rectGrass11;
  Rect rectGrassRight;
  bool hasChanged;
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  Paint opacityC0; // = Paint()..color = Colors.white.withOpacity(opacity);
  Paint opacityC1; // = Paint()..color = Colors.white.withOpacity(opacity);
  Paint opacityC2; // = Paint()..color = Colors.white.withOpacity(opacity);
  int j = 0;
  List<double> grassXOffset = [];
  int increment = 0;

  static List<String> coins = [
    'temp/coin1.png',
    'temp/coin2.png',
    'temp/coin3.png',
    'temp/coin4.png',
    'temp/coin5.png',
    'temp/coin6.png',
    'temp/coin7.png',
    'temp/coin8.png',
    'temp/coin9.png',
    'temp/coin10.png',
    'temp/coin11.png',
    'temp/coin12.png',
    'temp/coin13.png',
    'temp/coin14.png',
    'temp/coin15.png',
    'temp/coin16.png'
  ];

  BottomFloor(this.game) {
    coinSprite = [
      Sprite(coins[0]),
      Sprite(coins[1]),
      Sprite(coins[2]),
      Sprite(coins[3]),
      Sprite(coins[4]),
      Sprite(coins[5]),
      Sprite(coins[6]),
      Sprite(coins[7]),
      Sprite(coins[8]),
      Sprite(coins[9]),
      Sprite(coins[10]),
      Sprite(coins[11]),
      Sprite(coins[12]),
      Sprite(coins[13]),
      Sprite(coins[14]),
      Sprite(coins[15]),
    ];
    flag = Sprite('temp/flag.png');
    grass = Sprite('temp/grass.png');
    grassRight = Sprite('temp/grass_right.png');
    grassLeft = Sprite('temp/grass_left.png');
    //width: 500
    //height: 300
    grassSize = game.screenSize.width * 0.1;
    coinSize = game.screenSize.width * 0.05;

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
      9 * grassSize + offset,
      10 * grassSize + offset,
      11 * grassSize + offset,
      12 * grassSize + offset,
      13 * grassSize + offset,
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
    rectCoin0 = Rect.fromLTWH(
        grassXOffset[0], grassYOffset - coinSize, coinSize, coinSize);
    rectCoin1 = Rect.fromLTWH(grassXOffset[0] + coinSize / 2,
        grassYOffset - coinSize, coinSize, coinSize);
    rectCoin2 = Rect.fromLTWH(grassXOffset[0] + coinSize,
        grassYOffset - coinSize, coinSize, coinSize);
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
    rectFlag = Rect.fromLTWH(grassXOffset[5], grassYOffset - grassSize,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass5 = Rect.fromLTWH(grassXOffset[6], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass6 = Rect.fromLTWH(grassXOffset[7], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass7 = Rect.fromLTWH(grassXOffset[8], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass8 = Rect.fromLTWH(grassXOffset[9], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass9 = Rect.fromLTWH(grassXOffset[10], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass10 = Rect.fromLTWH(grassXOffset[11], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass11 = Rect.fromLTWH(grassXOffset[12], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrassRight = Rect.fromLTWH(grassXOffset[13], grassYOffset,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
  }

  void render(Canvas c, bool pause, bool isMoving) {
    if (isMoving) c.translate(0, 0);

    //Change coins sprite
    increment++;
    if (increment % 8 == 0) {
      if (k < 15)
        k++;
      else
        k = 0;
    }
    grassLeft.renderRect(c, rectGrassLeft, overridePaint: getOpacity());
    coinSprite[k].renderRect(c, rectCoin0, overridePaint: getOpacityC0());
    coinSprite[k].renderRect(c, rectCoin1, overridePaint: getOpacityC1());
    coinSprite[k].renderRect(c, rectCoin2, overridePaint: getOpacityC2());
    grass.renderRect(c, rectGrass0, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass1, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass2, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass3, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass4, overridePaint: getOpacity());
    flag.renderRect(c, rectFlag, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass5, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass6, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass7, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass8, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass9, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass10, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass11, overridePaint: getOpacity());
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

  void setOpacityC0(double _opacity) {
    if (_opacity <= 0) _opacity = 0;
    opacityC0 = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  void setOpacityC1(double _opacity) {
    if (_opacity <= 0) _opacity = 0;
    opacityC1 = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  void setOpacityC2(double _opacity) {
    if (_opacity <= 0) _opacity = 0;
    opacityC2 = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  Paint getOpacity() {
    return opacity;
  }

  Paint getOpacityC0() {
    return opacityC0;
  }

  Paint getOpacityC1() {
    return opacityC1;
  }

  Paint getOpacityC2() {
    return opacityC2;
  }

  double getFlagPosition() {
    return getGrassXOffset()[5];
  }

  double getCoinsPosition() {
    return getGrassXOffset()[0];
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
  List<Sprite> coinSprite;
  Sprite flag;
  Sprite grass;
  Sprite grassRight;
  Sprite grassLeft;

  Rect rectCoin0;
  Rect rectCoin1;
  Rect rectCoin2;
  Rect rectGrassLeft;
  Rect rectGrass0;
  Rect rectGrass1;
  Rect rectGrass2;
  Rect rectGrass3;
  Rect rectGrass4;
  Rect rectFlag;
  Rect rectGrass5;
  Rect rectGrass6;
  Rect rectGrass7;
  Rect rectGrass8;
  Rect rectGrass9;
  Rect rectGrass10;
  Rect rectGrass11;
  Rect rectGrassRight;

  bool hasChanged;
  bool isPassed = false;
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  Paint opacityC0; // = Paint()..color = Colors.white.withOpacity(opacity);
  Paint opacityC1; // = Paint()..color = Colors.white.withOpacity(opacity);
  Paint opacityC2; // = Paint()..color = Colors.white.withOpacity(opacity);
  List<double> grassXOffset = [];
  int increment = 0;

  static List<String> coins = [
    'temp/coin1.png',
    'temp/coin2.png',
    'temp/coin3.png',
    'temp/coin4.png',
    'temp/coin5.png',
    'temp/coin6.png',
    'temp/coin7.png',
    'temp/coin8.png',
    'temp/coin9.png',
    'temp/coin10.png',
    'temp/coin11.png',
    'temp/coin12.png',
    'temp/coin13.png',
    'temp/coin14.png',
    'temp/coin15.png',
    'temp/coin16.png'
  ];

  FirstFloor(this.game) {
    coinSprite = [
      Sprite(coins[0]),
      Sprite(coins[1]),
      Sprite(coins[2]),
      Sprite(coins[3]),
      Sprite(coins[4]),
      Sprite(coins[5]),
      Sprite(coins[6]),
      Sprite(coins[7]),
      Sprite(coins[8]),
      Sprite(coins[9]),
      Sprite(coins[10]),
      Sprite(coins[11]),
      Sprite(coins[12]),
      Sprite(coins[13]),
      Sprite(coins[14]),
      Sprite(coins[15]),
    ];
    flag = Sprite('temp/flag.png');
    grass = Sprite('temp/grass.png');
    grassRight = Sprite('temp/grass_right.png');
    grassLeft = Sprite('temp/grass_left.png');
    //width: 500
    //height: 300

    grassYOffset1 = firstFloorY;

    setGrassXOffset(0);

    grassXOffset = getGrassXOffset();
    increment = 0;
    k = 0;
    hasChanged = false;

    updateRect();
  }

  void setGrassXOffset(double offset) {
    grassXOffset = [
      16 * grassSize + offset,
      17 * grassSize + offset,
      18 * grassSize + offset,
      19 * grassSize + offset,
      20 * grassSize + offset,
      21 * grassSize + offset,
      22 * grassSize + offset,
      23 * grassSize + offset,
      24 * grassSize + offset,
      25 * grassSize + offset,
      26 * grassSize + offset,
      27 * grassSize + offset,
      28 * grassSize + offset,
      29 * grassSize + offset,
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
    rectCoin0 = Rect.fromLTWH(
        grassXOffset[0], grassYOffset1 - coinSize, coinSize, coinSize);
    rectCoin1 = Rect.fromLTWH(grassXOffset[0] + coinSize / 2,
        grassYOffset1 - coinSize, coinSize, coinSize);
    rectCoin2 = Rect.fromLTWH(grassXOffset[0] + coinSize,
        grassYOffset1 - coinSize, coinSize, coinSize);
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
    rectFlag = Rect.fromLTWH(grassXOffset[5], grassYOffset1 - grassSize,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass5 = Rect.fromLTWH(grassXOffset[6], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass6 = Rect.fromLTWH(grassXOffset[7], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass7 = Rect.fromLTWH(grassXOffset[8], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass8 = Rect.fromLTWH(grassXOffset[9], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass9 = Rect.fromLTWH(grassXOffset[10], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass10 = Rect.fromLTWH(grassXOffset[11], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    rectGrass11 = Rect.fromLTWH(grassXOffset[12], grassYOffset1,
        game.screenSize.width * 0.1, game.screenSize.width * 0.1);

    rectGrassRight = Rect.fromLTWH(grassXOffset[13], grassYOffset1,
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
    //Change coins sprite
    increment++;
    if (increment % 8 == 0) {
      if (k < 15)
        k++;
      else
        k = 0;
    }

    grassLeft.renderRect(c, rectGrassLeft, overridePaint: getOpacity());
    coinSprite[k].renderRect(c, rectCoin0, overridePaint: getOpacityC0());
    coinSprite[k].renderRect(c, rectCoin1, overridePaint: getOpacityC1());
    coinSprite[k].renderRect(c, rectCoin2, overridePaint: getOpacityC2());
    grass.renderRect(c, rectGrass0, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass1, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass2, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass3, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass4, overridePaint: getOpacity());
    flag.renderRect(c, rectFlag, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass5, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass6, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass7, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass8, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass9, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass10, overridePaint: getOpacity());
    grass.renderRect(c, rectGrass11, overridePaint: getOpacity());
    grassRight.renderRect(c, rectGrassRight, overridePaint: getOpacity());
    // restore original state
    //c.restore();
  }

  void setOpacity(double _opacity) {
    if (_opacity <= 0) _opacity = 0;

    opacity = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  void setOpacityC0(double _opacity) {
    if (_opacity <= 0) _opacity = 0;
    opacityC0 = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  void setOpacityC1(double _opacity) {
    if (_opacity <= 0) _opacity = 0;
    opacityC1 = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  void setOpacityC2(double _opacity) {
    if (_opacity <= 0) _opacity = 0;
    opacityC2 = Paint()..color = Colors.white.withOpacity(_opacity);
  }

  Paint getOpacity() {
    return opacity;
  }

  Paint getOpacityC0() {
    return opacityC0;
  }

  Paint getOpacityC1() {
    return opacityC1;
  }

  Paint getOpacityC2() {
    return opacityC2;
  }

  double getFlagPosition() {
    return getGrassXOffset()[5];
  }

  double getCoinsPosition() {
    return getGrassXOffset()[0];
  }

  void update(double t) {}
}

//Classe qui gère le déplacement horizontal des plateformes
class ManageFloors {
  final TempGame game;
  bool hasChanged;
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  int j;
  int walkTillVoid;
  double jumpOffset = 0.0;

  ManageFloors(this.game) {
    grassSize = game.screenSize.width * 0.1;

    hasChanged = false;
    blockOne = false;
  }

  void render(Canvas c, bool pause, bool isMoving) {
/*    if(isMoving)
      c.translate(-game.screenSize.width / 2,
          -game.screenSize.height * (1 - balloonPosition));*/

    if (isMoving) {
      if (!pause && !game.launchTuto) j += screenSpeed;

      if (!isInit) {
        offset = game.tempPosX.toInt();
        posFloorY = 0;
        j = 0;
        walkTillVoid = 0;
        isInit = true;
        isTheFirstPlatform = true;
      }

      //Ne pas faire avancer les blocs pendant qu'il pousse
      if ((game.isWaiting) && game.getPush() > 0.0 && !pause) {
        j -= screenSpeed;
      }

      //S'il dépasse le drapeau, on marche jusqu'au bout de la dernière herbe
      if (game.isPushable && !game.isAtEdge) {
        if (!pause) walkTillVoid += screenSpeed;

        if (!isTheFirstPlatform)
          jumpOffset = grassSize;
        else
          jumpOffset = grassSize * 0.5;


        if (game.tabBottomFloor[game.getCurrentFloor()].getFlagPosition() +
                    walkTillVoid >
                game.tabBottomFloor[game.getCurrentFloor()].getGrassXOffset()[
                        game.tabBottomFloor[0].getLength() - 1] +
                    jumpOffset &&
            !game.hasJumped &&
            !blockOne) {
          game.isAtEdge = true;
          j -= screenSpeed;
          //isMoving = false;
          if (!hasChanged) {
            //Waiting
            game.setPlayerState(2);
            hasChanged = true;
          }
        } else if (game.tabFloor[game.getCurrentFloor()].getFlagPosition() +
                    walkTillVoid >
                game.tabFloor[game.getCurrentFloor()]
                        .getGrassXOffset()[game.tabFloor[0].getLength() - 1] +
                    jumpOffset &&
            !game.hasJumped &&
            blockOne) {
          game.isAtEdge = true;
          j -= screenSpeed;
          //isMoving = false;
          if (!hasChanged) {
            //Waiting
            game.setPlayerState(2);
            hasChanged = true;
          }
        }
      } else {
        //if (!pause) j -= screenSpeed;
        walkTillVoid = 0;
      }

      //Vide à sauter
      if (j >=
              game.tabBottomFloor[game.getPreviousFloor()].grassXOffset[
                      game.tabBottomFloor[game.getPreviousFloor()].getLength() -
                          1] -
                  offset -
                  grassSize / 2 &&
          j <=
              game.tabFloor[game.getCurrentFloor()].grassXOffset[0] -
                  offset -
                  grassSize / 2 &&
          game.hasJumped &&
          !blockOne) {
        game.isAtEdge = false;
        jump();
        //blockOne = true;
      } else if (j >=
              game.tabFloor[game.getPreviousFloor()].grassXOffset[
                      game.tabBottomFloor[game.getPreviousFloor()].getLength() -
                          1] -
                  offset -
                  grassSize / 2 &&
          j <=
              game.tabBottomFloor[game.getCurrentFloor()].grassXOffset[0] -
                  offset -
                  grassSize / 2 &&
          game.hasJumped &&
          blockOne) {
        game.isAtEdge = false;
        jump();
        //blockOne = false;
      }

      //Déplacement du bloc à la suite de l'ancien
      //BlockOne = false
      //if (game.getFloor() != 0 && j - 2*grassSize > game.tabBottomFloor[game.getFloor() - 1].grassXOffset[
      //            game.tabBottomFloor[game.getFloor() - 1].getLength() - 1] + grassSize * 1) {
      if (game.getFloor() != 0 && game.isOutOfScreen && !blockOne) {
        game.tabBottomFloor[0].setOpacity(1);
        game.tabBottomFloor[1].setOpacity(1);
        game.tabBottomFloor[2].setOpacity(1);
        game.isOutOfScreen = false;
        blockOne = true;

        //Placement des plateformes en fonction de la plateforme précédente
        List<double> temps =
            game.tabFloor[game.getCurrentFloor()].getGrassXOffset();
        firstFloorY = game.floorPosition[1];
        grassYOffset = firstFloorY;
        game.tabBottomFloor[0].setGrassXOffset(
            temps[game.tabFloor[game.getCurrentFloor()].getLength() - 1] +
                3 * grassSize);
        game.tabBottomFloor[0].setOpacityC0(1);
        game.tabBottomFloor[0].setOpacityC1(0);
        game.tabBottomFloor[0].setOpacityC2(0);
        game.tabBottomFloor[0].updateRect();

        temps = game.tabBottomFloor[0].getGrassXOffset();
        firstFloorY = game.floorPosition[2];
        grassYOffset = firstFloorY;
        game.tabBottomFloor[1].setGrassXOffset(temps[0] + grassSize / 2);
        game.tabBottomFloor[1].setOpacityC0(1);
        game.tabBottomFloor[1].setOpacityC1(1);
        game.tabBottomFloor[1].setOpacityC2(0);
        game.tabBottomFloor[1].updateRect();

        temps = game.tabBottomFloor[1].getGrassXOffset();
        firstFloorY = game.floorPosition[3];
        grassYOffset = firstFloorY;
        game.tabBottomFloor[2].setGrassXOffset(temps[0] + grassSize / 2);
        game.tabBottomFloor[2].setOpacityC0(1);
        game.tabBottomFloor[2].setOpacityC1(1);
        game.tabBottomFloor[2].setOpacityC2(1);
        game.tabBottomFloor[2].updateRect();
      }
      //else if (game.getFloor() != 0 && j - 2*grassSize >  game.tabFloor[game.getFloor() - 1].grassXOffset[
      //  game.tabFloor[game.getFloor() - 1].getLength() - 1] + grassSize * 1) {
      else if (game.getFloor() != 0 && game.isOutOfScreen && blockOne) {
        game.tabFloor[0].setOpacity(1);
        game.tabFloor[1].setOpacity(1);
        game.tabFloor[2].setOpacity(1);
        game.isOutOfScreen = false;
        blockOne = false;

        List<double> temps =
            game.tabBottomFloor[game.getCurrentFloor()].getGrassXOffset();

        firstFloorY = game.floorPosition[1];
        grassYOffset1 = firstFloorY;
        game.tabFloor[0].setGrassXOffset(temps[0]);
        game.tabFloor[0].setOpacityC0(1);
        game.tabFloor[0].setOpacityC1(0);
        game.tabFloor[0].setOpacityC2(0);
        game.tabFloor[0].updateRect();

        firstFloorY = game.floorPosition[2];
        grassYOffset1 = firstFloorY;
        game.tabFloor[1].setGrassXOffset(temps[0] + grassSize / 2);
        game.tabFloor[1].setOpacityC0(1);
        game.tabFloor[1].setOpacityC1(1);
        game.tabFloor[1].setOpacityC2(0);
        game.tabFloor[1].updateRect();

        firstFloorY = game.floorPosition[3];
        grassYOffset1 = firstFloorY;
        game.tabFloor[2].setGrassXOffset(temps[0] + grassSize);
        game.tabFloor[2].setOpacityC0(1);
        game.tabFloor[2].setOpacityC1(1);
        game.tabFloor[2].setOpacityC2(1);
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
    //Run
    game.setPlayerState(1);
    hasChanged = false;
  }

  void update(double t) {

  }
}

//Classe qui gère le déplacement horizontal du panneau
class ManageSign {
  final TempGame game;
  Sprite sign;
  Rect rectSign;
  bool hasChanged;
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  double signWidth;
  double signHeight;
  double posYSign;
  double posXSign;
  TextConfig config = TextConfig(fontSize: 48.0, fontFamily: 'Awesome Font');

  ManageSign(this.game) {
    grassSize = game.screenSize.width * 0.1;
    signWidth = game.screenSize.width * 0.2;
    signHeight = game.screenSize.width * 0.2;

    posYSign = game.screenSize.height;
    posXSign = game.screenSize.width / 2 + signWidth;
    sign = Sprite('temp/clear_sign.png');
    updateRect();
  }

  void updateRect() {
    rectSign = Rect.fromLTWH(posXSign, posYSign, signWidth, signHeight);
  }

  void render(Canvas c, bool pause, bool isMoving) {
    if (isMoving) c.translate(0, 0);

    if (!pause) {
      //Gestion de la position des panneaux
      //Montée du panneau
      if (game.hasJumped && posYSign > game.screenSize.height - signHeight ||
          game.isDisplayingSign &&
              posYSign > game.screenSize.height - signHeight) {
        game.isDisplayingSign = true;
        posYSign -= 2;
        updateRect();
      }
      //Descente du panneau
      else if (!game.hasJumped && posYSign < game.screenSize.height) {
        game.isDisplayingSign = false;
        posYSign += 2;
        updateRect();
      } else
        game.isDisplayingSign = false;

      sign.renderRect(c, rectSign);
      config.render(
          c, "${game.jumpCounter}/10", Position(posXSign + signWidth * 0.1, posYSign + signHeight*0.1));

      //128
      // restore original state
      //c.restore();
    }
  }

  void update(double t) {}
}

//Classe qui gère le déplacement vertical du drapeau
class ManageFlag {
  final TempGame game;
  Sprite flag;
  Rect rectFlag;
  bool hasChanged;
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  double signWidth;
  double signHeight;
  double posYSign;
  double posXSign;
  TextConfig config = TextConfig(fontSize: 48.0, fontFamily: 'Awesome Font');

  ManageFlag(this.game) {
    grassSize = game.screenSize.width * 0.1;
    signWidth = game.screenSize.width * 0.2;
    signHeight = game.screenSize.width * 0.2;

    posYSign = game.screenSize.height;
    posXSign = game.screenSize.width / 2 + signWidth;
    flag = Sprite('temp/clear_sign.png');
    updateRect();
  }

  void updateRect() {
    rectFlag = Rect.fromLTWH(posXSign, posYSign, signWidth, signHeight);
  }

  void render(Canvas c, bool pause, bool isMoving) {
    if (isMoving) c.translate(0, 0);

    if (!pause) {
      //Gestion de la position des panneaux
      //Montée du panneau
      if (game.hasJumped && posYSign > game.screenSize.height - signHeight ||
          game.isDisplayingSign &&
              posYSign > game.screenSize.height - signHeight) {
        game.isDisplayingSign = true;
        posYSign -= 2;
        updateRect();
      }
      //Descente du panneau
      else if (!game.hasJumped && posYSign < game.screenSize.height) {
        game.isDisplayingSign = false;
        posYSign += 2;
        updateRect();
      } else
        game.isDisplayingSign = false;

      flag.renderRect(c, rectFlag);
      config.render(
          c, "${game.jumpCounter}/10", Position(posXSign + 10, posYSign + 10));

      // restore original state
      //c.restore();
    }
  }

  void update(double t) {}
}
