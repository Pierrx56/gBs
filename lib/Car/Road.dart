import 'dart:math';
import 'dart:ui';
import 'dart:async' as async;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/Car/CarGame.dart';

double balloonPosition = 0.1;
double posX = 0;
double posY = 0;
double carSize = 0;
int j = 0;
int roadSpeed = 4;
double speedCars = 0.6;
double speedTruck = 0.5;
int widthRoad;

String spriteRoad = "car/autoroute.png";
String spriteFuel = "car/fuel.png";
String spriteRedTruck = "car/red_truck.png";
String spritePolice = "car/police_car.png";
String spriteBrownTruck = "car/brown_truck.png";
String spriteGreenCar = "car/green_car.png";
String spriteRedCar = "car/red_car.png";
String spriteBrownCar = "car/brown_car.png";
String leftUpRoad = "car/turn_left_to_up.png";
String leftDownRoad = "car/turn_left_to_down.png";
String upRightRoad = "car/turn_up_to_right.png";

int straightRoad = 150;
int numberCars = 3;
int numberFuel = 4;
int numberTruck = 10;
int numberPolice = 1;

class StraightRoad {
  final CarGame game;
  Vector2 posRoad;
  Vector2 sizeRoad;
  List<Sprite> roadList = [];

  void _loadImage() async {
    for (int l = 0; l < straightRoad; l++) {
      roadList.add(new Sprite(await Flame.images.load(spriteRoad)));
    }
  }

  StraightRoad(this.game) {
    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    //int number = rng.nextInt(balloonArray.length);
    int number = 0;

    widthRoad = 150; //bottomBalloon.image.width;
    _loadImage();

    j = 10;

    //width: 500
    //height: 300
    posRoad = Vector2(0, 0);
    sizeRoad = Vector2(game.screenSize.width, game.screenSize.height);
  }

  void render(
      Canvas c, bool pause, bool reset, bool hasCrash, bool hasCrashSecondWay) {
    if (reset) j = 10;

    c.translate(posX = game.screenSize.width - widthRoad - j.toDouble(), 0);

    if (pause)
      ; // j += 6*roadSpeed;
    //Replacing car in second road and go forward for 2 seconds
    else if (hasCrash) {
      j -= 2 * roadSpeed;
      //Collision TME
      if ((game.tempPos >= game.screenSize.height * 0.4)) {
        game.tempPos = game.car.y;
        game.car.y -= game.difficulte;
      } else {
        game.posMid = true;
        game.posMin = false;
        game.posMax = false;
      }
    } else if (hasCrashSecondWay) {
      j -= 2 * roadSpeed;
      //Collision CMV
      if ((game.tempPos >= game.screenSize.height * 0.1)) {
        game.tempPos = game.car.y;
        game.car.y -= game.difficulte;
      } else {
        game.posMid = false;
        game.posMin = false;
        game.posMax = true;
      }
    } //else j += roadSpeed;

    for (int i = 0; i < roadList.length; i++) {
      posRoad = Vector2(
          (i * game.screenSize.width).toDouble() - game.screenSize.width, 0);
      sizeRoad = Vector2(game.screenSize.width, game.screenSize.height);

      roadList[i].render(c, position: posRoad, size: sizeRoad);
    }
    // restore original state
    //c.restore();
  }

  void setCarSize(double size) {
    carSize = size * 1.5;
  }

  double getYBottomPosition() {
    posY = carSize;
    return posY;
  }

  double getYTopPosition() {
    posY = game.screenSize.height - carSize;
    return posY;
  }

  double getXBottomPosition() {
    return posX;
  }

  void update(double t) {}
}

//Trucks + cars
class CMV {
  final CarGame game;

  List<Sprite> truckList = [];
  List<double> posXTruck = [];
  double widthTruck = 0;
  double heightTruck = 0;

  double widthCar = 0;
  double heightCar = 0;

  List<Vector2> posTruck = [];
  List<Vector2> sizeTruck = [];

  double spacerTruck = 50;


  CMV(this.game, this.truckList) {
    widthRoad = 150; //bottomBalloon.image.width;

    widthTruck = game.screenSize.width * 0.35;
    heightTruck = game.screenSize.width * 0.12;

    widthCar = game.screenSize.width * 0.22;
    heightCar = widthCar * 0.5;

    for (int l = 0; l < numberCars; l++) {
      posXTruck.add(0.0);
      posTruck.add(Vector2(0, 0));
      sizeTruck.add(Vector2(game.screenSize.width, game.screenSize.height));
    }

    int k = 0;
    for (int i = numberCars - truckList.length; i < truckList.length; i++) {
      posTruck[k] = Vector2(
          posXTruck[k] = game.screenSize.width * 0.5 +
              speedTruck * j +
              i * (widthTruck + spacerTruck),
          k == 0 ? game.screenSize.height * 0.7 : game.screenSize.height * 0.4);

      sizeTruck[k] = Vector2(
          k == 0 ? widthTruck : widthCar, k == 0 ? heightTruck : heightCar);

      k++;
    }
    //width: 500
    //height: 300
  }

