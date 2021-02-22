import 'dart:async';
import 'dart:math';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/CarGame/Background.dart';
import 'package:gbsalternative/CarGame/Car.dart';
import 'package:gbsalternative/CarGame/Ui.dart';
import 'package:gbsalternative/CarGame/Road.dart';

class CarGame extends Game {
  Size screenSize;
  bool inTouch = false;
  Background background;
  StraightRoad staightRoad;
  CSI csi;
  TME tme;
  POLICE police;
  List<String> launchExercise = ["csi", "cmv", "repos", "tme"];
  SpriteComponent plane;
  double tileSize;
  bool redFilter;
  bool start;
  bool gameOver;
  bool isConnected;
  bool isInit;
  bool doingBreak;

  bool hasSetXFuel;
  bool fuelIsDown;
  bool isDoingExercice;
  bool isBeginning;

  //Count CMV/CSI/TME/Wait
  int CMVCounter;
  int CSICounter;
  int TMECounter;
  int waitCounter;
  int CMVLimit = 5;
  int CSILimit = 5;
  int TMELimit = 2;
  int waitLimit = 6;
  int randomNumber;

  int previousActivity = 0;

  int score = 0;
  int life = 0;
  int starLevel = 0;
  double starValue = 0.0;
  bool pauseGame;
  bool hasCrash = false;
  bool reset = false;
  double creationTimer = 0.0;
  double scoreTimer = 0.0;
  double tempPos = 0;
  double posY = 0;
  double posX = 0;
  int i = 0;
  double difficulte = 3.0;

  double sizeW = 130.0;
  double sizeH = 65.0;

  double Function() getData;
  User user;
  double posYBottomLine;
  double posYTopLine;
  bool posMax;
  bool posMid;
  UI gameUI;
  AppLanguage appLanguage;

  CarGame(this.getData, User _user, AppLanguage _appLanguage) {
    user = _user;
    appLanguage = _appLanguage;
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    background = Background(this);
    staightRoad = StraightRoad(this);
    //csi = CSI(this);
    //tme = TME(this);
    police = POLICE(this);
    gameUI = UI();

    life = 3;
    pauseGame = false;
    isInit = false;
    posMax = false;
    posMid = false;
    gameOver = false;
    isConnected = true;
    start = false;
    redFilter = false;

    hasSetXFuel = false;
    doingBreak = false;
    fuelIsDown = true;
    isDoingExercice = false;
    isBeginning = true;
    CMVCounter = 0;
    CSICounter = 0;
    TMECounter = 0;
    waitCounter = 0;
    randomNumber = 0;
    //3: wait
    previousActivity = 3;

    posYBottomLine = staightRoad.getYBottomPosition();
    staightRoad.setCarSize(sizeH);
  }

  void render(Canvas canvas) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    canvas.drawRect(bgRect, bgPaint);

    //String btData = _onDataReceiver();

    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;

