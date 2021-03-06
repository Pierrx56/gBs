import 'dart:async' as async;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Swimmer/Background.dart';
import 'package:gbsalternative/Swimmer/Ui.dart';
import 'package:gbsalternative/Swimmer/WaterLines.dart';

//TODO voir pour rapprocher la ligne rouge, plus reapide, sinon pluis lent

class SwimGame extends Game {
  Size screenSize;
  bool inTouch = false;
  Background background;
  BottomLine bottomLine;
  TopLine topLine;
  SpriteComponent swimmer;
  double tileSize;
  bool redFilter = false;
  bool start;
  bool gameOver = false;
  bool empty = false;
  bool isConnected = false;
  bool isInit = false;
  int counterHigh;
  bool isTooHigh = false;

  int score = 0;
  int life = 3;
  int starLevel = 0;
  double starValue = 0.0;
  bool pauseGame = false;
  bool posMax;
  String swimmerPic;
  double creationTimer = 0.0;
  double scoreTimer = 0.0;
  double tempPos = 0;
  double pos = 0;
  int i = 0;
  double difficulte = 0.50;
  double speed = 100; // Pixels per second

  double sizeXSprite = 100.0;
  double sizeYSprite = 230.0;

  List<String> tab = [
    'ship/ship_and_water_0.png',
    'ship/ship_and_water_1.png',
    'ship/ship_and_water_2.png',
    'ship/ship_and_water_3.png',
    'ship/ship_and_water_4.png',
  ];

  String emptyShip = "ship/empty_ship.png";

  /*
  List<String> tab = [
    'swimmer/swim0.png',
    'swimmer/swim1.png',
    'swimmer/swim2.png',
    'swimmer/swim3.png',
    'swimmer/swim4.png',
    'swimmer/swim5.png',
    'swimmer/swim6.png',
    'swimmer/swim7.png',
    'swimmer/swim8.png',
    'swimmer/swim9.png',
    'swimmer/swim10.png',
    'swimmer/swim11.png',
    'swimmer/swim12.png',
    'swimmer/swim13.png',
    'swimmer/swim14.png',
    'swimmer/swim15.png',
    'swimmer/swim16.png',
    'swimmer/swim17.png',
    'swimmer/swim18.png',
    'swimmer/swim19.png',
    'swimmer/swim20.png',
    'swimmer/swim21.png',
    'swimmer/swim22.png',
    'swimmer/swim23.png'
  ];*/

  double Function() getData;
  User user;
  double posBottomLine;
  double posTopLine;
  bool isBottomPosition;
  UI gameUI;
  AppLanguage appLanguage;
  async.Timer timerSwimmer;

  SwimGame(this.getData, User _user, AppLanguage _appLanguage) {
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
    background = Background(this);
    bottomLine = BottomLine(this);
    topLine = TopLine(this);
    gameUI = UI();

    //Swimmer's size
    sizeXSprite = screenSize.width * 0.4;
    sizeYSprite = screenSize.height * 0.4;

    isTooHigh = false;
    counterHigh = 0;
    life = 3;
    isBottomPosition = false;
    posMax = false;
    gameOver = false;
    isConnected = true;
    isInit = false;
    start = false;
    empty = false;
    redFilter = false;
    posBottomLine = bottomLine.getDownPosition();
    posTopLine = bottomLine.getDownPosition();
  }

  Future<ui.Image> _loadImage(String image) async {
    ui.Image temp;

    temp = await Flame.images.load(image);
    return temp;
  }

  void render(Canvas canvas) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    canvas.drawRect(bgRect, bgPaint);

    //String btData = _onDataReceiver();

    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;

    /*
    if (hasWon) {
      boxPaint.color = Color(0xff00ff00);
      hasWon = false;

    } else {
      boxPaint.color = Color(0xffffffff);
    }*/

