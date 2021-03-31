import 'dart:async' as async;
import 'dart:ui' as ui;
import 'dart:math';

import 'package:flame/components.dart';
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
  StraightRoad staightRoad;
  CMV cmv;
  CSI csi;
  TME tme;
  POLICE police;
  List<String> launchExercise = ["csi", "cmv", "repos", "tme"];
  SpriteComponent car;
  bool redFilter;
  bool start;
  bool gameOver = false;
  bool endOfGame = false;
  bool isConnected = false;
  bool isInit;
  bool doingBreak;

  bool hasSetXFuel;
  bool fuelIsDown;
  bool isDoingExercice;
  bool isWaiting = false;
  bool changeSize;

  //Count CMV/CSI/TME/Wait
  int totalCounterActivity;
  int CMVCounter;
  int CSICounter;
  int TMECounter;
  int waitCounter;
  int CMVLimit = 5;
  int CSILimit = 5;
  int TMELimit = 2;
  int waitLimit = 12;
  int randomNumber;
  int index;
  List<int> randomActivity = [];

  int previousActivity = 0;

  int score = 0;
  int life = 0;
  int starLevel = 0;
  double starValue = 0.0;
  bool pauseGame = false;
  bool hasCrash = false;
  bool hasCrashSecondWay = false;
  bool reset = false;
  double creationTimer = 0.0;
  double tempPos;
  double posY = 0;
  double posX = 0;
  int i = 0;
  double difficulte = 3.0;
  double secondWayDifficulty = 0.0;
  double thirdWayDifficulty = 0.0;

  double sizeW;
  double sizeH;
  List<Sprite> tempCMV = [];
  List<Sprite> tempCSI = [];
  List<Sprite> tempTME = [];

  double Function() getData;
  User user;
  double posYBottomLine;
  double posYTopLine;
  bool posMax;
  bool posMid;
  bool posMin;
  UI gameUI;
  AppLanguage appLanguage;

  async.Timer timerPause;

  CarGame(this.getData, User _user, AppLanguage _appLanguage) {
    user = _user;
    appLanguage = _appLanguage;
  }

  @override
  Future<void> onLoad() {
    initialize();
    // TODO: implement onLoad
    return super.onLoad();
  }

  void initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    screenSize = size.toSize();

    staightRoad = StraightRoad(this);
    //csi = CSI(this);
    //tme = TME(this);
    //police = POLICE(this);
    gameUI = UI();

    //140 / 70
    sizeW = screenSize.width * 0.22;
    sizeH = sizeW * 0.5;

    hasCrash = false;
    hasCrashSecondWay = false;

    life = 3;
    pauseGame = false;
    isInit = false;
    posMax = false;
    posMid = false;
    posMin = true;
    gameOver = false;
    endOfGame = false;
    isConnected = true;
    start = false;
    redFilter = false;
    changeSize = false;

    tempPos = 0;

    hasSetXFuel = false;
    doingBreak = false;
    fuelIsDown = true;
    isDoingExercice = false;
    isWaiting = false;
    totalCounterActivity = 0;
    CMVCounter = 0;
    CSICounter = 0;
    TMECounter = 0;
    waitCounter = 0;
    randomNumber = 0;
    //3: wait
    previousActivity = 3;

    //TODO change/implement for athletic mode
    secondWayDifficulty = double.parse(user.userInitialPush) * 0.5;
    thirdWayDifficulty = double.parse(user.userInitialPush) * 1.0;

    //Generate a "random" series of number that correspond to exercizes
    for (int i = 0; i < CMVLimit + CSILimit + TMELimit + waitLimit; i++) {
      Random random = new Random();
      randomNumber = random.nextInt(3); // from 0 upto 2 included

      if (randomNumber != previousActivity) {
        //Add wait between activities
        if (randomActivity.length == 0) randomActivity.add(3);

        if (randomActivity[randomActivity.length - 1] != 3)
          randomActivity.add(3);

        if (CMVLimit > CMVCounter && randomNumber == 0) {
          randomActivity.add(randomNumber);
          CMVCounter++;
        }
        if (CSILimit > CSICounter && randomNumber == 1) {
          randomActivity.add(randomNumber);
          CSICounter++;
        }
        if (TMELimit > TMECounter && randomNumber == 2) {
          randomActivity.add(randomNumber);
          TMECounter++;
        }
        previousActivity = randomNumber;
      } else
        i--;
    }
    //reset counter
    CMVCounter = 0;
    CSICounter = 0;
    TMECounter = 0;
    waitCounter = 0;

    print(randomActivity);
    index = 0;


    tempCMV = await _loadTruckCarSprites();
    tempTME = await _loadTruckSprites();
    tempCSI = await _loadFuelSprites();

    posYBottomLine = staightRoad.getYBottomPosition();
    staightRoad.setCarSize(sizeH);
  }

  Future<ui.Image> _loadImage(String image) async {
    ui.Image temp;

    temp = await Flame.images.load(image);
    return temp;
  }

  Future<List<Sprite>> _loadTruckCarSprites() async {
    List<Sprite> tempo = [];
    String sprite = "";
    for (int l = 0; l < numberCars; l++) {
      if (l == 0)
        sprite = spriteRedTruck;
      else if (l == 1)
        sprite = spriteBrownCar;
      else
        sprite = spriteRedCar;
      tempo.add(new Sprite(await Flame.images.load(sprite)));
    }
    return tempo;
  }

  Future<List<Sprite>> _loadFuelSprites() async {
    List<Sprite> tempo = [];
    for (int l = 0; l < numberFuel; l++) {
      tempo.add(new Sprite(await Flame.images.load(spriteFuel)));
    }
    return tempo;
  }

  Future<List<Sprite>> _loadTruckSprites() async {
    List<Sprite> tempo = [];
    for (int l = 0; l < numberTruck; l++) {
      tempo.add(new Sprite(await Flame.images.load(spriteRedTruck)));
    }
    return tempo;
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
            staightRoad.render(
                canvas, pauseGame, reset, hasCrash, hasCrashSecondWay);
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
          //car
          if (car != null) {
            car.render(canvas);

            //game.screenSize.height * (1 - balloonPosition);
            posY = screenSize.height - car.y - car.height / 2;
            //print("PosY car: $posY");

            posX = screenSize.width / 2.5 - car.width / 2;
/*
            print(j * speedCars -
                screenSize.width / 2 +
                cmv.getWidth() * speedCars);
            print(2 * (cmv.getXPosition(2) + cmv.getWidth() * 0.5) +
                cmv.getWidth() / 2);*/

            //HitBox CMV : trucks and cars
            if (cmv != null) {
              //First way
              if (posY + car.height * 0.5 <
                  screenSize.height * 0.7 - cmv.getHeight()) {
                //Hitbox trucks
                if (j * speedTruck -
                            screenSize.width / 2 +
                            cmv.getWidth() * 0.6 >
                        cmv.getXPosition(0) &&
                    j * speedTruck - screenSize.width / 2 <
                        cmv.getXPosition(cmv.truckList.length - 1) +
                            cmv.getWidth() * 0.62) {
                  //Empêche d'enlever 2 vies
                  if (!hasCrash) life--;
                  hasCrash = true;
                  //print("crashed");
                  //TODO stop timer game
                  async.Timer(Duration(seconds: 2), () {
                    hasCrash = false;
                  });
                }
                //Reset trucks spawn
                else if (j * speedTruck -
                        screenSize.width / 2 -
                        screenSize.width >
                    cmv.getXPosition(cmv.truckList.length - 1) +
                        cmv.getWidth() * 0.9) {
                  cmv = null;
                  isDoingExercice = false;
                }
              }
              //else if (posMid) {
              else if (tempPos <= screenSize.height * 0.4 &&
                  tempPos >= screenSize.height * 0.2) {
                //Hitbox Car
                if (j * speedTruck -
                            screenSize.width / 2 +
                            cmv.getWidth() * 0.6 >
                        cmv.getXPosition(1) &&
                    j * speedTruck - screenSize.width / 2 <
                        cmv.getXPosition(cmv.truckList.length - 1) +
                            cmv.getWidth() * 0.62) {
                  if (!hasCrashSecondWay) life--;
                  hasCrashSecondWay = true;
                  //TODO stop timer game
                  async.Timer(Duration(seconds: 2), () {
                    hasCrashSecondWay = false;
                  });
                }
                //Reset trucks spawn
                else if (j * speedTruck -
                        screenSize.width / 2 -
                        screenSize.width >
                    cmv.getXPosition(cmv.truckList.length - 1) +
                        cmv.getWidth() * 0.9) {
                  cmv = null;
                  isDoingExercice = false;
                }
              } else if (j * speedTruck -
                      screenSize.width / 2 -
                      screenSize.width >
                  cmv.getXPosition(cmv.truckList.length - 1) +
                      cmv.getWidth() * 0.9) {
                cmv = null;
                isDoingExercice = false;
              }
            }

            //HitBox CSI : Fuels
            if (csi != null) {
              //Hitbox fuel
              for (int i = 0; i < csi.fuelList.length; i++) {
                if (j - screenSize.width / 2 >
                        csi.getXPosition(i) - 2 * csi.getWidth() &&
                    j - screenSize.width / 2 < csi.getXPosition(i)) {
                  //bottom Fuel
                  if (posMid &&
                      csi.getYPosition(i) >
                          screenSize.height * 0.1 /*&& fuelIsDown*/) {
                    if (!hasSetXFuel) {
                      csi.removeFuel(i);
                      hasSetXFuel = true;
                      //Avoid multiple adding score
                      async.Timer(Duration(milliseconds: 600), () {
                        hasSetXFuel = false;
                        csi.hasHadScore = false;
                      });
                    }
                  }
                  //Top Fuel
                  else if (posMax &&
                      csi.getYPosition(i) <
                          screenSize.height * 0.4 /*&& !fuelIsDown*/) {
                    if (!hasSetXFuel) {
                      csi.removeFuel(i);
                      hasSetXFuel = true;
                      //Avoid multiple adding score
                      async.Timer(Duration(milliseconds: 600), () {
                        hasSetXFuel = false;
                        csi.hasHadScore = false;
                      });
                    }
                  }
                } else if (j - screenSize.width - csi.getWidth() >
                    csi.getXPosition(csi.fuelList.length - 1) -
                        2 * csi.getWidth()) {
                  csi = null;
                  isDoingExercice = false;
                }
              }
            }

            //HitBox TME : Trucks
            if (tme != null) {
              if (posY + car.height * 0.5 <
                  screenSize.height - widthRoad * 0.7 - tme.getHeight()) {
                //Hitbox Camion
                if (j * speedTruck -
                            screenSize.width / 2 +
                            tme.getWidth() * 0.6 >
                        tme.getXPosition(0) &&
                    j * speedTruck - screenSize.width / 2 <
                        tme.getXPosition(tme.truckList.length - 1) +
                            tme.getWidth() * 0.9) {
                  if (!hasCrash) life--;
                  hasCrash = true;
                  //TODO stop timer game
                  async.Timer(Duration(seconds: 2), () {
                    hasCrash = false;
                  });
                }
                //Reset trucks spawn
                else if (j * speedTruck -
                        screenSize.width / 2 -
                        screenSize.width >
                    tme.getXPosition(tme.truckList.length - 1) +
                        tme.getWidth() * 0.9) {
                  tme = null;
                  isDoingExercice = false;
                }
              } else if (j * speedTruck -
                      screenSize.width / 2 -
                      screenSize.width >
                  tme.getXPosition(tme.truckList.length - 1) +
                      tme.getWidth() * 0.9) {
                tme = null;
                isDoingExercice = false;
              }
            }

            //Game Over conditions
            if (life < 1) {
              pauseGame = true;
              gameOver = true;
            }
          }
        }
      }
    }
  }

  void update(double t) async {
    creationTimer += t;

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

          //TODO km + fuels -> star

          car = SpriteComponent.fromImage(await _loadImage(spriteGreenCar),
              size: Vector2(sizeW, sizeH));

          //tempPos = 0.0;

          //print("posY: $posY");
          //print("tempPos: $tempPos");
          //print("car.y: ${car.y}");

          if (!isInit) {
            //Centrage de la voiture en ordonnées
            posY = screenSize.height * 0.7;
            car.y = posY;
            isInit = true;
          }

          //Centrage de l'avion en abscisses
          car.x = screenSize.width / 2.5 - car.width / 2;
          //Définition des bords haut et bas de l'écran

          //Select activity
          if (!isDoingExercice) {
            //randomNumber = 1;

            //End of the game
            if (index > CMVLimit + CSILimit + TMELimit + waitLimit)
            {
              //score = 16;

              //TODO Update value
              //Family
              if (user.userMode == "0" && score > 15) {
                setStarValue(starValue = 0.5);
              }
              //Athletic
              else if (user.userMode == "1" && score > 30) {
                setStarValue(starValue = 0.5);
              } else {
                setStarValue(starValue = 0.0);
              }

              pauseGame = true;
              endOfGame = true;
            } else {
              switch (randomActivity[index]) {
                //CMV
                case 0:
                  if (CMVLimit > CMVCounter) {
                    isDoingExercice = true;
                    isWaiting = false;
                    cmv = new CMV(this, tempCMV);
                    totalCounterActivity++;
                    index++;
                    CMVCounter++;
                  }
                  break;
                //CSI
                case 1:
                  if (CSILimit > CSICounter) {
                    isDoingExercice = true;
                    isWaiting = false;
                    csi = new CSI(this, tempCSI);
                    totalCounterActivity++;
                    index++;
                    CSICounter++;
                  }
                  break;
                //TME
                case 2:
                  if (TMELimit > TMECounter) {
                    isDoingExercice = true;
                    isWaiting = false;
                    tme = new TME(this, tempTME);
                    totalCounterActivity++;
                    index++;
                    TMECounter++;
                  }
                  break;
                //Wait
                case 3:
                  isWaiting = true;
                  isDoingExercice = true;
                  startPause(true);
                  index++;
                  waitCounter++;
                  break;
                default:
                  break;
              }
            }
          }

          //Bas
          if (tempPos >= screenSize.height * 0.7) {
            car.y = tempPos;
            posMid = false;
            posMin = true;
            posMax = false;
          }
          //Milieu
          else if (getData() > secondWayDifficulty &&
              //!posMid &&
              tempPos <= screenSize.height * 0.4 &&
              tempPos >= screenSize.height * 0.38) {
            car.y = tempPos;
            posMid = true;
            posMin = false;
            posMax = false;

            //print("mid");
          }
          //Haut
          else if (getData() > thirdWayDifficulty &&
              tempPos <= screenSize.height * 0.1) {
            //tempPos = 0.0;
            car.y = tempPos;
            posMid = false;
            posMin = false;
            posMax = true;
            //print("max");
            //tempPos = -size / 2;
            //car.y = tempPos;
          }
          //Sinon on fait descendre la voiture
          else if (!posMid && !posMax) {
            car.y += tempPos;
            tempPos = car.y + difficulte * 3.0;
            if (pauseGame) tempPos = car.y;
          } else {
            if (car.y == 0.0) {
              car.y = tempPos;
            }
            posMid = false;
            posMin = false;
            posMax = false;
          }
        }

        if (!pauseGame) {
          //getData = données reçues par le Bluetooth
          //Montée de la voiture dans la 3 eme voie
          if (getData() > thirdWayDifficulty && !posMax && car != null) {
            //tempPos >= screenSize.height / 2 - sizeH / 2) {
            //print(car.y);
            car.y -= difficulte;
            tempPos = car.y;
            inTouch = false;
          }
          //Montée de la voiture 2nd voie
          else if (getData() > secondWayDifficulty &&
              car != null &&
              !posMid &&
              tempPos >= screenSize.height / 2 - sizeH / 2) {
            car.y -= difficulte;
            tempPos = car.y;
            inTouch = false;
          }

          if (inTouch) {
            //print(car.y);
            //car.y -= 20.0;
            tempPos = car.y;
            inTouch = false;
          }
        }
      }
    }
    //super.update(t);
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
      timerPause = new async.Timer.periodic(
        time,
        (async.Timer timer) {
          if (_start < 1) {
            timerPause.cancel();
            isWaiting = false;
            doingBreak = false;
            isDoingExercice = false;
          } else if (pauseGame)
            ;
          else {
            _start = _start - 1;
          }
        },
      );
    }
  }
}
