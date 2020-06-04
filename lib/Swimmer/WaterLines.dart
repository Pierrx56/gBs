import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/box-game.dart';

class WaterLine {}

double linePosition = 0.1;
int j = 0;
int linesSpeed = 2;

class BottomLine {
  final BoxGame game;
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
    //bgSprite.render(c);

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(
        -game.screenSize.width / 2, -game.screenSize.height * (linePosition));

    if (j >= game.screenSize.width) j = 0;

    if(pause)
      j -= linesSpeed;

    c.translate(game.screenSize.width - j.toDouble(), 0);

    bottomLine.renderRect(c, rectBottom);

    c.translate(-game.screenSize.width, 0);

    bottomLine.renderRect(c, rectBottom);
    // restore original state
    c.restore();
  }

  double getDownPosition() {
    return game.screenSize.height * (linePosition);
  }

  void update(double t) {}
}

class TopLine {
  final BoxGame game;
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
    //bgSprite.render(c);

    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(-game.screenSize.width / 2,
        -game.screenSize.height * (1 - linePosition));

    if (j >= game.screenSize.width) j = 0;

    c.translate(game.screenSize.width - j.toDouble(), 0);
    j += linesSpeed;

    topLine.renderRect(c, rectTop);

    c.translate(-game.screenSize.width, 0);

    topLine.renderRect(c, rectTop);

    // restore original state
    c.restore();
  }

  double getUpPosition() {
    return game.screenSize.height * (1 - linePosition);
  }

  void update(double t) {}
}
