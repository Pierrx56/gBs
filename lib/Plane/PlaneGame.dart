import 'dart:async';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Plane/Background.dart';
import 'package:gbsalternative/Plane/Ui.dart';
import 'package:gbsalternative/Plane/Balloons.dart';

class PlaneGame extends Game {
  Size screenSize;
  bool inTouch = false;
  Background background;
  BottomBalloon bottomBalloon;
  TopBalloon topBalloon;
  bool isDown = false;
  SpriteComponent plane;
  double tileSize;
  bool redFilter;
  bool start;
  bool gameOver;
  bool isConnected;

  int score = 0;
  bool pauseGame = false;
  bool reset = false;
  String planePic;
  double creationTimer = 0.0;
  double scoreTimer = 0.0;
  double tempPos = 0;
  double posY = 0;
  double posX = 0;
  int i = 0;
  double difficulte = 3.0;

  double size = 130.0;
  List<String> tab = ['plane/plane1.png', 'plane/plane2.png'];

  double Function() getData;
  User user;
  int j = 0;
  double posYBottomLine;
  double posYTopLine;
  bool position;
  bool posMax;
  UI gameUI;

  PlaneGame(this.getData, User _user) {
    user = _user;
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    background = Background(this);
    bottomBalloon = BottomBalloon(this);
    topBalloon = TopBalloon(this);
    gameUI = UI();

    position = false;
    posMax = false;
    gameOver = false;
    isConnected = true;
    start = false;
    redFilter = false;
    posYBottomLine = bottomBalloon.getYBottomPosition();
    posYTopLine = topBalloon.getYTopPosition();
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
      if (background != null) background.render(canvas, pauseGame);

      canvas.save();

      if (!gameOver) {
        if (isConnected) {
          //Ballon du bas
          if (isDown) {
            if (bottomBalloon != null) {
              //bottomBalloon = BottomBalloon(this);
              bottomBalloon.render(canvas, pauseGame, reset);
            }
          }
          //Ballon du haut
          else if (!isDown) {
            if (topBalloon != null) {
              //topBalloon = TopBalloon(this);
              topBalloon.render(canvas, pauseGame, reset);
            }
          }
          reset = false;
          //Nageur
          if (plane != null) {
            plane.render(canvas);

            //game.screenSize.height * (1 - balloonPosition);
            posY = screenSize.height - plane.y - plane.height / 2;
            //print("PosY Plane: $posY");

            posX = screenSize.width / 2 - plane.width / 2;
            //print("Position joueur: " + tempPos.toString());

            //print("PosY Plane: ${bottomBalloon.getHeightBottomPosition()}");
            //Conditions si le ballon dépasse la moitié de l'avion, on respawn un ballon

            if (bottomBalloon.getXBottomPosition() == screenSize.width / 2) {
              //bottomBalloon = BottomBalloon(this);
            } else if (topBalloon.getXTopPosition() ==
                screenSize.width / 2) {
              //topBalloon = TopBalloon(this);
            }

            //HitBox ballon bas
            if (posY <= bottomBalloon.getYBottomPosition() &&
                posX ==
                    (bottomBalloon.getXBottomPosition() -
                        plane.width / 2) &&
                isDown) {
              score++;
              position = isDown;
              reset = true;
              isDown = !isDown;
              bottomBalloon = BottomBalloon(this);
              //Rentre une fois dans la timer
              if (!start) {
                startTimer(start = true);
              }
            }
            //HitBox ballon haut
            else if (posY >=
                    (topBalloon.getYTopPosition() - plane.height / 2) &&
                posX == (topBalloon.getXTopPosition() - plane.width / 2) &&
                !isDown) {
              score++;
              position = isDown;
              reset = true;
              isDown = !isDown;
              topBalloon = TopBalloon(this);
              if (!start) {
                startTimer(start = true);
              }
            } else {
              setColorFilter(false);
              startTimer(start = false);
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
          if (i == tab.length - 1)
            i = 0;
          else
            i++;

          if (pauseGame) i = 0;

          planePic = tab[i];

          creationTimer = 0.0;

          Sprite sprite = Sprite(planePic);

          plane = SpriteComponent.fromSprite(
              size, size, sprite); // width, height, sprite

          plane.x = screenSize.width / 2 - plane.width / 2;
          //Définition des bords haut et bas de l'écran

          //Bas
          if (tempPos >= screenSize.height - size) {
            plane.y = tempPos;
          }
          //Haut
          else if (tempPos <= 0.0 &&
              getData() > double.parse(user.userInitialPush)) {
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
          } else
            posMax = false;

          //component = new Component(dimensions);
          //add(component);
        }

        if (!pauseGame) {
          //getData = données reçues par le Bluetooth

          //Montée de l'avion
          if (getData() > double.parse(user.userInitialPush) && !posMax) {
            //print(plane.y);
            plane.y -= difficulte;
            tempPos = plane.y;
            inTouch = false;
          }

          if (inTouch) {
            print(plane.y);
            plane.y -= 20.0;
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

  void setColorFilter(bool boolean) {
    redFilter = boolean;
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

  bool getPosition() {
    //True: position haut
    //False: position basse
    return position;
  }

  void startTimer(bool boolean) async {
    Timer _timer;
    double _start = 5.0;

    if (!boolean) {
      _start = 5.0;
      start = false;
    } else {
      const time = const Duration(milliseconds: 500);
      _timer = new Timer.periodic(
        time,
        (Timer timer) {
          // S'il ressort de la zone avant le timer, on reset le timer
          if (!start) {
            timer.cancel();
            return;
          }
          if (_start < 0.5) {
            //TODO Display menu ?
            setColorFilter(true);
            timer.cancel();
            gameOver = true;
          } else {
            setColorFilter(!redFilter);
            _start = _start - 0.5;
            print(_start);
          }
        },
      );
    }
  }
}
