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
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/ManageProfile.dart';
import 'package:gbsalternative/TempGame/Background.dart';
import 'package:gbsalternative/TempGame/Ui.dart';
import 'package:gbsalternative/TempGame/Floor.dart';
import 'package:flame/animation.dart'
    as animation; // imports the Animation class under animation.Animation
import 'package:flame/position.dart' as position; // imports the Position class

class TempGame extends Game {
  Size screenSize;
  bool inTouch = false;
  bool isPushable = false;
  bool hasJumped = false;
  Background background;
  ManageSign sign;

  double signPosition = 4.5;
  bool isDisplayingSign = false;

  //BottomFloor bottomFloor;
  //FirstFloor firstFloor;
  //FirstFloor firstFloor1;
  //FirstFloor firstFloor2;

  List<BottomFloor> tabBottomFloor = [];

  List<FirstFloor> tabFloor = [];

  ManageFloors manageFloors;

  SpriteComponent temp;
  double tileSize;
  bool redFilter;
  bool start;
  bool gameOver;
  bool endGame = false;
  bool isConnected;
  bool launchTuto = false;
  int counterHigh;
  bool isTooHigh;
  bool isInit;
  int phaseTuto = 1;

  //Red Player
  bool isWaiting = false;
  bool isRunning;
  bool isJumping;

  int floor = 0;
  int coins = 0;
  int jumpCounter = 0;
  int starLevel = 0;
  double starValue = 0.0;

  int life;
  double opacity = 1;
  int increment;
  bool pauseGame = false;
  bool isMoving = false;
  bool isPushing = false;
  bool posMax;
  bool gravity;
  String tempPic;
  int randomNumber;
  bool goodNumber;
  double creationTimer;
  double scoreTimer;
  double tempPosY;
  double tempPosX;
  double pos;
  int i;
  double difficulte = 0.50;

  double size;
  static List<String> jump = [
    'temp/jump1.png',
    'temp/jump2.png',
  ];

  static List<String> run = [
    'temp/run1.png',
    'temp/run2.png',
    'temp/run3.png',
    'temp/run4.png',
    'temp/run5.png',
    'temp/run6.png',
    'temp/run7.png',
    'temp/run8.png',
    'temp/run9.png',
    'temp/run10.png',
    'temp/run11.png',
    'temp/run12.png',
    'temp/run13.png',
    'temp/run14.png',
    'temp/run15.png',
    'temp/run16.png',
    'temp/run17.png',
    'temp/run18.png'
  ];

  static List<String> waiting = [
    'temp/tile000.png',
    'temp/tile001.png',
    'temp/tile002.png',
    'temp/tile003.png',
    'temp/tile004.png',
    'temp/tile005.png',
    'temp/tile006.png',
    'temp/tile007.png',
    'temp/tile008.png',
    'temp/tile009.png',
    'temp/tile010.png'
  ];

  List<List<String>> tab = [jump, run, waiting];

  double Function() getData;
  double Function() getPush;
  void Function() setFloor;
  int Function() getFloor;
  User user;
  int j = 1;
  double posBottomFloor;
  double posFirstFloor;
  bool isTopPosition;
  UI gameUI;
  AppLanguage appLanguage;
  animation.Animation a;
  List<double> floorPosition = [];
  Timer tempTimer;
  Timer timerPosition;
  bool isOutOfScreen;

  TempGame(this.getData, this.getPush, this.getFloor, this.setFloor, User _user,
      AppLanguage _appLanguage) {
    user = _user;
    appLanguage = _appLanguage;
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());

    //Initialisation des différents niveaux de sol
    floorPosition.add(screenSize.height + 3 * screenSize.width * 0.1);
    floorPosition.add(screenSize.height - 1 * screenSize.width * 0.1);
    floorPosition.add(screenSize.height - 2.5 * screenSize.width * 0.1);
    floorPosition.add(screenSize.height - 4 * screenSize.width * 0.1);

    tempTimer?.cancel();

    firstFloorY = floorPosition[1];
    background = Background(this);
    //bottomFloor = new BottomFloor(this);
    manageFloors = new ManageFloors(this);
    manageFloors.j = 0;
    tabBottomFloor.add(new BottomFloor(this));
    tabBottomFloor[0].setOpacityC0(0);
    tabBottomFloor[0].setOpacityC1(0);
    tabBottomFloor[0].setOpacityC2(0);

