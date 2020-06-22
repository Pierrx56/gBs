import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';

Size screenSize;

class Background {
  final PlaneGame game;
  Sprite bgSprite;
  Rect bgRect;

  Background(this.game) {
    bgSprite = Sprite('plane/background.png');
    bgRect = Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height);
  }

  void render(Canvas c) {
    //bgSprite.render(c);
    bgSprite.renderRect(c, bgRect);
  }

  void update(double t) {}
}