  void render(Canvas c, bool pause, bool reset) {
    c.translate(posX = speedTruck * j.toDouble(), 0);

    for (int i = 0; i < truckList.length; i++)
      truckList[i].render(c, position: posTruck[i], size: sizeTruck[i]);

    //print(posXTruck);
    /*
    //If the car get the fuel, disappear fuel
    if (game.posMid &&
        fuelList.length >= 1 &&
        (j - game.posX) % game.screenSize.width <
            game.posX + game.plane.width / 2) {
      fuelList.length--;
    }*/

    // restore original state
    //c.restore();
  }

  void setCarSize(double size) {
    carSize = size * 1.5;
  }

  double getYBottomPosition() {
    posY = carSize;
    return posY;
  }

  double getWidth() {
    return widthTruck;
  }

  double getHeight() {
    return heightTruck;
  }

  double getXPosition(int k) {
    return posXTruck[k];
  }

  double getYTopPosition() {
    posY = game.screenSize.height - carSize;
    return posY;
  }

  void update(double t) {}
}

//Fuels
class CSI {
  final CarGame game;
  List<Vector2> posFuel = [];
  List<Vector2> sizeFuel = [];
  List<Sprite> fuelList = [];
  List<double> posXFuel = [];
  List<double> posYFuel = [];
  double widthFuel = 0;
  double heightFuel = 0;
  double spacerFuel = 150;
  double speedFuel = 0;
  int numberCSI = 0;
  bool hasPassedMid = false;
  bool hasPassedMax = false;
  bool hasHadScore = false;


  CSI(this.game, this.fuelList) {
    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    //int number = rng.nextInt(balloonArray.length);
    int number = 0;

    numberCSI = 0;
    hasPassedMid = false;
    hasPassedMax = false;
    hasHadScore = false;

    widthRoad = 150; //bottomBalloon.image.width;

    spacerFuel = game.screenSize.width * 0.6;
    speedFuel = (widthFuel / game.screenSize.width);

    widthFuel = game.screenSize.width * 0.1;
    heightFuel = game.screenSize.width * 0.12;

    for (int l = 0; l < numberFuel; l++) {
      posXFuel.add(0.0);
      posYFuel.add(0.0);
      posFuel.add(Vector2(0, 0));
      sizeFuel.add(Vector2(game.screenSize.width, game.screenSize.height));
    }

    int k = 0;
    for (int i = numberFuel - fuelList.length; i < fuelList.length; i++) {
      posFuel[k] = Vector2(
          posXFuel[k] =
              /*straightRoad * widthBalloon + (i * widthTruck * 1.5).toDouble() + game.screenSize.width*/
              game.screenSize.width + j + i * (widthFuel + spacerFuel),
          i % 2 == 0
              ? posYFuel[k] = game.screenSize.height * 0.4
              : posYFuel[k] = game.screenSize.height * 0.1);
      sizeFuel[k] = Vector2(widthFuel, heightFuel);

      k++;
    }
    //width: 500
    //height: 300
  }

  void render(Canvas c, bool pause, bool reset) {
    c.translate(speedFuel * (-j.toDouble()), 0);

    for (int i = 0; i < posFuel.length; i++)
      fuelList[i].render(c, position: posFuel[i], size: sizeFuel[i]);
  }

  void setCarSize(double size) {
    carSize = size * 1.5;
  }

  void removeFuel(int fuelToRemove) {
    game.fuelIsDown = !game.fuelIsDown;
    numberCSI++;

    List<double> tempPosX = posXFuel;
    List<double> tempPosY = posYFuel;

    int offset = posXFuel.length;

    for (int i = 0; i < offset; i++) {
      posXFuel[i] = tempPosX[i];
      posYFuel[i] = tempPosY[i];

      if (i == fuelToRemove && !hasHadScore) {
        posYFuel[i] = game.screenSize.width * 2;
        game.score++;
        hasHadScore = true;
      }
    }

    for (int i = 0; i < offset; i++) {
      posFuel[i] = Vector2(posXFuel[i], posYFuel[i]);
      sizeFuel[i] = Vector2(widthFuel, heightFuel);
    }

/*
    if (game.posMid && !hasPassedMid) {
      hasPassedMid = true;
      game.score++;
      int offset = posXFuel.length - 1;

      for (int i = 0; i < offset; i++) {
        posXFuel[i] = tempPosX[(i + 1)];
        posYFuel[i] = tempPosY[(i + 1)];
      }

      for (int i = 0; i < offset; i++) {
        rectBottomList[i] = Rect.fromLTWH(
            //336
            posXFuel[i],
            posYFuel[i],
            widthFuel,
            heightFuel);
      }
    }
    else if (game.posMax && !hasPassedMax) {
      hasPassedMax = true;
      game.score++;
      for (int i = 0; i < rectBottomList.length; i++) {
        rectBottomList[i] = Rect.fromLTWH(
            //336
            posXFuel[i],
            game.screenSize.height * 1.4,
            widthFuel,
            heightFuel);
      }
      numberCSI = 0;
      game.isDoingExercice = false;
      game.fuelIsDown = true;
      //game.csi = null;

    }*/
  }

  double getYBottomPosition() {
    posY = carSize;
    return posY;
  }

