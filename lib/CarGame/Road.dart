import 'dart:math';
import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/CarGame/CarGame.dart';

double balloonPosition = 0.1;
double posX = 0;
double posY = 0;
double carSize = 0;
int j = 0;
int roadSpeed = 4;
double speedTruck = 0.5;
int widthRoad;
List<String> balloonArray = ["car/straight_road_left.png"];
String spriteRoad = "car/autoroute.png";
String spriteFuel = "car/fuel.png";
String spriteRedTruck = "car/red_truck.png";
String spritePolice = "car/police_car.png";
String spriteBrownTruck = "car/brown_truck.png";
String leftUpRoad = "car/turn_left_to_up.png";
String leftDownRoad = "car/turn_left_to_down.png";
String upRightRoad = "car/turn_up_to_right.png";

int straightRoad = 30;
int numberFuel = 2;
int numberTruck = 10;
int numberPolice = 1;

class StraightRoad {
  final CarGame game;
  Rect rectBottom;
  List<Sprite> roadList = [];

  StraightRoad(this.game) {
    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    //int number = rng.nextInt(balloonArray.length);
    int number = 0;

    widthRoad = 150; //bottomBalloon.image.width;

    for (int l = 0; l < straightRoad; l++) {
      roadList.add(new Sprite(spriteRoad));
    }

    j = 10;

    print(roadList.length);

    //width: 500
    //height: 300
    rectBottom =
        Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height);
  }

  void render(Canvas c, bool pause, bool reset, bool hasCrash) {
    if (reset) j = 10;

    //c.translate(game.screenSize.width / 2, game.screenSize.height *0.5);
    //c.translate(-game.screenSize.width / 2, 0); //(game.screenSize.height *0.5) - widthBalloon/2);

    /*
    if (j >= game.screenSize.width) {
      j = 0;
      var rng = new Random();
      //Génération de ballon de couleur aléatoire
      //int number = rng.nextInt(balloonArray.length);
      int number = 0;
      for(int l = 0; l < k ; l++){
        roadList.add(new Sprite(spriteRoad));
      }
    }*/

    c.translate(posX = game.screenSize.width - widthRoad - j.toDouble(), 0);

    if (pause)
      ; // j += 6*roadSpeed;
    //Replacing car in second road and go forward for 2 seconds
    else if (hasCrash) {
      j -= 2 * roadSpeed;
      //Collision CMV
      if ((game.tempPos >= game.screenSize.height * 0.4)) {
        game.tempPos = game.plane.y;
        game.plane.y -= game.difficulte;
      } else
        game.posMid = true;
    } else
      j += roadSpeed;

    for (int i = 0; i < roadList.length; i++) {
      rectBottom = Rect.fromLTWH(
          (i * game.screenSize.width).toDouble() - game.screenSize.width,
          0,
          game.screenSize.width,
          game.screenSize.height);

      //c.translate(-game.screenSize.width - widthBalloon, 0);

      roadList[i].renderRect(c, rectBottom);
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

class CSI {
  final CarGame game;
  List<Rect> rectBottomList = [];
  List<Sprite> fuelList = [];
  List<double> posXFuel = [];
  List<double> posYFuel = [];
  double widthFuel = 0;
  double heightFuel = 0;
  double spacerFuel = 50;
  double speedFuel = 0;
  int numberCSI = 0;

  CSI(this.game) {
    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    //int number = rng.nextInt(balloonArray.length);
    int number = 0;

    numberCSI = 0;

    widthRoad = 150; //bottomBalloon.image.width;

    spacerFuel = game.screenSize.width * 0.4;
    speedFuel = (widthFuel / game.screenSize.width);

    widthFuel = game.screenSize.width * 0.1;
    heightFuel = game.screenSize.width * 0.12;

    for (int l = 0; l < numberFuel; l++) {
      fuelList.add(new Sprite(spriteFuel));
      posXFuel.add(0.0);
      posYFuel.add(0.0);
      rectBottomList.add(
          Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height));
    }

    print(fuelList.length);

    int k = 0;
    for (int i = numberFuel - fuelList.length; i < fuelList.length; i++) {
      rectBottomList[k] = Rect.fromLTWH(
          //336
          posXFuel[k] =
              /*straightRoad * widthBalloon + (i * widthTruck * 1.5).toDouble() + game.screenSize.width*/
              game.screenSize.width + j + i * (widthFuel + spacerFuel),
          i % 2 == 0
              ? posYFuel[k] = game.screenSize.height * 0.7
              : posYFuel[k] = game.screenSize.height * 0.4,
          widthFuel,
          heightFuel);

      k++;
    }
    //width: 500
    //height: 300
  }

  void render(Canvas c, bool pause, bool reset) {
    c.translate(speedFuel * (-j.toDouble()), 0);

    for (int i = 0; i < rectBottomList.length; i++)
      fuelList[i].renderRect(c, rectBottomList[i]);
  }

  void setCarSize(double size) {
    carSize = size * 1.5;
  }

  void setPosXFuel() {
    game.score++;
    game.fuelIsDown = !game.fuelIsDown;
    numberCSI++;

    //If player has every fuels, reset datas
    if (numberCSI == 2) {
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
      game.csi = null;
    } else {
      List<double> tempPosX = posXFuel;
      List<double> tempPosY = posYFuel;

      int offset = posXFuel.length - 1;

      for (int i = 0; i < offset; i++) {
        posXFuel[i] = tempPosX[(i + 1)];
        posYFuel[i] = tempPosY[(i + 1)];
      }

      for (int i = 0; i < rectBottomList.length - 1; i++) {
        rectBottomList[i] = Rect.fromLTWH(
            //336
            posXFuel[i],
            posYFuel[i],
            widthFuel,
            heightFuel);
      }
    }
  }

  double getYBottomPosition() {
    posY = carSize;
    return posY;
  }

  double getYTopPosition() {
    posY = game.screenSize.height - carSize;
    return posY;
  }

  int getFuelTaken() {
    if (fuelList != null)
      return numberFuel;
    else
      return 0;
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

  void update(double t) {}
}

class TME {
  final CarGame game;
  List<Rect> rectBottomList = [];
  List<Sprite> truckList = [];
  List<double> posXTruck = [];
  double widthTruck = 0;
  double heightTruck = 0;
  double spacerTruck = 50;

  TME(this.game) {
    widthRoad = 150; //bottomBalloon.image.width;

    widthTruck = game.screenSize.width * 0.35;
    heightTruck = game.screenSize.width * 0.12;

    for (int l = 0; l < numberTruck; l++) {
      truckList.add(new Sprite(spriteRedTruck));
      posXTruck.add(0.0);
      rectBottomList.add(
          Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height));
    }

    print(truckList.length);

    int k = 0;
    for (int i = numberTruck - truckList.length; i < truckList.length; i++) {
      rectBottomList[k] = Rect.fromLTWH(
          //336
          posXTruck[k] =
              /*straightRoad * widthBalloon + (i * widthTruck * 1.5).toDouble() + game.screenSize.width*/
              j + i * (widthTruck + spacerTruck),
          game.screenSize.height - widthRoad * 0.7,
          widthTruck,
          heightTruck);

      k++;
    }
    //width: 500
    //height: 300
  }

  void render(Canvas c, bool pause, bool reset) {
    c.translate(posX = speedTruck* j.toDouble(), 0);

    for (int i = 0; i < rectBottomList.length; i++)
      truckList[i].renderRect(c, rectBottomList[i]);

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
  List<Rect> rectBottomList = [];
  List<Sprite> policeList = [];
  List<double> posXPolice = [];
  double widthPolice = 0;
  double heightPolice = 0;

  POLICE(this.game) {
    widthRoad = 150; //bottomBalloon.image.width;

    widthPolice = game.screenSize.width * 0.24;
    heightPolice = game.screenSize.width * 0.12;

    for (int l = 0; l < numberPolice; l++) {
      policeList.add(new Sprite(spritePolice));
      posXPolice.add(0.0);
      rectBottomList.add(
          Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height));
    }

    print(policeList.length);

    int k = 0;
    for (int i = numberPolice - policeList.length; i < policeList.length; i++) {
      rectBottomList[k] = Rect.fromLTWH(
          //336
          posXPolice[k] = -game.screenSize.width * 3,
          /*straightRoad * widthBalloon + (i * widthTruck * 1.5).toDouble() + game.screenSize.width*/
          //j + i * (widthPolice),
          game.screenSize.height / 3 - heightPolice,
          widthPolice,
          heightPolice);

      k++;
    }
    //width: 500
    //height: 300
  }

  void render(Canvas c, bool pause, bool reset) {
    c.translate(posX = game.screenSize.width + 4 * j.toDouble(), 0);

//   print(0.6*game.screenSize.width - (j%game.screenSize.width)/2);

    for (int i = 0; i < rectBottomList.length; i++)
      policeList[i].renderRect(c, rectBottomList[i]);

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