    firstFloorY = floorPosition[2];
    tabBottomFloor.add(new BottomFloor(this));
    tabBottomFloor[1].setGrassXOffset(grassSize / 2);
    tabBottomFloor[1].setOpacityC0(0);
    tabBottomFloor[1].setOpacityC1(0);
    tabBottomFloor[1].setOpacityC2(0);

    tabBottomFloor.add(new BottomFloor(this));
    tabBottomFloor[2].setGrassXOffset(grassSize);
    tabBottomFloor[2].setOpacityC0(0);
    tabBottomFloor[2].setOpacityC1(0);
    tabBottomFloor[2].setOpacityC2(0);

    firstFloorY = floorPosition[1];
    tabFloor.add(new FirstFloor(this));
    tabFloor[0].setOpacityC0(1);
    tabFloor[0].setOpacityC1(0);
    tabFloor[0].setOpacityC2(0);

    firstFloorY = floorPosition[2];
    tabFloor.add(new FirstFloor(this));
    tabFloor[1].setGrassXOffset(grassSize / 2);
    tabFloor[1].setOpacityC0(1);
    tabFloor[1].setOpacityC1(1);
    tabFloor[1].setOpacityC2(0);
    tabFloor[1].updateRect();

    firstFloorY = floorPosition[3];
    tabFloor.add(new FirstFloor(this));
    tabFloor[2].setGrassXOffset(grassSize);
    tabFloor[2].setOpacityC0(1);
    tabFloor[2].setOpacityC1(1);
    tabFloor[2].setOpacityC2(1);
    tabFloor[2].updateRect();

    sign = new ManageSign(this);
    gameUI = UI();

    life = 3;
    randomNumber = 0;
    increment = 0;
    size = 75.0;
    pos = 0;
    i = 0;
    tempPosY = 0.0;
    tempPosX = 0.0;
    scoreTimer = 0.0;
    creationTimer = 0.0;
    isTooHigh = false;
    counterHigh = 0;
    phaseTuto = 1;
    isTopPosition = false;
    goodNumber = false;
    posMax = false;
    gameOver = false;
    endGame = false;
    isConnected = true;
    isInit = false;
    start = false;
    redFilter = false;
    hasJumped = false;
    gravity = false;
    isOutOfScreen = false;