  double getYTopPosition() {
    posY = game.screenSize.height - carSize;
    return posY;
  }

  double getWidth() {
    return widthFuel;
  }

  double getHeight() {
    return heightFuel;
  }

  double getXPosition(int k) {
    return posXFuel[k];
  }

  double getYPosition(int k) {
    return posYFuel[k];
  }

  void update(double t) {}
}

//Trucks
class TME {
  final CarGame game;

  List<Vector2> posTruck = [];
  List<Vector2> sizeTruck = [];
  List<Sprite> truckList = [];
  List<double> posXTruck = [];
  double widthTruck = 0;
  double heightTruck = 0;
  double spacerTruck = 50;


  TME(this.game, this.truckList) {
    widthRoad = 150; //bottomBalloon.image.width;

    widthTruck = game.screenSize.width * 0.35;
    heightTruck = game.screenSize.width * 0.12;

    for (int l = 0; l < numberTruck; l++) {
      posXTruck.add(0.0);

      posTruck.add(Vector2(0, 0));
      sizeTruck.add(Vector2(widthTruck, heightTruck));
    }

    //print(truckList.length);

    int k = 0;
    for (int i = numberTruck - truckList.length; i < truckList.length; i++) {
      posTruck[k] = Vector2(
          //336
          posXTruck[k] = game.screenSize.width * 0.5 +
              speedTruck * j +
              i * (widthTruck + spacerTruck),
          game.screenSize.height - widthRoad * 0.7);
      sizeTruck[k] = Vector2(widthTruck, heightTruck);

      k++;
    }
    //width: 500
    //height: 300
  }

  void render(Canvas c, bool pause, bool reset) {
    c.translate(posX = speedTruck * j.toDouble(), 0);

    for (int i = 0; i < truckList.length; i++)
      truckList[i].render(c, position: posTruck[i], size: sizeTruck[i]);

    //print(posXTruck);
    /*
    //If the car get the fuel, disappear fuel
    if (game.posMid &&
        fuelList.length >= 1 &&
        (j - game.posX) % game.screenSize.width <
            game.posX + game.plane.width / 2) {
      fuelList.length--;
    }*/

    // restore original state
    //c.restore();
  }

  void setCarSize(double size) {
    carSize = size * 1.5;
  }

  double getYBottomPosition() {
    posY = carSize;
    return posY;
  }

  double getWidth() {
    return widthTruck;
  }

  double getHeight() {
    return heightTruck;
  }

  double getXPosition(int k) {
    return posXTruck[k];
  }

  double getYTopPosition() {
    posY = game.screenSize.height - carSize;
    return posY;
  }

  void update(double t) {}
}

class POLICE {
  final CarGame game;

  List<Sprite> policeList = [];
  List<double> posXPolice = [];
  List<Vector2> posPolice = [];
  List<Vector2> sizePolice = [];

  double widthPolice = 0;
  double heightPolice = 0;

  void _loadImage(String image) async {
    policeList.add(new Sprite(await Flame.images.load(image)));
  }

  POLICE(this.game) {
    widthRoad = 150; //bottomBalloon.image.width;

    widthPolice = game.screenSize.width * 0.24;
    heightPolice = game.screenSize.width * 0.12;

    for (int l = 0; l < numberPolice; l++) {
      _loadImage(spritePolice);

      posXPolice.add(0.0);
      posPolice.add(Vector2(0, 0));
      sizePolice.add(Vector2(game.screenSize.width, game.screenSize.height));
    }

    print(policeList.length);

    int k = 0;
    for (int i = numberPolice - policeList.length; i < policeList.length; i++) {
      posPolice[k] = Vector2(
          //336
          posXPolice[k] = -game.screenSize.width * 3,
          /*straightRoad * widthBalloon + (i * widthTruck * 1.5).toDouble() + game.screenSize.width*/
          //j + i * (widthPolice),
          game.screenSize.height * 0.1);
      sizePolice[k] = Vector2(widthPolice, heightPolice);

      k++;
    }
    //width: 500
    //height: 300
  }

  void render(Canvas c, bool pause, bool reset) {
    c.translate(posX = game.screenSize.width + 4 * j.toDouble(), 0);

//   print(0.6*game.screenSize.width - (j%game.screenSize.width)/2);

    for (int i = 0; i < posPolice.length; i++)
      policeList[i].render(c, position: posPolice[i], size: sizePolice[i]);

    /*
    //If the car get the fuel, disappear fuel
    if (game.posMid &&
        fuelList.length >= 1 &&
        (j - game.posX) % game.screenSize.width <
            game.posX + game.plane.width / 2) {
      fuelList.length--;
    }*/

    // restore original state
    //c.restore();
  }

  void setCarSize(double size) {
    carSize = size * 1.5;
  }

  double getYBottomPosition() {
    posY = carSize;
    return posY;
  }

  double getWidth() {
    return widthPolice;
  }

  double getHeight() {
    return heightPolice;
  }

  double getYTopPosition() {
    posY = game.screenSize.height - carSize;
    return posY;
  }

  double getXPosition(int k) {
    return posXPolice[k];
  }

  void update(double t) {}
}
