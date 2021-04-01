import 'dart:async' as async;
import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Plane/Background.dart';
import 'package:gbsalternative/Plane/Plane.dart';
import 'package:flame/components.dart';
import 'package:gbsalternative/Plane/Ui.dart';
import 'package:gbsalternative/Plane/Balloons.dart';

class PlaneGame extends Game with TapDetector {
  Size screenSize;
  bool inTouch = false;
  Background background;
  BottomBalloon bottomBalloon;
  TopBalloon topBalloon;
  bool isDown = false;
  SpriteComponent plane;
  bool redFilter;
  bool start;
  bool gameOver = false;
  bool isConnected = true;
  List<ui.Image> image = [];

  int score = 0;
  int starLevel = 0;
  double starValue = 0.0;
  bool pauseGame = false;
  bool resetBottom = false;
  bool resetTop = false;
  bool hasMissedBaloon = false;
  String planePic;
  double creationTimer = 0.0;
  double scoreTimer = 0.0;
  double tempPos = 0;
  double posY = 0;
  double posX = 0;
  int i = 0;
  double difficulte = 3.0;

  double sizeSprite = 130.0;
  List<String> tab = ['plane/plane1.png', 'plane/plane2.png'];

  double Function() getData;
  double btData;
  async.Timer timerData;

  User user;
  int j = 0;
  double posYBottomLine;
  double posYTopLine;
  bool position;
  bool posMax;
  UI gameUI;
  AppLanguage appLanguage;

  BluetoothManager bluetoothManager;

  PlaneGame(this.getData, User _user, AppLanguage _appLanguage) {
    user = _user;
    appLanguage = _appLanguage;
  }

  @override
  Future<void> onLoad() {
    initialize();
    // TODO: implement onLoad
    return super.onLoad();
  }

  Future<List<ui.Image>> _loadImage() async {
    List<ui.Image> temp = [];

    for (int i = 0; i < tab.length; i++) {
      temp.add(await Flame.images.load(tab[i]));
    }

    return temp;
  }

  void initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    //resize(await initialDimensions());
    //onResize(Vector2(screenSize.width, screenSize.height));

    screenSize = size.toSize();
    image = await _loadImage();
    btData = getData();
    bluetoothManager =
        BluetoothManager(appLanguage: null, inputMessage: null, user: null);

    setData();
    background = Background(this);
    bottomBalloon = BottomBalloon(this);
    topBalloon = TopBalloon(this);
    gameUI = UI();

