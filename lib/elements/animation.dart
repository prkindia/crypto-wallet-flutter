import 'dart:math';

import 'package:bitsbull_app/elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as Vector;
// import 'package:vector_math/vector_math_64.dart';

class waveBody extends StatefulWidget {
  final Size size;
  final int xOffset;
  final int yOffset;
  final Color color;
  String totalValue;

  waveBody(
      {Key key, @required this.size, this.totalValue, this.xOffset, this.yOffset, this.color})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _waveBodyState();
  }
}

class _waveBodyState extends State<waveBody> with TickerProviderStateMixin {
  AnimationController animationController;
  List<Offset> animList1 = [];

  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));

    animationController.addListener(() {
      animList1.clear();
      for (int i = -2 - widget.xOffset;
      i <= widget.size.width.toInt() + 2;
      i++) {
        animList1.add(new Offset(
            i.toDouble() + widget.xOffset,
            sin((animationController.value * 360 - i) %
                360 *
                Vector.degrees2Radians) *
                20 +
                50 +
                widget.yOffset));
      }
    });
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 185.0,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  tileMode: TileMode.repeated,
                  colors: [Color.fromRGBO(78, 2, 251, 1), Color.fromRGBO(94,47,199, 1)])),
          child: new Container(
            margin: EdgeInsets.only(top: 75.0),
            height: 20.0,
            child: new AnimatedBuilder(
              animation: new CurvedAnimation(
                parent: animationController,
                curve: Curves.easeInOut,
              ),
              builder: (context, child) => new ClipPath(
                child: widget.color == null
                    ? new Container(
                  width: widget.size.width,
                  height: widget.size.height,
                  color: Colors.white.withOpacity(0.25),
                )
                    : new Container(
                  width: widget.size.width,
                  height: widget.size.height,
                  color: Colors.white.withOpacity(0.9),
                ),
                clipper:
                new WaveClipper(animationController.value, animList1),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 180.0),
          height: 5.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: <Color>[
                  Color.fromRGBO(78, 2, 251, 1), Color.fromRGBO(94,47,199, 1)
                ],
                stops: [
                  0.0,
                  1.0
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(0.0, 1.0)),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 70.0),
          alignment: Alignment.topCenter,
          child: Column(children: <Widget>[
            RobText(
              "PORTFOLIO",
              style: TextStyle(
                color:Colors.white70,
                fontSize: 20.0,
                fontWeight: FontWeight.w500
              )
            ),
            SizedBox(
              height: 5.0,
            ),
            RobText(
              "TOTAL HOLDINGS",
              style: TextStyle(
                color:Colors.white70,
                fontSize: 24.0,
                  fontWeight: FontWeight.w400
              )
            ),
            SizedBox(
              height:5.0,
            ),
            RobText(
              "\$ "+widget.totalValue,
              style: TextStyle(
                color:Colors.white70,
                fontSize: 28.0,
                fontWeight: FontWeight.w600
              )
            ),
          ]),
        )
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  List<Offset> waveList1 = [];

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.addPolygon(waveList1, false);

    path.lineTo(size.width, size.height);
    path.lineTo(5.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}
