import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';

class Background {
  final PlaneGame game;
  Sprite bgSprite;
  Rect bgRect;

  double j = 0;
  double backgroundSpeed = 0.5;

  Background(this.game) {
    bgSprite = Sprite('plane/background.png');
    bgRect = Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height);
  }

  void render(Canvas c, bool pause) {
    //bgSprite.render(c);
    bgSprite.renderRect(c, bgRect);



    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(
        -game.screenSize.width / 2, -game.screenSize.height);

    if (j >= game.screenSize.width) j = 0;

    j += backgroundSpeed;

    if(pause)
      j -= backgroundSpeed;

    c.translate(game.screenSize.width - j.toDouble(), 0);

    bgSprite.renderRect(c, bgRect);

    c.translate(-game.screenSize.width, 0);

    bgSprite.renderRect(c, bgRect);
    // restore original state
    c.restore();
  }

  void update(double t) {}
  }

