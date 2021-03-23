import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/CarGame/CarGame.dart';

class Background {
  final CarGame game;
  Sprite bgSprite;
  Vector2 bgSize;
  Vector2 bgPosition;

  double j = 0;
  double backgroundSpeed = 1;

  var image;

  _loadImage() async{
    image = await Flame.images.load('car/background.png');
    bgSprite = Sprite(image);
  }

  Background(this.game) {
    _loadImage();
    bgSize = Vector2( game.screenSize.width, game.screenSize.height);
    bgPosition = Vector2(0,0);
  }

  void render(Canvas c, bool pause) {
    //bgSprite.render(c);
    bgSprite.render(c,position: bgPosition, size: bgSize);



    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(
        -game.screenSize.width / 2, -game.screenSize.height);

    if (j >= game.screenSize.width) j = 0;

    j += backgroundSpeed;

    if(pause)
      j -= backgroundSpeed;

    c.translate(game.screenSize.width - j.toDouble(), 0);

    bgSprite.render(c,position: bgPosition, size: bgSize);

    c.translate(-game.screenSize.width, 0);

    bgSprite.render(c,position: bgPosition, size: bgSize);
    // restore original state
    c.restore();
  }

  void update(double t) {}
  }

