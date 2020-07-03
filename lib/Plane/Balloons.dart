import 'dart:math';
import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';

class WaterLine {}

double balloonPosition = 0.1;
double posX = 0;
double posY = 0;
int j = 0;
int balloonSpeed = 2;
int widthBalloon;
List<String> balloonArray = ["plane/balloon-green.png", "plane/balloon-pink.png"];


class BottomBalloon {
  final PlaneGame game;
  Sprite bottomBalloon;
  Rect rectBottom;

  BottomBalloon(this.game) {

    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    int number = rng.nextInt(balloonArray.length);

    bottomBalloon = new Sprite(balloonArray[number]);
    widthBalloon = 30;//bottomBalloon.image.width;

    //width: 500
    //height: 300
    rectBottom = Rect.fromLTWH(
        0, 0, game.screenSize.width*0.05, game.screenSize.height * 0.2);
  }

  void render(Canvas c, bool pause, bool reset) {

    if(reset)
      j = 10;

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(-game.screenSize.width / 2,
        -game.screenSize.height * (balloonPosition*2));

    if (j >= game.screenSize.width) {
      j = 0;
      var rng = new Random();
      //Génération de ballon de couleur aléatoire
      int number = rng.nextInt(balloonArray.length);

      bottomBalloon = new Sprite(balloonArray[number]);
    }
    c.translate(posX = game.screenSize.width - widthBalloon - j.toDouble(), 0);
    j += balloonSpeed;

    if(pause)
      j -= balloonSpeed;

    bottomBalloon.renderRect(c, rectBottom);

    c.translate(-game.screenSize.width - widthBalloon, 0);

    bottomBalloon.renderRect(c, rectBottom);

    // restore original state
    c.restore();
  }

  double getYBottomPosition() {
    posY = game.screenSize.height * (balloonPosition*2);
    return posY;
  }

  double getXBottomPosition() {
    return posX;
  }

  void update(double t) {}
}

class TopBalloon {
  final PlaneGame game;
  Sprite topBalloon;
  Rect rectTop;

  TopBalloon(this.game) {

    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    int number = rng.nextInt(balloonArray.length);

    topBalloon = new Sprite(balloonArray[number]);

    widthBalloon = 30;//topBalloon.image.width;
    //width: 500
    //height: 300

    rectTop = Rect.fromLTWH(
        0, 0, game.screenSize.width*0.05, game.screenSize.height * 0.2);
  }

  void render(Canvas c, bool pause, bool reset) {

    if(reset)
      j = 10;

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(
        -game.screenSize.width / 2, -game.screenSize.height * (1 - balloonPosition));

    if (j >= game.screenSize.width){
      j = 0;
      var rng = new Random();
      //Génération de ballon de couleur aléatoire
      int number = rng.nextInt(balloonArray.length);
      topBalloon = new Sprite(balloonArray[number]);
    }

    j += balloonSpeed;

    if(pause)
      j -= balloonSpeed;

    c.translate( posX = game.screenSize.width - widthBalloon - j.toDouble(), 0);

    topBalloon.renderRect(c, rectTop);

    c.translate(-game.screenSize.width, 0);

    topBalloon.renderRect(c, rectTop);
    // restore original state
    c.restore();
  }

  double getYTopPosition() {
    posY = game.screenSize.height * (1 - balloonPosition);
    //print(posY);
    return posY;
  }

  double getXTopPosition() {
    return posX;
  }

  void update(double t) {}
}