    if (canvas != null) {
      //Background
      //if (background != null) background.render(canvas, pauseGame);

      if (!gameOver) {
        if (isConnected) {
          canvas.save();
          //Road
          if (staightRoad != null) {
            staightRoad.render(canvas, pauseGame, reset, hasCrash);
          }

          if (!isDoingExercice) {
            Random random = new Random();
            randomNumber = random.nextInt(4); // from 0 upto 3 included
            if (previousActivity != randomNumber || isBeginning) {
              if (isBeginning) {
                isBeginning = false;
                randomNumber = 3;
              }
              switch (randomNumber) {
                //CMV
                case 0:
                  //previousActivity = randomNumber;
                  break;
                //CSI
                case 1:
                  if (CSILimit > CSICounter) {
                    previousActivity = randomNumber;
                    isDoingExercice = true;
                    csi = CSI(this);
                    CSICounter++;
                  }
                  break;
                //TME
                case 2:
                  if (TMELimit > TMECounter) {
                    previousActivity = randomNumber;
                    isDoingExercice = true;
                    tme = new TME(this);
                    TMECounter++;
                  }
                  break;
                //Wait
                case 3:
                  if (waitLimit > waitCounter) {
                    previousActivity = randomNumber;
                    isDoingExercice = true;
                    startPause(true);
                    waitCounter++;
                    print("PAUUUUSE");
                  }

                  break;
                default:
                  break;
              }
            }
          }

          //Doubler voitures sur CMV
          //rattarper bariles entre alternativement entre 2 et 3 pour CSI

          if (tme != null) {
            tme.render(canvas, pauseGame, reset);
          }

          if (csi != null) {
            csi.render(canvas, pauseGame, reset);
          }

          if (police != null) {
            police.render(canvas, pauseGame, reset);
          }
          reset = false;
          canvas.restore();
          //Nageur
          if (plane != null) {
            plane.render(canvas);

            //game.screenSize.height * (1 - balloonPosition);
            posY = screenSize.height - plane.y - plane.height / 2;
            //print("PosY Plane: $posY");

            posX = screenSize.width / 2.5 - plane.width / 2;

            //HitBox PME bas
            if (tme != null) {
              if (posY + plane.height * 0.5 <
                  screenSize.height - widthRoad * 0.7 - tme.getHeight()) {
                //Hitbox Camion
                if (j * speedTruck -
                            screenSize.width / 2 +
                            tme.getWidth() * 0.6 >
                        tme.getXPosition(0) &&
                    j * speedTruck - screenSize.width / 2 <
                        tme.getXPosition(tme.truckList.length - 1) +
                            tme.getWidth() * 0.9) {
                  life--;
                  hasCrash = true;
                  //TODO stop timer game
                  Timer(Duration(seconds: 2), () {
                    hasCrash = false;
                  });
                }
                //Reset trucks spawn
                else if (j * speedTruck - screenSize.width / 2 >
                    tme.getXPosition(tme.truckList.length - 1) +
                        tme.getWidth() * 0.9) {
                  tme = null;
                  isDoingExercice = false;
                }
              } else if (j * speedTruck - screenSize.width - tme.getWidth() >
                  tme.getXPosition(tme.truckList.length - 1) +
                      tme.getWidth() * 0.9) {
                tme = null;
                isDoingExercice = false;
              }
            }

            //HitBox CSI bas
            if (csi != null) {
              //TODO a refaire pour voie 2 et 3

              //Hitbox fuel
              for (int i = 0; i < csi.fuelList.length - 1; i++) {
                /*  print(j - screenSize.width / 2);

                  print(csi.getXPosition(0) - 2 * csi.getWidth());

                  print(csi.getXPosition(0) - 1 * csi.getWidth());*/

                //bottom Fuel
                if (posY + plane.height * 0.5 <
                        screenSize.height - widthRoad * 0.7 - csi.getHeight() &&
                    fuelIsDown) {
                  if (j - screenSize.width / 2 >
                          csi.getXPosition(i) - 2 * csi.getWidth() &&
                      j - screenSize.width / 2 <
                          csi.getXPosition(i) - 1 * csi.getWidth()) {
                    if (!hasSetXFuel) {
                      csi.setPosXFuel();
                      hasSetXFuel = true;
                    }
                    print("Fuel bottom +1");
                  } else {
                    hasSetXFuel = false;
                  }
                }
                //Top Fuel
                else if (posMid && !fuelIsDown) {
                  if (j - screenSize.width / 2 >
                          csi.getXPosition(i) - 2 * csi.getWidth() &&
                      j - screenSize.width / 2 <
                          csi.getXPosition(i) - 1 * csi.getWidth()) {
                    if (!hasSetXFuel) {
                      csi.setPosXFuel();
                      hasSetXFuel = true;
                    }
                    print("Fuel TOP +1");
                  } else
                    hasSetXFuel = false;
                } else if (j - screenSize.width - csi.getWidth() >
                    csi.getXPosition(csi.fuelList.length - 1) -
                        2 * csi.getWidth()) {
                  csi = null;
                  isDoingExercice = false;
                  fuelIsDown = true;
                }
              }
            }

            if (posY <= staightRoad.getYBottomPosition() ||
                posY >= staightRoad.getYTopPosition()) {
              //if (posY <= staightRoad.getYBottomPosition())
              //print("Bottom");
              //else if (posY >= staightRoad.getYTopPosition()) print("Top");
            }
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
        if (creationTimer >= 0.04) {
          if (pauseGame) i = 0;

          creationTimer = 0.0;

          Sprite sprite = Sprite("car/green_car.png");

          plane = SpriteComponent.fromSprite(
              sizeW, sizeH, sprite); // width, height, sprite

          if (!isInit) {
            //Centrage du bonhomme en ordonnées
            posY = screenSize.height - plane.height - 50;
            plane.y = posY;
            isInit = true;
          }

          //Centrage de l'avion en abscisses
          plane.x = screenSize.width / 2.5 - plane.width / 2;
          //Définition des bords haut et bas de l'écran

          //Bas
          if (tempPos >= screenSize.height - sizeH - sizeH / 2) {
            plane.y = tempPos;
          }
          //Milieu
          else if (getData() > double.parse(user.userInitialPush) * 0.5 &&
              !posMid &&
              (tempPos <= screenSize.height * 0.5)) {
            posMid = true;
            plane.y = tempPos;

            print("mid");
          }
          //Haut
          else if (tempPos <= sizeH / 2 &&
              getData() > double.parse(user.userInitialPush) * 1.5) {
            //tempPos = 0.0;
            plane.y = tempPos;
            posMid = false;
            posMax = true;
            //tempPos = -size / 2;
            //plane.y = tempPos;
          }
          //Sinon on fait descendre l'avion
          else if (!posMid && !posMax) {
            plane.y += tempPos;
            tempPos = plane.y + difficulte * 3.0;
            if (pauseGame) tempPos = plane.y;
          } else {
            if (plane.y == 0.0) {
              plane.y = tempPos;
            }
            posMid = false;
            posMax = false;
          }
          //component = new Component(dimensions);
          //add(component);
        }

        if (!pauseGame) {
          //getData = données reçues par le Bluetooth
          //Montée de l'avion dans la 3 eme voie
          if (getData() > double.parse(user.userInitialPush) * 1.5 &&
              !posMax &&
              plane != null) {
            //tempPos >= screenSize.height / 2 - sizeH / 2) {
            //print(plane.y);
            plane.y -= difficulte;
            tempPos = plane.y;
            inTouch = false;
          }
          //Montée de l'avion 2nd voie
          else if (getData() > double.parse(user.userInitialPush) &&
              plane != null &&
              !posMid &&
              tempPos >= screenSize.height / 2 - sizeH / 2) {
            print(plane.y);
            plane.y -= difficulte;
            tempPos = plane.y;
            inTouch = false;
          }

          if (inTouch) {
            //print(plane.y);
            //plane.y -= 20.0;
            tempPos = plane.y;
            inTouch = false;
          }
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

  double getStarValue() {
    return starValue;
  }

  void setStarValue(double _starValue) {
    starValue = _starValue;
  }

  int getStarLevel() {
    return starLevel;
  }

  void setStarLevel(int _starLevel) {
    starLevel = _starLevel;
  }

  void setColorFilter(bool boolean) {
    redFilter = boolean;
  }

  void setRoadSpeed(int speed) {
    roadSpeed = speed;
  }

  ColorFilter getColorFilter() {
    if (redFilter) {
      return ColorFilter.mode(Colors.redAccent, BlendMode.hue);
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

  void startPause(bool boolean) async {
    double _start = 5.0;
    doingBreak = true;

    if (!boolean) {
      _start = 5.0;
      start = false;
    } else {
      const time = const Duration(seconds: 1);
      new Timer.periodic(
        time,
        (Timer timer) {
          if (_start < 1) {
            timer.cancel();
            doingBreak = false;
            isDoingExercice = false;
          } else {
            _start = _start - 1;
          }
        },
      );
    }
  }
}