    resetBottom = false;
    resetTop = false;
    hasMissedBaloon = false;
    position = false;
    posMax = false;
    gameOver = false;
    isConnected = true;
    start = false;
    redFilter = false;
    posYBottomLine = bottomBalloon.getYBottomPosition();
    posYTopLine = topBalloon.getYTopPosition();
  }

  void setData() {
    timerData =
        async.Timer.periodic(Duration(milliseconds: 120), (timer) async {
      btData = getData();
      /*
      bool _isConnected = await bluetoothManager.getData("C");
      if (!_isConnected) {
        print("isConnected: $_isConnected");
        async.Timer(Duration(milliseconds: 500), () async {
          String temp = await bluetoothManager.getData("C");
          print("temp: $temp");
          if (temp != "true") {
            timerData.cancel();
            isConnected = false;
          }
        });
      }*/
    });
  }

  void render(Canvas canvas) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    canvas.drawRect(bgRect, bgPaint);

    if (canvas != null) {
      //Background
      if (background != null) background.render(canvas, pauseGame);

      canvas.save();

      if (!gameOver) {
        if (isConnected) {
          //Ballon du bas
          if (isDown) {
            if (bottomBalloon != null) {
              //bottomBalloon = BottomBalloon(this);
              bottomBalloon.render(canvas, pauseGame, resetBottom);
            }
            if(hasMissedBaloon) {
              canvas.save();
              if (topBalloon != null) {
                //topBalloon = TopBalloon(this);
                topBalloon.render(canvas, pauseGame, resetTop);
              }
            }
          }
          //Ballon du haut
          else if (!isDown) {
            if (topBalloon != null) {
              //topBalloon = TopBalloon(this);
              topBalloon.render(canvas, pauseGame, resetTop);
            }
          }
          resetBottom = false;
          resetTop = false;
          //Nageur
          if (plane != null) {
            plane.render(canvas);

            //game.screenSize.height * (1 - balloonPosition);
            posY = screenSize.height - plane.y - plane.height / 2;
            //print("PosY Plane: $posY");

            posX = screenSize.width / 2.5 - plane.width / 2;
            //print("Position joueur: " + tempPos.toString());

            //print("PosY Plane: ${bottomBalloon.getHeightBottomPosition()}");
            //TODO ? Conditions si le ballon dépasse la moitié de l'avion, on respawn un ballon

            if (bottomBalloon.getXBottomPosition() == screenSize.width / 2) {
              //bottomBalloon = BottomBalloon(this);
            } else if (topBalloon.getXTopPosition() == screenSize.width / 2) {
              //topBalloon = TopBalloon(this);
            }

            //HitBox ballon bas
            if (posY <= bottomBalloon.getYBottomPosition() &&
                (posX <=
                        ((bottomBalloon.getXBottomPosition() -
                                plane.width / 2) +
                            3) &&
                    posX >=
                        ((bottomBalloon.getXBottomPosition() -
                                plane.width / 2) -
                            3)) &&
                isDown) {
              score++;
              position = isDown;
              resetBottom = true;
              //resetTop = true;
              hasMissedBaloon = false;
              if (!hasMissedBaloon) {
                bottomBalloon = BottomBalloon(this);
                isDown = !isDown;
              }
              //Rentre une fois dans la timer
            }
            //HitBox ballon haut
            else if (posY >=
                    (topBalloon.getYTopPosition() - plane.height / 2) &&
                (posX >=
                        ((topBalloon.getXTopPosition() - plane.width / 2) -
                            3) &&
                    posX <=
                        ((topBalloon.getXTopPosition() - plane.width / 2) +
                            3)) &&
                !isDown) {
              score++;
              position = isDown;
              resetTop = true;
              hasMissedBaloon = false;
              if (!hasMissedBaloon) {
                topBalloon = TopBalloon(this);
                isDown = !isDown;
              }
              //sDown = !isDown;
            } else if (posX >=
                    ((topBalloon.getXTopPosition() - plane.width / 2) - 3) &&
                posX <=
                    ((topBalloon.getXTopPosition() - plane.width / 2) + 3) &&
                !isDown) {
              print("ici");
              position = isDown;
              //resetBottom = true;
              hasMissedBaloon = true;
              isDown = true;
              //bottomBalloon = BottomBalloon(this);
            } else {
              setColorFilter(false);
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
      /*if (btData != -1.0) {
        isConnected = true;
      }
      else{
        isConnected = false;
      }*/

      if (isConnected) {
        //Timer
        if (creationTimer >= 0.04) {
          if (i == tab.length - 1)
            i = 0;
          else
            i++;

          if (pauseGame) i = 0;

          planePic = tab[i];

          creationTimer = 0.0;

          plane = SpriteComponent.fromImage(image[i],
              size: Vector2(screenSize.width * 0.2,
                  screenSize.width * 0.2)); // width, height, sprite

          //Centrage de l'avion en abscisses
          plane.x = screenSize.width / 2.5 - plane.width / 2;
          //Définition des bords haut et bas de l'écran

          //Bas
          if (tempPos >= screenSize.height - sizeSprite) {
            plane.y = tempPos;
          }
          //Haut
          else if (tempPos <= 0.0 &&
              btData > double.parse(user.userInitialPush)) {
            tempPos = 0.0;
            plane.y = tempPos;
            posMax = true;
            //tempPos = -size / 2;
            //plane.y = tempPos;
          }
          //Sinon on fait descendre l'avion
          else if (!posMax) {
            plane.y += tempPos;
            tempPos = plane.y + difficulte * 3.0;
            if (pauseGame) tempPos = plane.y;
          } else {
            if (plane.y == 0.0) {
              plane.y = tempPos;
            }
            posMax = false;
          }
          //component = new Component(dimensions);
          //add(component);
        }

        if (!pauseGame) {
          //getData = données reçues par le Bluetooth

          //Montée de l'avion
          if (btData > double.parse(user.userInitialPush) &&
              !posMax &&
              plane != null) {
            //print(plane.y);
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

  void setBalloonSpeed(int speed) {
    balloonSpeed = speed;
  }

  bool getGameOver() {
    return gameOver;
  }

  bool getConnectionState() {
    return isConnected;
  }

  bool getPosition() {
    //True: position haut
    //False: position basse
    return position;
  }

  void onTapDown(TapDownDetails d) {
    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;

    if (d.globalPosition.dx >= screenCenterX - screenSize.width &&
        d.globalPosition.dx <= screenCenterX + screenSize.width &&
        d.globalPosition.dy >= screenCenterY - screenSize.height &&
        d.globalPosition.dy <= screenCenterY + screenSize.height) {
      inTouch = true;

      //inTouch = true;
    }
  }
}
