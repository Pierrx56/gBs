import 'dart:math';
import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';

class WaterLine {}

double linePosition = 0.1;
int j = 0;
int linesSpeed = 2;
List<String> balloonArray = ["plane/balloon-green.png", "plane/balloon-pink.png"];

class BottomBalloon {
  final PlaneGame game;
  Sprite bottomBalloon;
  Rect rectBottom;

  BottomBalloon(this.game) {

    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    int number = rng.nextInt(2);
    print("Ballon bas: $number");
    bottomBalloon = Sprite(balloonArray[number]);
    //width: 500
    //height: 300

    rectBottom = Rect.fromLTWH(
        0, 0, game.screenSize.width*0.05, game.screenSize.height * 0.2);
  }

  void render(Canvas c, bool pause) {
    //bgSprite.render(c);

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(
        -game.screenSize.width / 2, -game.screenSize.height * (linePosition));

    if (j >= game.screenSize.width) j = 0;

    if(pause)
      j -= linesSpeed;

    c.translate(game.screenSize.width - j.toDouble(), 0);

    bottomBalloon.renderRect(c, rectBottom);

    c.translate(-game.screenSize.width, 0);

    bottomBalloon.renderRect(c, rectBottom);
    // restore original state
    c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (linePosition);
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
    int number = rng.nextInt(2);
    print("Ballon haut: $number");
    topBalloon = Sprite(balloonArray[number]);

    //width: 500
    //height: 300
    rectTop = Rect.fromLTWH(
        0, 0, game.screenSize.width*0.05, game.screenSize.height * 0.2);
  }

  void render(Canvas c) {
    //bgSprite.render(c);

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(-game.screenSize.width / 2,
        -game.screenSize.height * (1 - linePosition));

    if (j >= game.screenSize.width) j = 0;

    c.translate(game.screenSize.width - j.toDouble(), 0);
    j += linesSpeed;

    topBalloon.renderRect(c, rectTop);

    c.translate(-game.screenSize.width, 0);

    topBalloon.renderRect(c, rectTop);

    // restore original state
    c.restore();
  }

  double getUpPosition() {
    return game.screenSize.height * (1 - linePosition);
  }

  void update(double t) {}
}
