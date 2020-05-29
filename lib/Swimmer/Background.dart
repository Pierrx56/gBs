import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/box-game.dart';

Size screenSize;

class Background {
  final BoxGame game;
  Sprite bgSprite;
  Rect bgRect;

  Background(this.game) {
    bgSprite = Sprite('swimmer/background1.png');
    bgRect = Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height);
  }

  void render(Canvas c) {
    //bgSprite.render(c);
    bgSprite.renderRect(c, bgRect);
  }

  void update(double t) {}
}


class Close {
  final BoxGame game;
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

  void resize(Size size) {
    screenSize = size;
  }
}
