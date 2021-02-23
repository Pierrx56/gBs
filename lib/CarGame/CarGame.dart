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
  CMV cmv;
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
  bool isWaiting;
  bool changeSize;

  //Count CMV/CSI/TME/Wait
  int CMVCounter;
  int CSICounter;
  int TMECounter;
  int waitCounter;
  int CMVLimit = 5;
  int CSILimit = 5;
  int TMELimit = 2;
  int waitLimit = 12;
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
    changeSize = false;

    hasSetXFuel = false;
    doingBreak = false;
    fuelIsDown = true;
    isDoingExercice = false;
    isWaiting = false;
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

          //Select randomly activity
          if (!isDoingExercice) {
            Random random = new Random();
            randomNumber = random.nextInt(4); // from 0 upto 3 included
            if (previousActivity != randomNumber || !isWaiting) {
              if (!isWaiting) {
                isWaiting = true;
                randomNumber = 3;
              }
              randomNumber = 0;
              switch (randomNumber) {
                //CMV
                case 0:
                  if (CMVLimit > CMVCounter) {
                    previousActivity = randomNumber;
                    isDoingExercice = true;
                    isWaiting = false;
                    cmv = new CMV(this);
                    CMVCounter++;
                  }
                  break;
                //CSI
                case 1:
                  if (CSILimit > CSICounter) {
                    previousActivity = randomNumber;
                    isDoingExercice = true;
                    isWaiting = false;
                    csi = CSI(this);
                    CSICounter++;
                  }
                  break;
                //TME
                case 2:
                  if (TMELimit > TMECounter) {
                    previousActivity = randomNumber;
                    isDoingExercice = true;
                    isWaiting = false;
                    tme = new TME(this);
                    TMECounter++;
                  }
                  break;
                //Wait
                case 3:
                  if (waitLimit > waitCounter) {
                    switchSize(game);
                    previousActivity = randomNumber;
                    isDoingExercice = true;
                    startPause(true);
                    waitCounter++;
                  }

                  break;
                default:
                  break;
              }
            }
          }

          //Doubler voitures sur CMV
          //rattarper bariles entre alternativement entre 2 et 3 pour CSI

          if (cmv != null) {
            cmv.render(canvas, pauseGame, reset);
          }

          if (csi != null) {
            csi.render(canvas, pauseGame, reset);
          }

          if (tme != null) {
            tme.render(canvas, pauseGame, reset);
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
/*
            print(j * speedCars -
                screenSize.width / 2 +
                cmv.getWidth() * speedCars);
            print(2 * (cmv.getXPosition(2) + cmv.getWidth() * 0.5) +
                cmv.getWidth() / 2);*/

            //HitBox CMV
            if (cmv != null) {
              //print(j * speedCars - screenSize.width *0.5 - plane.width * 0.4 );

              //369.6
              //print((cmv.getXPosition(2)));
              //484
              //print((cmv.getWidth()));
              //900 à battre

              print(cmv.getXPosition(0));

              //First truck hitbox
              if (j * speedCars - screenSize.width * 0.5 + plane.width * 0.4 >
                      cmv.getXPosition(0) &&
                  j * speedCars - screenSize.width * 0.5 - plane.width * 0.4 <
                      (cmv.getXPosition(cmv.carsList.length - 1) +
                          cmv.getWidth()) &&
                  posY + plane.height * 0.5 <
                      screenSize.height - widthRoad * 0.7 - cmv.getHeight()) {
                print("touched");
              }
              //Cars 2nd way
              /*else if (j * speedCars -
                          screenSize.width / 2 +
                          cmv.getWidth() * speedCars >
                      cmv.getXPosition(1) + cmv.getWidth() * 0.5 &&
                  j * speedCars -
                          screenSize.width / 2 +
                          cmv.getWidth() * speedCars <
                      2 * (cmv.getXPosition(2) + cmv.getWidth() * 0.5) +
                          cmv.getWidth() / 2 &&
                  posY + plane.height * 0.5 <
                      screenSize.height - widthRoad * 0.4 - cmv.getHeight()) {
                print("2nd touched");
              }*/
              //Reset CMV
              else if (j * speedCars -
                          screenSize.width * 0.5 +
                          plane.width * 0.4 >
                      cmv.getXPosition(0) &&
                  j * speedCars - screenSize.width * 0.5 - plane.width <
                      (cmv.getXPosition(cmv.carsList.length - 1) +
                          cmv.getWidth())) {
                print("out");
                cmv = null;
                isDoingExercice = false;
              }
            }

            //HitBox CSI
            if (csi != null) {
              //TODO a refaire pour voie 2 et 3

              //Hitbox fuel
              for (int i = 0; i < csi.fuelList.length - 1; i++) {
                /*  print(j - screenSize.width / 2);

                  print(csi.getXPosition(0) - 2 * csi.getWidth());

                  print(csi.getXPosition(0) - 1 * csi.getWidth());*/

                //bottom Fuel
                if (posMid && fuelIsDown) {
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
                else if (posMax && !fuelIsDown) {
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

            //HitBox TME
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
          if (tempPos >= screenSize.height * 0.7) {
            plane.y = tempPos;
          }
          //Milieu
          else if (getData() > double.parse(user.userInitialPush) * 0.5 &&
              !posMid &&
              tempPos <= screenSize.height * 0.4 &&
              tempPos >= screenSize.height * 0.35) {
            posMid = true;
            posMax = false;
            plane.y = tempPos;

            print("mid");
          }
          //Haut
          else if (getData() > double.parse(user.userInitialPush) * 1.5 &&
              tempPos <= screenSize.height * 0.1 &&
              tempPos >= screenSize.height * 0.05) {
            //tempPos = 0.0;
            plane.y = tempPos;
            posMid = false;
            posMax = true;
            print("max");
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
    double _start = 3.0;
    doingBreak = true;

    if (!boolean) {
      _start = 3.0;
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
          } else if (pauseGame)
            ;
          else
            _start = _start - 1;
        },
      );
    }
  }

  void switchSize(CarGame game) async {
    Timer.periodic(Duration(milliseconds: 750), (timer) {
      changeSize = !changeSize;
      if (game.previousActivity != 3) timer.cancel();
    });
  }
}
