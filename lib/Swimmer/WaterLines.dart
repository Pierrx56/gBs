import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';

class WaterLine {}

double balloonPosition = 0.1;
int j = 0;
int balloonSpeed = 2;

class BottomBalloon {
  final SwimGame game;
  Sprite bottomBalloon;
  Rect rectBottom;

  BottomBalloon(this.game) {
    bottomBalloon = Sprite('swimmer/down_line.png');
    //width: 500
    //height: 300

    rectBottom = Rect.fromLTWH(
        0, 0, game.screenSize.width, game.screenSize.height * 0.05);
  }

  void render(Canvas c, bool pause) {

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(
        -game.screenSize.width / 2, -game.screenSize.height * (balloonPosition));

    if (j >= game.screenSize.width) j = 0;

    if(pause)
      j -= balloonSpeed;

    c.translate(game.screenSize.width - j.toDouble(), 0);

    bottomBalloon.renderRect(c, rectBottom);

    c.translate(-game.screenSize.width, 0);

    bottomBalloon.renderRect(c, rectBottom);
    // restore original state
    c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void update(double t) {}
}

class TopBalloon {
  final SwimGame game;
  Sprite topBalloon;
  Rect rectTop;

  TopBalloon(this.game) {
    topBalloon = Sprite('swimmer/up_line.png');
    //width: 500
    //height: 300
    rectTop = Rect.fromLTWH(
        0, 0, game.screenSize.width, game.screenSize.height * 0.05);
  }

  void render(Canvas c) {

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(-game.screenSize.width / 2,
        -game.screenSize.height * (1 - balloonPosition));

    if (j >= game.screenSize.width) j = 0;

    c.translate(game.screenSize.width - j.toDouble(), 0);
    j += balloonSpeed;

    topBalloon.renderRect(c, rectTop);

    c.translate(-game.screenSize.width, 0);

    topBalloon.renderRect(c, rectTop);

    // restore original state
    c.restore();
  }

  double getUpPosition() {
    return game.screenSize.height * (1 - balloonPosition);
  }

  void update(double t) {}
}