    isWaiting = false;
    isRunning = true;
    isJumping = false;
  }

  void render(Canvas canvas) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    canvas.drawRect(bgRect, bgPaint);

    if (canvas != null) {
      //Background
      if (background != null) background.render(canvas, pauseGame);

      if (!gameOver) {
        if (isConnected) {
          canvas.save();
          //Arrière plan
          if (manageFloors != null)
            manageFloors.render(canvas, pauseGame, isMoving);
          //Base
          if (tabBottomFloor != null) {
            tabBottomFloor[0].render(canvas, pauseGame, isMoving);
            tabBottomFloor[1].render(canvas, pauseGame, isMoving);
            tabBottomFloor[2].render(canvas, pauseGame, isMoving);
          }
          //Premier étage
          if (tabFloor != null) {
            tabFloor[0].render(canvas, pauseGame, isMoving);
            tabFloor[1].render(canvas, pauseGame, isMoving);
            tabFloor[2].render(canvas, pauseGame, isMoving);
          }

          canvas.restore();
          //Premier plan
          if (sign != null) sign.render(canvas, pauseGame, isMoving);
          //Bonhomme rouge
          if (temp != null) {
            temp.render(canvas);
            pos = temp.y + temp.height / 2;
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
        if (creationTimer >= 0.02) {
          if (i == tab[j].length - 1) {
            i = 0;
          } else if (pauseGame)
            ;
          else {
            i++;
          }

          if (isJumping) {
            tempPic = jump[i];
            j = 0;
          } else if (isRunning) {
            //On fige le joueur uniquement pour le tuto
            if (launchTuto && isPushable)
              ;
            else
              tempPic = run[i];
            j = 1;
          }
          //Gestion de l'animation d'attente
          //Génère un nombre aléatoire pour faire cligner les yeux
          //2% de chance de cligner des yeux
          else if (isWaiting && !pauseGame) {
            var rng = new Random();
            if (!goodNumber) randomNumber = rng.nextInt(100);
            if ((randomNumber >= 0 && randomNumber <= 98))
              tempPic = waiting[0];
            //waitAnimation(randomNumber);
            else {
              goodNumber = true;
              if (increment < waiting.length) {
                tempPic = waiting[increment];
                increment++;
              } else {
                increment = 0;
                goodNumber = false;
              }
            }
            j = 2;
          }

          creationTimer = 0.0;

          Sprite sprite = Sprite(tempPic);

          temp = SpriteComponent.fromSprite(
              size, size, sprite); // width, height, sprite
          temp.x = tempPosX;
          temp.y = tempPosY;

          if (!isInit) {
            //Centrage du bonhomme en abscisses
            temp.x = -10;

            tempPosX = temp.x;

            //Centrage du bonhomme en ordonnées
            tempPosY = screenSize.height - (size) - grassSize;

            isInit = true;
          }

          if (!pauseGame) {
            if (launchTuto && isPushable)
              ;
            else if (tempPosX < (screenSize.width - size) / 2) {
              tempPosX += 3;
              temp.x = tempPosX;
            }
            //Si le joueur atteint la moitié de l'écran, la "caméra" suit le joueur au centre de l'écran
            else {
              isMoving = true;
            }
          }
          //Définition des bords haut et bas de l'écran

          //Bas
          //Premier étage d'herbe
          if (tempPosY >= screenSize.height - (size) - grassSize) {
            temp.y = tempPosY;
          }
        }

        if (!pauseGame) {
          if (temp != null) {
            //Si c'est le premier lancement de l'activité, lancer le tuto
            // Initializing database
            DatabaseHelper db = new DatabaseHelper();
            List<Scores> dataTemp =
                await db.getScore(user.userId, ID_TEMP_ACTIVITY);

            if (dataTemp.isEmpty && phaseTuto < 4 ||
                dataTemp.isEmpty && phaseTuto == 5) {
              launchTuto = true;
            } else {
              launchTuto = false;
            }
            //Deuxième phase du tuto pour l'explication des etages
            if (manageFloors.j + temp.x + grassSize >=
                    tabBottomFloor[getCurrentFloor()].getGrassXOffset()[13] &&
                coins == 0 &&
                phaseTuto == 4) {
              phaseTuto++;
            }

            //Si le joueur a dépassé le drapeau, on autorise la jauge
            if (manageFloors.j + temp.x + grassSize >=
                    tabBottomFloor[getCurrentFloor()].getFlagPosition() &&
                manageFloors.j + temp.x + grassSize - 2 <=
                    tabBottomFloor[getCurrentFloor()].getFlagPosition()) {
              isPushable = true;
            } else if (manageFloors.j + temp.x + grassSize >=
                    tabFloor[getCurrentFloor()].getFlagPosition() &&
                manageFloors.j + temp.x + grassSize - 2 <=
                    tabFloor[getCurrentFloor()].getFlagPosition()) {
              isPushable = true;
            }
          }
          //If the player walks on coins, make coins disappear
          if (manageFloors.j + temp.x + grassSize >=
                  tabBottomFloor[getCurrentFloor()].getCoinsPosition() &&
              blockOne) {
            tabBottomFloor[getFloor() - 1].setOpacityC0(opacity -= 0.1);
            tabBottomFloor[getFloor() - 1].setOpacityC1(opacity -= 0.1);
            tabBottomFloor[getFloor() - 1].setOpacityC2(opacity -= 0.1);
          } else if (manageFloors.j + temp.x + grassSize >=
                  tabFloor[getCurrentFloor()].getCoinsPosition() &&
              !blockOne) {
            tabFloor[getFloor() - 1].setOpacityC0(opacity -= 0.1);
            tabFloor[getFloor() - 1].setOpacityC1(opacity -= 0.1);
            tabFloor[getFloor() - 1].setOpacityC2(opacity -= 0.1);
          }

          //Si il a poussé pendant 6 secondes et qu'il n'a pas déjà sauté
          if (isWaiting || isPushable) {
            //print("push: ${getPush()}");
            if (getPush() <= 0 &&
                    manageFloors.j + temp.x + grassSize >=
                        tabBottomFloor[getCurrentFloor()].getGrassXOffset()[
                                tabBottomFloor[getCurrentFloor()].getLength() -
                                    1] -
                            grassSize / 2 ||
                getPush() <= 0 &&
                    manageFloors.j + temp.x + grassSize >=
                        tabFloor[getCurrentFloor()].getGrassXOffset()[
                                tabFloor[getCurrentFloor()].getLength() - 1] -
                            grassSize / 2 ||
                inTouch) {
              setPlayerState(0);
              hasJumped = true;
              isPushable = false;
              inTouch = false;
              //Détermination du sol où sauter
              jumpCounter++;
              //Reset du X des plateformes due au décallage des plateformes
              switch (getFloor()) {
                //tombe dans le vide
                case 0:
                  jumpCounter--;
                  jumpIntoTheVoid();
                  break;
                case 1:
                  coins = coins + 1;
                  firstFloorY = floorPosition[1];
                  if (blockOne) {
                    for (int i = 0;
                        i < tabBottomFloor[getFloor()].getLength();
                        i++) {
                      if (coins < 2)
                        tabBottomFloor[getFloor()].setGrassXOffset(-grassSize);
                      else
                        tabBottomFloor[getFloor()]
                            .setGrassXOffset(-grassSize * 1.5);
                    }
                  } else if (!blockOne) {
                    for (int i = 0; i < tabFloor[getFloor()].getLength(); i++) {
                      if (coins < 2)
                        tabFloor[getFloor()].setGrassXOffset(-grassSize);
                      else
                        tabFloor[getFloor()].setGrassXOffset(-grassSize * 1.5);
                    }
                  }
                  doAJump();
                  break;
                case 2:
                  coins = coins + 2;
                  firstFloorY = floorPosition[2];
                  if (blockOne) {
                    for (int i = 0;
                        i < tabBottomFloor[getFloor()].getLength();
                        i++) {
                      if (coins < 2)
                        tabBottomFloor[getFloor()]
                            .setGrassXOffset(-grassSize / 2);
                      else
                        tabBottomFloor[getFloor()].setGrassXOffset(-grassSize);
                    }
                  } else if (!blockOne) {
                    for (int i = 0; i < tabFloor[getFloor()].getLength(); i++) {
                      if (coins < 2)
                        tabFloor[getFloor()].setGrassXOffset(-grassSize / 2);
                      else
                        tabFloor[getFloor()].setGrassXOffset(-grassSize);
                    }
                  }
                  doAJump();
                  break;
                case 3:
                  coins = coins + 3;
                  firstFloorY = floorPosition[3];
                  doAJump();
                  break;
              }
              grassYOffset1 = firstFloorY;
            }
          }
        }
      }
    }
    //super.update(t);
  }

  //Assure que ça ne retourne pas un negatif
  //0: vide, 1: 1er etage, 2: 2eme etage, 3: 3eme etage
  int getCurrentFloor() {
    return getFloor() - 1 > 0 ? getFloor() - 1 : 0;
  }

  //Saute dans le vide
  void jumpIntoTheVoid() {
    //Animation de saut
    if (tempPosY <= floorPosition[0]) {
      new Timer(
        const Duration(milliseconds: 2),
        () {
          tempPosY += 2;

          if (blockOne) {
            tabBottomFloor[0].setOpacity(opacity -= 0.1);
            tabBottomFloor[1].setOpacity(opacity -= 0.1);
            tabBottomFloor[2].setOpacity(opacity -= 0.1);

            tabBottomFloor[0].setOpacityC0(opacity -= 0.1);
            tabBottomFloor[0].setOpacityC1(opacity -= 0.1);
            tabBottomFloor[0].setOpacityC2(opacity -= 0.1);
            tabBottomFloor[1].setOpacityC0(opacity -= 0.1);
            tabBottomFloor[1].setOpacityC1(opacity -= 0.1);
            tabBottomFloor[1].setOpacityC2(opacity -= 0.1);
            tabBottomFloor[2].setOpacityC0(opacity -= 0.1);
            tabBottomFloor[2].setOpacityC1(opacity -= 0.1);
            tabBottomFloor[2].setOpacityC2(opacity -= 0.1);
          } else if (!blockOne) {
            tabFloor[0].setOpacity(opacity -= 0.1);
            tabFloor[1].setOpacity(opacity -= 0.1);
            tabFloor[2].setOpacity(opacity -= 0.1);

            tabFloor[0].setOpacityC0(opacity -= 0.1);
            tabFloor[0].setOpacityC1(opacity -= 0.1);
            tabFloor[0].setOpacityC2(opacity -= 0.1);
            tabFloor[1].setOpacityC0(opacity -= 0.1);
            tabFloor[1].setOpacityC1(opacity -= 0.1);
            tabFloor[1].setOpacityC2(opacity -= 0.1);
            tabFloor[2].setOpacityC0(opacity -= 0.1);
            tabFloor[2].setOpacityC1(opacity -= 0.1);
            tabFloor[2].setOpacityC2(opacity -= 0.1);
          }
          jumpIntoTheVoid();
        },
      );
    }
    //Game Over
    else {
      life--;
      //Condition de défaite
      if (life == 0)
        gameOver = true;
      else {
        hasJumped = false;
        tempPosY = floorPosition[1] - size;
        tempPosX = (screenSize.width - size) / 2;

        if (blockOne) {
          //Déplacement des blocs pour pouvoir re-sauter
          manageFloors.j =
              tabFloor[getFloor()].grassXOffset[tabFloor.length - 1].toInt()
                  .toInt() - (grassSize * 3).toInt();
          tabBottomFloor[0].setOpacity(opacity = 1);
          tabBottomFloor[1].setOpacity(opacity = 1);
          tabBottomFloor[2].setOpacity(opacity = 1);
          tabFloor[getFloor()].setOpacity(opacity = 1);
          //Reset coin opacity
          tabBottomFloor[0].setOpacityC0(opacity = 1);
          tabBottomFloor[0].setOpacityC1(opacity = 0);
          tabBottomFloor[0].setOpacityC2(opacity = 0);
          tabBottomFloor[1].setOpacityC0(opacity = 1);
          tabBottomFloor[1].setOpacityC1(opacity = 1);
          tabBottomFloor[1].setOpacityC2(opacity = 0);
          tabBottomFloor[2].setOpacityC0(opacity = 1);
          tabBottomFloor[2].setOpacityC1(opacity = 1);
          tabBottomFloor[2].setOpacityC2(opacity = 1);
        }
        if (!blockOne) {
          //Déplacement des blocs pour pouvoir re-sauter
          manageFloors.j = tabBottomFloor[getFloor()]
              .grassXOffset[tabBottomFloor.length - 1]
              .toInt() - (grassSize * 3).toInt();
          tabFloor[0].setOpacity(opacity = 1);
          tabFloor[1].setOpacity(opacity = 1);
          tabFloor[2].setOpacity(opacity = 1);
          tabBottomFloor[getFloor()].setOpacity(opacity = 1);
          //Reset coin opacity
          tabFloor[0].setOpacityC0(opacity = 1);
          tabFloor[0].setOpacityC1(opacity = 0);
          tabFloor[0].setOpacityC2(opacity = 0);
          tabFloor[1].setOpacityC0(opacity = 1);
          tabFloor[1].setOpacityC1(opacity = 1);
          tabFloor[1].setOpacityC2(opacity = 0);
          tabFloor[2].setOpacityC0(opacity = 1);
          tabFloor[2].setOpacityC1(opacity = 1);
          tabFloor[2].setOpacityC2(opacity = 1);
        }
        setFloor();
      }

      gravity = false;
    }
  }

  void doAJump() {
    //Montée du joueur
    if (tempPosY > firstFloorY - size - grassSize && !gravity) {
      tempTimer = new Timer(
        const Duration(milliseconds: 2),
        () {
          tempPosY -= 3;

          if (!blockOne) {
            switch (getFloor()) {
              //Fall in void
              case 0:
                break;
              case 1:
                tabFloor[1].setOpacity(opacity -= 0.1);
                tabFloor[2].setOpacity(opacity -= 0.1);

                //Coins
                tabFloor[1].setOpacityC0(opacity -= 0.1);
                tabFloor[1].setOpacityC1(opacity -= 0.1);
                tabFloor[1].setOpacityC2(opacity -= 0.1);
                tabFloor[2].setOpacityC0(opacity -= 0.1);
                tabFloor[2].setOpacityC1(opacity -= 0.1);
                tabFloor[2].setOpacityC2(opacity -= 0.1);
                break;
              case 2:
                tabFloor[0].setOpacity(opacity -= 0.1);
                tabFloor[2].setOpacity(opacity -= 0.1);

                //Coins
                tabFloor[0].setOpacityC0(opacity -= 0.1);
                tabFloor[0].setOpacityC1(opacity -= 0.1);
                tabFloor[0].setOpacityC2(opacity -= 0.1);
                tabFloor[2].setOpacityC0(opacity -= 0.1);
                tabFloor[2].setOpacityC1(opacity -= 0.1);
                tabFloor[2].setOpacityC2(opacity -= 0.1);
                break;
              case 3:
                tabFloor[0].setOpacity(opacity -= 0.1);
                tabFloor[1].setOpacity(opacity -= 0.1);

                //Coins
                tabFloor[0].setOpacityC0(opacity -= 0.1);
                tabFloor[0].setOpacityC1(opacity -= 0.1);
                tabFloor[0].setOpacityC2(opacity -= 0.1);
                tabFloor[1].setOpacityC0(opacity -= 0.1);
                tabFloor[1].setOpacityC1(opacity -= 0.1);
                tabFloor[1].setOpacityC2(opacity -= 0.1);
                break;
            }
          } else if (blockOne) {
            switch (getFloor()) {
              case 0:
                break;
              case 1:
                tabBottomFloor[1].setOpacity(opacity -= 0.1);
                tabBottomFloor[2].setOpacity(opacity -= 0.1);

                //Coins
                tabBottomFloor[1].setOpacityC0(opacity -= 0.1);
                tabBottomFloor[1].setOpacityC1(opacity -= 0.1);
                tabBottomFloor[1].setOpacityC2(opacity -= 0.1);
                tabBottomFloor[2].setOpacityC0(opacity -= 0.1);
                tabBottomFloor[2].setOpacityC1(opacity -= 0.1);
                tabBottomFloor[2].setOpacityC2(opacity -= 0.1);
                break;
              case 2:
                tabBottomFloor[0].setOpacity(opacity -= 0.1);
                tabBottomFloor[2].setOpacity(opacity -= 0.1);

                //Coins
                tabBottomFloor[0].setOpacityC0(opacity -= 0.1);
                tabBottomFloor[0].setOpacityC1(opacity -= 0.1);
                tabBottomFloor[0].setOpacityC2(opacity -= 0.1);
                tabBottomFloor[2].setOpacityC0(opacity -= 0.1);
                tabBottomFloor[2].setOpacityC1(opacity -= 0.1);
                tabBottomFloor[2].setOpacityC2(opacity -= 0.1);
                break;
              case 3:
                tabBottomFloor[0].setOpacity(opacity -= 0.1);
                tabBottomFloor[1].setOpacity(opacity -= 0.1);

                //Coins
                tabBottomFloor[0].setOpacityC0(opacity -= 0.1);
                tabBottomFloor[0].setOpacityC1(opacity -= 0.1);
                tabBottomFloor[0].setOpacityC2(opacity -= 0.1);
                tabBottomFloor[1].setOpacityC0(opacity -= 0.1);
                tabBottomFloor[1].setOpacityC1(opacity -= 0.1);
                tabBottomFloor[1].setOpacityC2(opacity -= 0.1);
                break;
            }
          }
          doAJump();
        },
      );
      //tempTimer?.cancel();
    }
    //Montée du joueur plus haut pour retomber dans la boucle suivante
    else if (tempPosY > firstFloorY - size - grassSize - 5 && !gravity) {
      gravity = true;
      tempPosY -= 3;
      doAJump();
    } else {
      if (tempPosY < firstFloorY - size) {
        tempTimer = new Timer(
          const Duration(milliseconds: 5),
          () {
            if (!pauseGame) tempPosY += 2;
            doAJump();
          },
        );
      } //descente des blocs après 2 blocs sur la nouvelle plateforme
      else if (!blockOne &&
          tabBottomFloor[getFloor() - 1].grassXOffset[
                  tabBottomFloor[getFloor() - 1].grassXOffset.length - 1] <
              manageFloors.j - 2 * grassSize) {
        tempTimer?.cancel();
        isOutOfScreen = true;
        hasJumped = false;
        isTheFirstPlatform = true;
        setPlayerDown();
        gravity = false;
      } //descente des blocs après 2 blocs sur la nouvelle plateforme
      else if (blockOne &&
          tabFloor[getFloor() - 1].grassXOffset[
                  tabFloor[getFloor() - 1].grassXOffset.length - 1] <
              manageFloors.j - 2 * grassSize) {
        tempTimer?.cancel();
        isOutOfScreen = true;
        hasJumped = false;
        isTheFirstPlatform = true;
        setPlayerDown();
        gravity = false;
      } else {
        tempTimer = new Timer(
          const Duration(milliseconds: 500),
          () {
            doAJump();
          },
        );
      }
    }
    //tempPosY = (screenSize.height - screenSize.width * 0.3) - size;
    temp.y = tempPosY;
  }

  void setPlayerDown() {
    new Timer(
      const Duration(milliseconds: 5),
      () {
        //Descente du bonhomme
        if (tempPosY < screenSize.height - (size) - grassSize) {
          if (!pauseGame) tempPosY += 1;
          setPlayerDown();
        }
        //Descente du sol en fonction du bonhomme

        if (pauseGame)
          ;
        else if (grassYOffset1 < screenSize.height - grassSize && blockOne) {
          grassYOffset1 = tempPosY + size;
          switch (getFloor()) {
            case 0:
              break;
            case 1:
              tabFloor[0].updateRect();
              tabFloor[1].setOpacity(opacity -= 0.01);
              tabFloor[2].setOpacity(opacity -= 0.01);
              break;
            case 2:
              tabFloor[0].setOpacity(opacity -= 0.01);
              tabFloor[1].updateRect();
              tabFloor[2].setOpacity(opacity -= 0.01);
              break;
            case 3:
              tabFloor[0].setOpacity(opacity -= 0.01);
              tabFloor[1].setOpacity(opacity -= 0.01);
              tabFloor[2].updateRect();
              break;
          }
        } else if (grassYOffset < screenSize.height - grassSize && !blockOne) {
          grassYOffset = tempPosY + size;
          switch (getFloor()) {
            case 0:
              break;
            case 1:
              tabBottomFloor[0].updateRect();
              tabBottomFloor[1].setOpacity(opacity -= 0.01);
              tabBottomFloor[2].setOpacity(opacity -= 0.01);
              break;
            case 2:
              tabBottomFloor[0].setOpacity(opacity -= 0.01);
              tabBottomFloor[1].updateRect();
              tabBottomFloor[2].setOpacity(opacity -= 0.01);
              break;
            case 3:
              tabBottomFloor[0].setOpacity(opacity -= 0.01);
              tabBottomFloor[1].setOpacity(opacity -= 0.01);
              tabBottomFloor[2].updateRect();
              break;
          }
        }
      },
    );
  }

  double getSignPosition() {
    return signPosition;
  }

  void setPlayerState(int state) {
    //Jump
    if (state == 0) {
      isJumping = true;
      isRunning = false;
      isWaiting = false;
      j = 0;
      i = 0;
    }
    //Run
    if (state == 1) {
      isJumping = false;
      isRunning = true;
      isWaiting = false;
      j = 1;
      i = 0;
    }
    //Wait
    if (state == 2) {
      isJumping = false;
      isRunning = false;
      isWaiting = true;
      j = 2;
      i = 0;
    }
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
      phaseTuto++;
      if (phaseTuto == 4 || phaseTuto == 6) launchTuto = false;

      //inTouch = true;
    }
  }

  int getCoins() {
    return coins;
  }

  int getScore() {
    return coins;
  }

  int getJumpCounter() {
    return jumpCounter;
  }

  void setColorFilter(bool boolean) {
    redFilter = boolean;
  }

  ColorFilter getColorFilter() {
    if (redFilter == null) redFilter = true;
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

  bool getEndGame() {
    return endGame;
  }

  bool getConnectionState() {
    return isConnected;
  }

  bool getPosition() {
    //True: position haut
    //False: position basse
    return isTopPosition;
  }

  bool getPauseStatus() {
    return pauseGame;
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

  void setPushState(bool _isPushing) {
    isPushing = _isPushing;
  }

  bool getPushState() {
    return isPushing;
  }

  void startTimer(bool isStarted, double _start) async {
    Timer _timer;

    if (!isStarted && isConnected) {
      //_start = 5.0;
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
          if (isConnected) {
            if (_start < 0.5) {
              //TODO Display menu ?
              setColorFilter(true);
              timer.cancel();
              gameOver = true;
            } else if (!pauseGame) {
              setColorFilter(!redFilter);
              _start = _start - 0.5;
              print(_start);
            }
          } else {
            setColorFilter(false);
            timer.cancel();
          }
        },
      );
    }
  }
}