    if (canvas != null) {
      //Background
      if (background != null) background.render(canvas);

      canvas.save();

      if (!gameOver) {
        if (isConnected) {
          //Ligne basse
          if (bottomLine != null) bottomLine.render(canvas, pauseGame);

          //Ligne haute
          if (topLine != null) topLine.render(canvas);

          //Nageur
          if (swimmer != null) {
            swimmer.render(canvas);

            pos = swimmer.y + swimmer.height / 2;

            //print("Position joueur: " + tempPos.toString());
          }

          //Conditions de défaite
          if (pos < bottomLine.getDownPosition()) {
            //print("Attention au bord bas !");
            //setColorFilter(true);
            isBottomPosition = true;
            //Rentre une fois dans le timer
            if (!start) {
              counterHigh++;
              //Si le joueur pousse trop fort 5 fois dans le jeu, on demande à ce qu'il réajuste la toise
              if (counterHigh > 5) {
                isTooHigh = true;
                pauseGame = true;
              } else {
                isTooHigh = false;
                pauseGame = false;
              }

              startTimer(start = true, 10.0);
            }
          } else if (pos > topLine.getUpPosition()) {
            //print("Attention au bord haut !");
            //setColorFilter(true);
            isBottomPosition = false;
            if (!start) {
              startTimer(start = true, 6.0);
            }
          } else {
            setColorFilter(false);
            startTimer(start = false, 0.0);
          }
        }
      }
    }
  }

  void update(double t) async {
    creationTimer += t;
    scoreTimer += t;

    if(!pauseGame && j != null){
      j += (speed * creationTimer).toInt();
    }

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
          else if (pauseGame)
            ;
          else
            i++;

          //if (pauseGame) i--;

          if(start && empty)
            swimmerPic = emptyShip;
          else
            swimmerPic = tab[i];

          creationTimer = 0.0;

          swimmer = SpriteComponent.fromImage(await _loadImage(swimmerPic),
              size: Vector2(sizeXSprite, sizeYSprite));

          if (!isInit) {
            swimmer.y = screenSize.height * 0.3;
            isInit = true;
          }

          //Centrage du nageur en abscisses
          swimmer.x = screenSize.width / 2 - swimmer.width / 2;

          //Définition des bords haut et bas de l'écran

          //Bas
          //if (tempPos >= screenSize.height - (sizeYSprite / 2)) {
          if (tempPos >= screenSize.height - bottomLine.getDownPosition() - (sizeYSprite / 2)) {
            swimmer.y = tempPos;
          }
          //Haut
          //else if (tempPos <= -(sizeYSprite / 2) &&
          else if (tempPos <= topLine.sizeWater.y*0.5 &&
              getData() > double.parse(user.userInitialPush)) {
            //tempPos = -(sizeYSprite / 2);
            tempPos = topLine.sizeWater.y*0.5;
            swimmer.y = tempPos;
            posMax = true;
          }
          //Sinon on fait descendre le nageur
          else if (!posMax) {
            swimmer.y += tempPos;
            tempPos = swimmer.y + difficulte * 4.0;
            if (pauseGame) tempPos = swimmer.y;
          } else {
            if (swimmer.y == 0.0) {
              swimmer.y = tempPos;
            }
            posMax = false;
          }
          //component = new Component(dimensions);
          //add(component);
        }

        //On incrémente le score tous les x secondes
        if (!pauseGame) {
          if (scoreTimer >= 0.5) {
            score++;
            scoreTimer = 0.0;
          }

          //getData = données reçues par le Bluetooth
          //Montée du nageur
          if (getData() > double.parse(user.userInitialPush) &&
              !posMax &&
              swimmer != null) {
            //print(swimmer.y);
            swimmer.y -= difficulte;
            tempPos = swimmer.y;
            inTouch = false;
          }

          //print("tempPos: $tempPos \nSwimmer.y: ${swimmer.y}\n");

          //Pression sur l'écran avec le doigt
/*          if (inTouch) {
            print(swimmer.y);
            swimmer.y -= 20.0;
            tempPos = swimmer.y;
            inTouch = false;
          }*/
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

  ColorFilter getColorFilter() {
    if (redFilter) {
      return ColorFilter.mode(Colors.transparent, BlendMode.luminosity);
      //return ColorFilter.mode(Colors.redAccent, BlendMode.hue);
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
    return isBottomPosition;
  }

  bool getPauseStatus() {
    return pauseGame;
  }

  void startTimer(bool isStarted, double _start) async {
    int temp = 0;
    if (!isStarted && isConnected) {
      //_start = 5.0;
      temp = 0;
      start = false;
    } else {
      const time = const Duration(milliseconds: 500);
      timerSwimmer = async.Timer.periodic(
        time,
        (async.Timer _timer) {
          // S'il ressort de la zone avant le timer, on reset le timer
          if (!start) {
            temp = 0;
            timerSwimmer.cancel();
            return;
          }
          if (isConnected) {
            if (_start < 0.5 || life == 0) {
              //TODO Display menu ?
              setColorFilter(true);
              timerSwimmer.cancel();
              gameOver = true;
            } else if (!pauseGame) {
              setColorFilter(!redFilter);
              _start = _start - 0.5;
              empty = !empty;
              temp++;
              //Every 2 seconds, -1 life
              if(temp == 4){
                life--;
                temp = 0;
              }
              print(_start);
            }
          } else {
            temp = 0;
            setColorFilter(false);
            timerSwimmer.cancel();
          }
        },
      );
    }
  }
}
