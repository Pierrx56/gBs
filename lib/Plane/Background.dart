import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';

class Background {
  final PlaneGame game;
  Sprite bgSprite;
  Vector2 bgSize;
  Vector2 bgPosition;

  double j = 0;
  double backgroundSpeed = 0.5;

  //Image(image: 'plane/background.png',)

  var image;

  _loadImage() async{
    image = await Flame.images.load('plane/background.png');
    bgSprite = Sprite(image);
  }

  Background(this.game) {
    _loadImage();
    bgSize = Vector2( game.screenSize.width, game.screenSize.height);
    bgPosition = Vector2(0,0);
  }

  void render(Canvas c, bool pause) {
    //bgSprite.render(c);

    bgSprite?.render(c,position: bgPosition, size: bgSize);



    c.translate(game.screenSize.width / 2, game.screenSize.height);
    c.translate(
        -game.screenSize.width / 2, -game.screenSize.height);

    if (j >= game.screenSize.width) j = 0;

    j += backgroundSpeed;

    if(pause)
      j -= backgroundSpeed;

    c.translate(game.screenSize.width - j.toDouble(), 0);

    bgSprite?.render(c,size: bgSize);

    c.translate(-game.screenSize.width, 0);

    bgSprite?.render(c, size: bgSize);
    // restore original state
    c.restore();
  }

  void update(double t) {}
  }

