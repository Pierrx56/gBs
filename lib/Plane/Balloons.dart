import 'dart:math';
import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';

double balloonPosition = 0.1;
double posY = 0;
int balloonSpeed = 2;
int widthBalloon;
List<String> balloonArray = ["plane/balloon-green.png", "plane/balloon-pink.png"];


class BottomBalloon {
  final PlaneGame game;
  Sprite bottomBalloon;
  Rect rectBottom;
  Vector2 rectSize;
  Vector2 rectPosition;
  int j = 0;
  double posX = 0;


  var image;

  _loadImage(String index) async{
    image = await Flame.images.load(index);
    bottomBalloon = new Sprite(image);
  }

  BottomBalloon(this.game) {

    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    //int number = rng.nextInt(balloonArray.length);
    int number = 0;

    _loadImage(balloonArray[number]);

    widthBalloon = 30;//bottomBalloon.image.width;

    rectSize = Vector2( game.screenSize.width*0.05, game.screenSize.height * 0.2);
    rectPosition = Vector2(0,0);


    //width: 500
    //height: 300
    //rectBottom = Rect.fromLTWH(0, 0, game.screenSize.width*0.05, game.screenSize.height * 0.2);

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
      //int number = rng.nextInt(balloonArray.length);
      int number = 0;
      _loadImage(balloonArray[number]);
      bottomBalloon = new Sprite(image);
    }
    c.translate(posX = game.screenSize.width - widthBalloon - j.toDouble(), 0);
    j += balloonSpeed;

    if(pause)
      j -= balloonSpeed;

    bottomBalloon.render(c, size: rectSize, position: rectPosition);

    c.translate(-game.screenSize.width - widthBalloon, 0);

    bottomBalloon.render(c, size: rectSize, position: rectPosition);

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
  Vector2 rectSize;
  Vector2 rectPosition;
  double posX = 0;

  int j = 0;

  var image;

  _loadImage(String index) async{
    image = await Flame.images.load(index);
    topBalloon = new Sprite(image);
  }

  TopBalloon(this.game) {

    var rng = new Random();
    //Génération de ballon de couleur aléatoire
    //int number = rng.nextInt(balloonArray.length);
    int number = 0;

    _loadImage(balloonArray[number]);

    widthBalloon = 30;//topBalloon.image.width;
    //width: 500
    //height: 300

    rectTop = Rect.fromLTWH(
        0, 0, game.screenSize.width*0.05, game.screenSize.height * 0.2);

    rectSize = Vector2( game.screenSize.width*0.05, game.screenSize.height * 0.2);
    rectPosition = Vector2(0,0);
  }

  void render(Canvas c, bool pause, bool reset) {

    if(reset)
      j = 10;

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(-game.screenSize.width / 2, -game.screenSize.height * (1 - balloonPosition));

    if (j >= game.screenSize.width){
      j = 0;
      var rng = new Random();
      //Génération de ballon de couleur aléatoire
      //int number = rng.nextInt(balloonArray.length);
      int number = 0;
      _loadImage(balloonArray[number]);
      topBalloon = new Sprite(image);
    }

    j += balloonSpeed;

    if(pause)
      j -= balloonSpeed;

    c.translate( posX = game.screenSize.width - widthBalloon - j.toDouble(), 0);
    topBalloon.render(c, size: rectSize, position: rectPosition);

    //c.translate(-game.screenSize.width, 0);
    //topBalloon.render(c, size: rectSize, position: rectPosition);
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
