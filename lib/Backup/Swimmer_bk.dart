import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:flame/animation.dart' as flanim;
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';

var game;
var player;
const SPEED = 120.0;
const ComponentSize = 60.0;
GameWrapper myGame;
int i = 0;
int difficulte = 5;
List<Sprite> sprites = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23
].map((i) => new Sprite('swimmer/swim${i}.png')).toList();

String swimPic;
const List<String> tab = [
  'swimmer/swim0.png',
  'swimmer/swim1.png',
  'swimmer/swim2.png',
  'swimmer/swim3.png',
  'swimmer/swim4.png',
  'swimmer/swim5.png',
  'swimmer/swim6.png',
  'swimmer/swim7.png',
  'swimmer/swim8.png',
  'swimmer/swim9.png',
  'swimmer/swim10.png',
  'swimmer/swim11.png',
  'swimmer/swim12.png',
  'swimmer/swim13.png',
  'swimmer/swim14.png',
  'swimmer/swim15.png',
  'swimmer/swim16.png',
  'swimmer/swim17.png',
  'swimmer/swim18.png',
  'swimmer/swim19.png',
  'swimmer/swim20.png',
  'swimmer/swim21.png',
  'swimmer/swim22.png',
  'swimmer/swim23.png'
];

class Swimmer_bk extends StatefulWidget {
  @override
  _Swimmer_bk createState() => new _Swimmer_bk();
}

class _Swimmer_bk extends State<Swimmer_bk> {
  void initState(){
    //myGame = GameWrapper(game);
    initSwimmer();
    super.initState();
  }

  Future<MyGame> initSwimmer() async{
    var dimensions = await Flame.util.initialDimensions();
    return game = await MyGame(dimensions);
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

/*    window.onPointerDataPacket = (packet) {
      var pointer = packet.data.first;
      game.input(pointer.physicalX, pointer.physicalY);
    };*/
    //game = MyGame(dimensions);
    return MaterialApp(
        home: Scaffold(
      body: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/images/swimmer/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: GameWrapper(game),
      ),
    ));
  }
}

class GameWrapper extends StatelessWidget {
  MyGame game;

  GameWrapper(_game) {
    game = _game;
  }

  @override
  Widget build(BuildContext context) {
    return game.widget;
  }
}

Component component;

class MyGame extends BaseGame {
  Size dimensions;

  MyGame(Size _dimensions) {
    dimensions = _dimensions;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    player.x = dimensions.width / 2;
    player.render(canvas);

    /*String text = "Score: 0";
    TextSpan span =
        new TextSpan(style: new TextStyle(color: Colors.blue[800]), text: text);
    TextPainter textPainter = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    textPainter.paint(canvas, Offset(size.width / 4.5, size.height - 50));*/
  }

  double creationTimer = 0.0;
  double tempPos = 0;

  @override
  void update(double t) {
    creationTimer += t;
    //Timer
    if (creationTimer >= 0.04) {
      if (i == 23)
        i = 0;
      else
        i++;

      swimPic = tab[i];

      creationTimer = 0.0;

      Sprite sprite = Sprite(swimPic);

      const size = 100.0;
      //player = AnimationComponent(size, size, new flanim.Animation.spriteList(sprites, stepTime: 0.01));

      player = SpriteComponent.fromSprite(
          size, size, sprite); // width, height, sprite

      if (tempPos >= dimensions.height - size)
        player.y = tempPos;
      else {
        player.y += tempPos;
        tempPos = player.y + difficulte;
      }
      //component = new Component(dimensions);
      //add(component);
    }
    //Height: 360 Widht: 640

    //print("Pos Y: " + player.y.toString());

    super.update(t);
  }
}

class Component extends SpriteComponent {
  Size dimensions;

  Component(this.dimensions) : super.square(ComponentSize, '$swimPic');
  double maxY;
  bool remove = false;

  //Emplacement du nageur
  @override
  void update(double t) {
    //y += t * SPEED;
  }

  @override
  bool destroy() {
    return remove;
  }

  @override
  void resize(Size size) {
    this.x = size.width / 2;
    this.y = 0;
    this.maxY = size.height;
  }
}
