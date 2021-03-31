import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Plane/Balloons.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';

class WaterLine {}

double balloonPosition = 0.30;
int j = 0;
int balloonSpeed = 2;

class BottomLine {
  final SwimGame game;
  Sprite bottomLine;
  Vector2 posWater;
  Vector2 sizeWater;

  void _loadImage() async {
      bottomLine = new Sprite(await Flame.images.load('ship/down_line.png'));
  }

  BottomLine(this.game) {
    _loadImage();
    //width: 500
    //height: 300

    posWater = Vector2(0, 0);
    sizeWater = Vector2(game.screenSize.width, game.screenSize.width* 0.1);

  }

  void render(Canvas c, bool pause) {

    c.translate(game.screenSize.width / 2, game.screenSize.height - sizeWater.y);
    c.translate(-game.screenSize.width / 2, 0);//-game.screenSize.height * (balloonPosition));

    if (j >= game.screenSize.width) j = 0;

    if(pause)
      j -= balloonSpeed;

    c.translate(game.screenSize.width - j.toDouble(), 0);

    bottomLine.render(c, position: posWater, size: sizeWater );

    c.translate(-game.screenSize.width, 0);

    bottomLine.render(c, position: posWater, size: sizeWater );
    // restore original state
    c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height *balloonPosition;
    return game.screenSize.height - sizeWater.y;
  }

  void update(double t) {}
}

class TopLine {
  final SwimGame game;
  Sprite topLine;
  Rect rectTop;
  Vector2 posWater;
  Vector2 sizeWater;

  void _loadImage() async {
    topLine = new Sprite(await Flame.images.load('ship/up_line.png'));
  }


  TopLine(this.game) {
    _loadImage();
    //width: 500
    //height: 300
    posWater = Vector2(0, 0);
    sizeWater = Vector2(game.screenSize.width, game.screenSize.width* 0.1);
  }

  void render(Canvas c) {

    c.translate(game.screenSize.width / 2, 0 );//game.screenSize.width* 0.1);
    c.translate(-game.screenSize.width / 2, 0);//-game.screenSize.height * (1 - balloonPosition));

    if (j >= game.screenSize.width) j = 0;

    c.translate(game.screenSize.width - j.toDouble(), 0);
    j += balloonSpeed;

    topLine.render(c, position: posWater, size: sizeWater);

    c.translate(-game.screenSize.width, 0);

    topLine.render(c, position: posWater, size: sizeWater);

    // restore original state
    c.restore();
  }

  double getUpPosition() {
    return game.screenSize.height * (1 - balloonPosition);
  }

  void update(double t) {}
}
