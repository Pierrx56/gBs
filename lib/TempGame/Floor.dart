import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/TempGame/TempGame.dart';

class Floor {}

double balloonPosition = 0.1;
int k = 0;
int screenSpeed = 2;
bool isInit;
bool isTheFirstPlatform;
Vector2 grassSize;
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

  Vector2 posCoin0;
  Vector2 posCoin1;
  Vector2 posCoin2;
  Vector2 posGrassLeft;
  Vector2 posGrass0;
  Vector2 posGrass1;
  Vector2 posGrass2;
  Vector2 posGrass3;
  Vector2 posGrass4;
  Vector2 posFlag;
  Vector2 posGrass5;
  Vector2 posGrass6;
  Vector2 posGrass7;
  Vector2 posGrass8;
  Vector2 posGrass9;
  Vector2 posGrass10;
  Vector2 posGrass11;
  Vector2 posGrassRight;

  Vector2 coinSize;
  Vector2 grassSize;

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

  //TODO Condition si coinSprite.length null dans Temp.dart
  _loadImage() async {
    coinSprite = [
      Sprite(await Flame.images.load(coins[0])),
      Sprite(await Flame.images.load(coins[1])),
      Sprite(await Flame.images.load(coins[2])),
      Sprite(await Flame.images.load(coins[3])),
      Sprite(await Flame.images.load(coins[4])),
      Sprite(await Flame.images.load(coins[5])),
      Sprite(await Flame.images.load(coins[6])),
      Sprite(await Flame.images.load(coins[7])),
      Sprite(await Flame.images.load(coins[8])),
      Sprite(await Flame.images.load(coins[9])),
      Sprite(await Flame.images.load(coins[10])),
      Sprite(await Flame.images.load(coins[11])),
      Sprite(await Flame.images.load(coins[12])),
      Sprite(await Flame.images.load(coins[13])),
      Sprite(await Flame.images.load(coins[14])),
      Sprite(await Flame.images.load(coins[15]))
    ];
    flag = Sprite(await Flame.images.load('temp/flag.png'));
    grass = Sprite(await Flame.images.load('temp/grass.png'));
    grassRight = Sprite(await Flame.images.load('temp/grass_right.png'));
    grassLeft = Sprite(await Flame.images.load('temp/grass_left.png'));

    if(coinSprite != null && flag != null && grass != null && grassRight != null && grassLeft != null) {
      game.hasLoadSpriteBottom = true;
    }
  }

  BottomFloor(this.game) {
    _loadImage();
    //width: 500
    //height: 300

    grassSize =
        Vector2(game.screenSize.width * 0.1, game.screenSize.width * 0.1);

    coinSize =
        Vector2(game.screenSize.width * 0.05, game.screenSize.width * 0.05);

    j = 0;
    hasChanged = false;
    blockOne = false;

    setGrassXOffset(0);

    grassXOffset = getGrassXOffset();

    grassYOffset = game.screenSize.height - grassSize[0];

    updateRect();
  }

  void setGrassXOffset(double offset) {
    grassXOffset = [
      0 + offset,
      1 * grassSize[0] + offset,
      2 * grassSize[0] + offset,
      3 * grassSize[0] + offset,
      4 * grassSize[0] + offset,
      5 * grassSize[0] + offset,
      6 * grassSize[0] + offset,
      7 * grassSize[0] + offset,
      8 * grassSize[0] + offset,
      9 * grassSize[0] + offset,
      10 * grassSize[0] + offset,
      11 * grassSize[0] + offset,
      12 * grassSize[0] + offset,
      13 * grassSize[0] + offset,
    ];
  }

  List<double> getGrassXOffset() {
    return grassXOffset;
  }

  int getLength() {
    return grassXOffset.length;
  }

  void updateRect() {
    posGrassLeft = Vector2(grassXOffset[0], grassYOffset);
    posCoin0 = Vector2(grassXOffset[0], grassYOffset - coinSize[0]);
    posCoin1 =
        Vector2(grassXOffset[0] + coinSize[0] / 2, grassYOffset - coinSize[0]);
    posCoin2 =
        Vector2(grassXOffset[0] + coinSize[0], grassYOffset - coinSize[0]);
    posGrass0 = Vector2(grassXOffset[1], grassYOffset);
    posGrass1 = Vector2(grassXOffset[2], grassYOffset);
    posGrass2 = Vector2(grassXOffset[3], grassYOffset);
    posGrass3 = Vector2(grassXOffset[4], grassYOffset);
    posGrass4 = Vector2(grassXOffset[5], grassYOffset);
    posFlag = Vector2(grassXOffset[5], grassYOffset - grassSize[0]);
    posGrass5 = Vector2(grassXOffset[6], grassYOffset);
    posGrass6 = Vector2(grassXOffset[7], grassYOffset);
    posGrass7 = Vector2(grassXOffset[8], grassYOffset);
    posGrass8 = Vector2(grassXOffset[9], grassYOffset);
    posGrass9 = Vector2(grassXOffset[10], grassYOffset);
    posGrass10 = Vector2(grassXOffset[11], grassYOffset);
    posGrass11 = Vector2(grassXOffset[12], grassYOffset);
    posGrassRight = Vector2(grassXOffset[13], grassYOffset);

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
    if (game.hasLoadSpriteBottom) {
      grassLeft?.render(c,
          position: posGrassLeft, size: grassSize, overridePaint: getOpacity());
      coinSprite[k]?.render(c,
          position: posCoin0, size: coinSize, overridePaint: getOpacityC0());
      coinSprite[k]?.render(c,
          position: posCoin1, size: coinSize, overridePaint: getOpacityC1());
      coinSprite[k]?.render(c,
          position: posCoin2, size: coinSize, overridePaint: getOpacityC2());
      grass?.render(c,
          position: posGrass0, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass1, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass2, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass3, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass4, size: grassSize, overridePaint: getOpacity());
      flag?.render(c,
          position: posFlag, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass5, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass6, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass7, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass8, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass9, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass10, size: grassSize, overridePaint: getOpacity());
      grass?.render(c,
          position: posGrass11, size: grassSize, overridePaint: getOpacity());
      grassRight?.render(c,
          position: posGrassRight,
          size: grassSize,
          overridePaint: getOpacity());
    }
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

  Vector2 posCoin0;
  Vector2 posCoin1;
  Vector2 posCoin2;
  Vector2 posGrassLeft;
  Vector2 posGrass0;
  Vector2 posGrass1;
  Vector2 posGrass2;
  Vector2 posGrass3;
  Vector2 posGrass4;
  Vector2 posFlag;
  Vector2 posGrass5;
  Vector2 posGrass6;
  Vector2 posGrass7;
  Vector2 posGrass8;
  Vector2 posGrass9;
  Vector2 posGrass10;
  Vector2 posGrass11;
  Vector2 posGrassRight;

  Vector2 coinSize;
  Vector2 grassSize;

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

  _loadImage() async {
    coinSprite = [
      Sprite(await Flame.images.load(coins[0])),
      Sprite(await Flame.images.load(coins[1])),
      Sprite(await Flame.images.load(coins[2])),
      Sprite(await Flame.images.load(coins[3])),
      Sprite(await Flame.images.load(coins[4])),
      Sprite(await Flame.images.load(coins[5])),
      Sprite(await Flame.images.load(coins[6])),
      Sprite(await Flame.images.load(coins[7])),
      Sprite(await Flame.images.load(coins[8])),
      Sprite(await Flame.images.load(coins[9])),
      Sprite(await Flame.images.load(coins[10])),
      Sprite(await Flame.images.load(coins[11])),
      Sprite(await Flame.images.load(coins[12])),
      Sprite(await Flame.images.load(coins[13])),
      Sprite(await Flame.images.load(coins[14])),
      Sprite(await Flame.images.load(coins[15]))
    ];
    flag = Sprite(await Flame.images.load('temp/flag.png'));
    grass = Sprite(await Flame.images.load('temp/grass.png'));
    grassRight = Sprite(await Flame.images.load('temp/grass_right.png'));
    grassLeft = Sprite(await Flame.images.load('temp/grass_left.png'));

    if(coinSprite != null && flag != null && grass != null && grassRight != null && grassLeft != null)
      game.hasLoadSpriteFirst = true;

  }

  FirstFloor(this.game) {
    _loadImage();
    //width: 500
    //height: 300

    grassSize =
        Vector2(game.screenSize.width * 0.1, game.screenSize.width * 0.1);

    coinSize =
        Vector2(game.screenSize.width * 0.05, game.screenSize.width * 0.05);

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
      16 * grassSize[0] + offset,
      17 * grassSize[0] + offset,
      18 * grassSize[0] + offset,
      19 * grassSize[0] + offset,
      20 * grassSize[0] + offset,
      21 * grassSize[0] + offset,
      22 * grassSize[0] + offset,
      23 * grassSize[0] + offset,
      24 * grassSize[0] + offset,
      25 * grassSize[0] + offset,
      26 * grassSize[0] + offset,
      27 * grassSize[0] + offset,
      28 * grassSize[0] + offset,
      29 * grassSize[0] + offset,
    ];
  }

  List<double> getGrassXOffset() {
    return grassXOffset;
  }

  int getLength() {
    return grassXOffset.length;
  }

  void updateRect() {
    posGrassLeft = Vector2(grassXOffset[0], grassYOffset1);
    posCoin0 = Vector2(grassXOffset[0], grassYOffset1 - coinSize[0]);
    posCoin1 =
        Vector2(grassXOffset[0] + coinSize[0] / 2, grassYOffset1 - coinSize[0]);
    posCoin2 =
        Vector2(grassXOffset[0] + coinSize[0], grassYOffset1 - coinSize[0]);
    posGrass0 = Vector2(grassXOffset[1], grassYOffset1);
    posGrass1 = Vector2(grassXOffset[2], grassYOffset1);
    posGrass2 = Vector2(grassXOffset[3], grassYOffset1);
    posGrass3 = Vector2(grassXOffset[4], grassYOffset1);
    posGrass4 = Vector2(grassXOffset[5], grassYOffset1);
    posFlag = Vector2(grassXOffset[5], grassYOffset1 - grassSize[0]);
    posGrass5 = Vector2(grassXOffset[6], grassYOffset1);
    posGrass6 = Vector2(grassXOffset[7], grassYOffset1);
    posGrass7 = Vector2(grassXOffset[8], grassYOffset1);
    posGrass8 = Vector2(grassXOffset[9], grassYOffset1);
    posGrass9 = Vector2(grassXOffset[10], grassYOffset1);
    posGrass10 = Vector2(grassXOffset[11], grassYOffset1);
    posGrass11 = Vector2(grassXOffset[12], grassYOffset1);
    posGrassRight = Vector2(grassXOffset[13], grassYOffset1);
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

    if (game.hasLoadSpriteFirst) {
      grassLeft.render(c,
          position: posGrassLeft, size: grassSize, overridePaint: getOpacity());
      coinSprite[k].render(c,
          position: posCoin0, size: coinSize, overridePaint: getOpacityC0());
      coinSprite[k].render(c,
          position: posCoin1, size: coinSize, overridePaint: getOpacityC1());
      coinSprite[k].render(c,
          position: posCoin2, size: coinSize, overridePaint: getOpacityC2());
      grass.render(c,
          position: posGrass0, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass1, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass2, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass3, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass4, size: grassSize, overridePaint: getOpacity());
      flag.render(c,
          position: posFlag, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass5, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass6, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass7, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass8, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass9, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass10, size: grassSize, overridePaint: getOpacity());
      grass.render(c,
          position: posGrass11, size: grassSize, overridePaint: getOpacity());
      grassRight.render(c,
          position: posGrassRight,
          size: grassSize,
          overridePaint: getOpacity());
    }
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
  int jOffset = 0;

  ManageFloors(this.game) {
    grassSize =
        Vector2(game.screenSize.width * 0.1, game.screenSize.width * 0.1);

    hasChanged = false;
    blockOne = false;
  }

  void render(Canvas c, bool pause, bool isMoving) {
/*    if(isMoving)
      c.translate(-game.screenSize.width / 2,
          -game.screenSize.height * (1 - balloonPosition));*/

    if (isMoving) {
      //if (!pause && !game.launchTuto) j += screenSpeed;

      if (!isInit) {
        offset = game.tempPosX.toInt();
        posFloorY = 0;
        j = 0;
        walkTillVoid = 0;
        isInit = true;
        isTheFirstPlatform = true;
      }

      //Ne pas faire avancer les blocs pendant qu'il pousse
      /*if ((game.isWaiting) && game.getPush() > 0.0 && !pause) {
        j -= screenSpeed;
      }*/

      //S'il dépasse le drapeau, on marche jusqu'au bout de la dernière herbe
      if (game.isPushable && !game.isAtEdge) {

        //if (!pause) walkTillVoid += screenSpeed;
        if (!pause) walkTillVoid += jOffset;

        if (!isTheFirstPlatform)
          jumpOffset = grassSize[0];
        else
          jumpOffset = grassSize[0] * 0.5;

        if (game.tabBottomFloor[game.getCurrentFloor()].getFlagPosition() +
                    walkTillVoid >
                game.tabBottomFloor[game.getCurrentFloor()].getGrassXOffset()[
                        game.tabBottomFloor[0].getLength() - 1] +
                    jumpOffset &&
            !game.hasJumped &&
            !blockOne) {
          game.isAtEdge = true;
          //j -= screenSpeed;
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
          //j -= screenSpeed;
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
                  grassSize[0] / 2 &&
          j <=
              game.tabFloor[game.getCurrentFloor()].grassXOffset[0] -
                  offset -
                  grassSize[0] / 2 &&
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
                  grassSize[0] / 2 &&
          j <=
              game.tabBottomFloor[game.getCurrentFloor()].grassXOffset[0] -
                  offset -
                  grassSize[0] / 2 &&
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
                3 * grassSize[0]);
        game.tabBottomFloor[0].setOpacityC0(1);
        game.tabBottomFloor[0].setOpacityC1(0);
        game.tabBottomFloor[0].setOpacityC2(0);
        game.tabBottomFloor[0].updateRect();

        temps = game.tabBottomFloor[0].getGrassXOffset();
        firstFloorY = game.floorPosition[2];
        grassYOffset = firstFloorY;
        game.tabBottomFloor[1].setGrassXOffset(temps[0] + grassSize[0] / 2);
        game.tabBottomFloor[1].setOpacityC0(1);
        game.tabBottomFloor[1].setOpacityC1(1);
        game.tabBottomFloor[1].setOpacityC2(0);
        game.tabBottomFloor[1].updateRect();

        temps = game.tabBottomFloor[1].getGrassXOffset();
        firstFloorY = game.floorPosition[3];
        grassYOffset = firstFloorY;
        game.tabBottomFloor[2].setGrassXOffset(temps[0] + grassSize[0] / 2);
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
        game.tabFloor[1].setGrassXOffset(temps[0] + grassSize[0] / 2);
        game.tabFloor[1].setOpacityC0(1);
        game.tabFloor[1].setOpacityC1(1);
        game.tabFloor[1].setOpacityC2(0);
        game.tabFloor[1].updateRect();

        firstFloorY = game.floorPosition[3];
        grassYOffset1 = firstFloorY;
        game.tabFloor[2].setGrassXOffset(temps[0] + grassSize[0]);
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

  void update(double t) {}
}

//Classe qui gère le déplacement horizontal du panneau
class ManageSign {
  final TempGame game;
  Sprite sign;
  Rect rectSign;
  bool hasChanged;
  Paint opacity; // = Paint()..color = Colors.white.withOpacity(opacity);
  Vector2 sizeSign;
  Vector2 posSign;
  double posSignY;
  TextConfig config = TextConfig(fontSize: 48.0, fontFamily: 'Awesome Font');

  var image;

  _loadImage() async {
    image = await Flame.images.load('temp/clear_sign.png');
    sign = Sprite(image);
  }

  ManageSign(this.game) {
    grassSize =
        Vector2(game.screenSize.width * 0.1, game.screenSize.width * 0.1);
    sizeSign =
        Vector2(game.screenSize.width * 0.2, game.screenSize.width * 0.2);

    posSign = Vector2(
        game.screenSize.width / 2 + sizeSign[0], game.screenSize.height);
    posSignY = posSign[1];

    _loadImage();
    updateRect();
  }

  void updateRect() {
    posSign = Vector2(game.screenSize.width / 2 + sizeSign[0], posSignY);
  }

  void render(Canvas c, bool pause, bool isMoving) {
    if (isMoving) c.translate(0, 0);

    if (!pause) {
      //Gestion de la position des panneaux
      //Montée du panneau
      if (game.hasJumped && posSign[1] > game.screenSize.height - sizeSign[0] ||
          game.isDisplayingSign &&
              posSign[1] > game.screenSize.height - sizeSign[0]) {
        game.isDisplayingSign = true;
        posSignY -= 2;
        updateRect();
      }
      //Descente du panneau
      else if (!game.hasJumped && posSign[1] < game.screenSize.height) {
        game.isDisplayingSign = false;
        posSignY += 2;
        updateRect();
      } else
        game.isDisplayingSign = false;

      if (sign != null) sign.render(c, position: posSign, size: sizeSign);

      //TODO Check position text
      config.render(
          c,
          "${game.jumpCounter}/10",
          Vector2(
              posSign[0] + sizeSign[0] * 0.1, posSign[1] + sizeSign[1] * 0.1));

      //Position(posXSign + signWidth * 0.1, posYSign + signHeight * 0.1));

      //128
      // restore original state
      //c.restore();
    }
  }

  void update(double t) {}
}
