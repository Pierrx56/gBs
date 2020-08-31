import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';
import 'package:gbsalternative/TempGame/TempGame.dart';

class WaterLine {}

double balloonPosition = 0.1;
int j = 0;
int balloonSpeed = 2;

class BottomLine {
  final TempGame game;
  Sprite bottomLine;
  Rect rectBottom;

  BottomLine(this.game) {
    bottomLine = Sprite('swimmer/down_line.png');
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

    bottomLine.renderRect(c, rectBottom);

    c.translate(-game.screenSize.width, 0);

    bottomLine.renderRect(c, rectBottom);
    // restore original state
    c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (balloonPosition);
  }

  void update(double t) {}
}

class TopLine {
  final TempGame game;
  Sprite topLine;
  Rect rectTop;

  TopLine(this.game) {
    topLine = Sprite('swimmer/up_line.png');
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

    topLine.renderRect(c, rectTop);

    c.translate(-game.screenSize.width, 0);

    topLine.renderRect(c, rectTop);

    // restore original state
    c.restore();
  }

  double getUpPosition() {
    return game.screenSize.height * (1 - balloonPosition);
  }

  void update(double t) {}
}
