import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';

class Background {
  final SwimGame game;
  Sprite bgSprite;
  Vector2 bgSize;
  Vector2 bgPosition;

  var image;

  _loadImage() async{
    image = await Flame.images.load('ship/background.png');
    bgSprite = Sprite(image);
  }

  Background(this.game) {
    _loadImage();
    bgSize = Vector2( game.screenSize.width, game.screenSize.height);
    bgPosition = Vector2(0,0);
  }

  void render(Canvas c) {
    bgSprite.render(c,position: bgPosition, size: bgSize);
  }

  void update(double t) {}
}
