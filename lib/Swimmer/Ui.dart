import 'dart:ui';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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

class UI extends StatefulWidget {
  final UIState state = UIState();

  State<StatefulWidget> createState() => state;
}

class UIState extends State<UI> with WidgetsBindingObserver{

  UIScreen currentScreen = UIScreen.home;
  BoxGame game;


  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  Widget scoreDisplay() {
    return Text(
      "22",
      style: TextStyle(
        fontSize: 150,
        color: Color(0x88000000),
        shadows: <Shadow>[
          Shadow(
            color: Color(0x88000000),
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget creditsButton() {
    return Ink(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
      ),
      child: IconButton(
        color: Colors.white,
        icon: Icon(
          Icons.nature_people,
        ),
        onPressed: currentScreen == UIScreen.playing
            ? null
            : () {
          currentScreen = currentScreen == UIScreen.credits ? UIScreen.home : UIScreen.credits;
          update();
        },
      ),
    );
  }

  Widget buildScreenPlaying() {
    return Positioned.fill(
      child: Column(
        children: <Widget>[
          scoreDisplay(),
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Row(
              children: <Widget>[
               /* GestureDetector(
                  //onTapDown: (TapDownDetails d) => game.boxer.punchLeft(),
                  behavior: HitTestBehavior.opaque,
                  child: LeftPunch(),
                ),
                GestureDetector(
                  onTapDown: (TapDownDetails d) => game.boxer.upperCut(),
                  behavior: HitTestBehavior.opaque,
                  child: Uppercut(),
                ),
                GestureDetector(
                  onTapDown: (TapDownDetails d) => game.boxer.punchRight(),
                  behavior: HitTestBehavior.opaque,
                  child: RightPunch(),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        Expanded(
          child: IndexedStack(
            sizing: StackFit.expand,
            children: <Widget>[
              buildScreenPlaying(),
              //scoreDisplay(),
              //creditsButton(),
            ],
            index: currentScreen.index,
          ),
        )
      ],
    );

    //throw UnimplementedError();
  }



}

class Close{
  final BoxGame game;
  Sprite spriteClose;
  Rect RectClose;
  bool inTouch;

  Close(this.game) {
    spriteClose = Sprite('swimmer/close.png');
    //width: 500
    //height: 300
    RectClose = Rect.fromLTWH(0, 0, game.screenSize.height*0.1, game.screenSize.height*0.1);
  }

  void render(Canvas c) {
    spriteClose.renderRect(c, RectClose);
  }

  void update(double t) {}

  void resize(Size size) {
    screenSize = size;
  }


}


enum UIScreen {
  home,
  playing,
  lost,
  help,
  credits,
}