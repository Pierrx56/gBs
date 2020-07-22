import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';

class Background {
  final SwimGame game;
  Sprite bgSprite;
  Rect bgRect;

  Background(this.game) {
    bgSprite = Sprite('swimmer/background.png');
    bgRect = Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height);
  }

  void render(Canvas c) {
    bgSprite.renderRect(c, bgRect);
  }

  void update(double t) {}
}


class Close {
  final SwimGame game;
  Sprite spriteClose;
  Rect RectClose;
  bool inTouch;

  Close(this.game) {
    spriteClose = Sprite('swimmer/close.png');
    //width: 500
    //height: 300
    RectClose = Rect.fromLTWH(
        0, 0, game.screenSize.height * 0.1, game.screenSize.height * 0.1);
  }

  void render(Canvas c) {
    spriteClose.renderRect(c, RectClose);
  }

  void update(double t) {}

}
