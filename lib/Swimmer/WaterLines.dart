import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/box-game.dart';

class WaterLine {

}

double linePosition = 0.1;
int j = 0;
int linesSpeed = 2;

class DownLine{
  final BoxGame game;
  Sprite downLine;
  Rect rectDown;

  DownLine(this.game) {
    downLine = Sprite('swimmer/down_line.png');
    //width: 500
    //height: 300

    rectDown = Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height*0.05);
  }

  void render(Canvas c) {
    //bgSprite.render(c);

    c.translate(game.screenSize.width/2, game.screenSize.height);
    c.translate(-game.screenSize.width/2, -game.screenSize.height*(linePosition));


    if(j >= game.screenSize.width)
      j = 0;

    c.translate(game.screenSize.width- j.toDouble(), 0);


    downLine.renderRect(c, rectDown);

    c.translate(-game.screenSize.width, 0);

    downLine.renderRect(c, rectDown);
    // restore original state
    c.restore();
  }


  void update(double t) {}

}

class UpLine {
  final BoxGame game;
  Sprite upLine;
  Rect rectUp;

  UpLine(this.game) {
    upLine = Sprite('swimmer/up_line.png');
    //width: 500
    //height: 300
    rectUp = Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height*0.05);
  }

  void render(Canvas c) {
    //bgSprite.render(c);

    c.translate(game.screenSize.width/2, game.screenSize.height);
    c.translate(-game.screenSize.width/2, -game.screenSize.height*(1-linePosition));


    if(j >= game.screenSize.width)
      j = 0;

    c.translate(game.screenSize.width- j.toDouble(), 0);
    j += linesSpeed;


    upLine.renderRect(c, rectUp);

    c.translate(-game.screenSize.width, 0);

    upLine.renderRect(c, rectUp);

    // restore original state
    c.restore();

  }

  void update(double t) {}

}
