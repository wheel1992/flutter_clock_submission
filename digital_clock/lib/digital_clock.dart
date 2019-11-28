// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_cache_builder.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_animations/simple_animations.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.black,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  final _defaultFontFamily = 'Monda';
  
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).brightness == Brightness.light
    //     ? _lightTheme
    //     : _darkTheme;
    // final hour =
    //     DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    // final minute = DateFormat('mm').format(_dateTime);
    // final fontSize = MediaQuery.of(context).size.width / 3.5;
    // final offset = -fontSize / 7;
    // final defaultStyle = TextStyle(
    //   color: colors[_Element.text],
    //   fontFamily: 'PressStart2P',
    //   fontSize: fontSize,
    //   shadows: [
    //     Shadow(
    //       blurRadius: 0,
    //       color: colors[_Element.shadow],
    //       offset: Offset(10, 0),
    //     ),
    //   ],
    // );

    return Stack(
      children: <Widget>[
        Positioned.fill(child: _AnimatedBackground()),
        onBottom(_AnimatedWave(
          height: 100,
          speed: 1.0,
        )),
        onBottom(_AnimatedWave(
          height: 80,
          speed: 0.9,
          offset: pi,
        )),
        onBottom(_AnimatedWave(
          height: 120,
          speed: 1.0,
          offset: pi / 2,
        )),
        Positioned.fill(child: _buildContent()),
      ],
    );
    // return Container(
    //   color: colors[_Element.background],
    //   child: Center(
    //     child: _buildTime(
    //       hour: hour,
    //       minute: minute,
    //     )
    //     // child: DefaultTextStyle(
    //     //   style: defaultStyle,
    //     //   child: Stack(
    //     //     children: <Widget>[
    //     //       Positioned(left: offset, top: 0, child: Text(hour)),
    //     //       Positioned(right: offset, bottom: offset, child: Text(minute)),
    //     //     ],
    //     //   ),
    //     // ),
    //     // child: FlareCacheBuilder(
    //     //   ["assets/Weather_Flat_Icons.flr"],
    //     //   builder: (BuildContext context, bool isWarm) {
    //     //     return !isWarm
    //     //         ? Container(child:Text("NO"))
    //     //         : FlareActor(
    //     //             "assets/Weather_Flat_Icons.flr",
    //     //             alignment: Alignment.center,
    //     //             fit: BoxFit.contain,
    //     //             animation: '13d',
    //     //           );
    //     //   },
    //     // ),
    //   ),
    // );
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      child: Column(
        children: <Widget>[
          _buildRowTop(),
          _buildRowCenter(),
          _buildRowBottom(),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
      ),
    );
  }

  Widget _buildRowBottom() {
    return Column(
      children: <Widget>[
        // Text(
        //   widget.model.weatherString,
        // ),
        Container(
          height: 60,
          child: FlareCacheBuilder(
            ["assets/Weather_Flat_Icons.flr"],
            builder: (BuildContext context, bool isWarm) {
              return !isWarm
                ? Container(child:Text("NO"))
                : FlareActor(
                  "assets/Weather_Flat_Icons.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: '13d',
                );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRowCenter() {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final meridiem = DateFormat('a').format(_dateTime);

    return Container(
      child: _buildTime(
        hour: hour,
        minute: minute,
        meridiem: widget.model.is24HourFormat ? null : meridiem,
      ),
    );
  }

  Widget _buildRowTop() {
    return LayoutBuilder(
      builder: (context, contraints) {
        return Row(
          children: <Widget>[
            Container(
              width: contraints.maxWidth / 1.5,
              child: DefaultTextStyle(
                style: _defaultTextStyle,
                child: Text(
                  widget.model.location,
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
            ),
            Container(
              child: DefaultTextStyle(
                style: _defaultTextStyle,
                child: Text(
                  widget.model.temperatureString
                ),
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
        );
      },
    );
    
  }

  Widget _buildTime({ @required String hour, @required String minute, @required String meridiem }) {
    return Container(
      child: Center(
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            DefaultTextStyle(
              style: _timeTextStyle,
              child: Text(
                '$hour : $minute' 
              ),
            ),
            const SizedBox(
              width: 16.0,
            ),
            DefaultTextStyle(
              style: _meridiemTextStyle,
              child: Text(
                '${meridiem ?? ""}' 
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
        ),
      ),
    );
    
  }

  onBottom(Widget child) => Positioned.fill(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: child,
    ),
  );

  TextStyle get _defaultTextStyle {
    return TextStyle(
      color: _colors[_Element.text],
      fontFamily: _defaultFontFamily,
      fontSize: 16.0,
      // shadows: [
      //   Shadow(
      //     blurRadius: 0,
      //     color: _colors[_Element.shadow],
      //     offset: Offset(10, 0),
      //   ),
      // ],
    );
  }

  TextStyle get _timeTextStyle {
    return TextStyle(
      color: _colors[_Element.text],
      fontFamily: _defaultFontFamily,
      fontSize: 50.0,
      // shadows: [
      //   Shadow(
      //     blurRadius: 0,
      //     color: _colors[_Element.shadow],
      //     offset: Offset(10, 0),
      //   ),
      // ],
    );
  }

  TextStyle get _meridiemTextStyle {
    return TextStyle(
      color: _colors[_Element.text],
      fontFamily: _defaultFontFamily,
      fontSize: 30.0,
    );
  }

  Map<_Element, Color> get _colors {
    return Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
  }

  double get _fontSize {
    return MediaQuery.of(context).size.width / 3.5;
  }
}

class _AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffA83279), end: Colors.blue.shade600))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

class _AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  _AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
          playback: Playback.LOOP,
          duration: Duration(milliseconds: (5000 / speed).round()),
          tween: Tween(begin: 0.0, end: 2 * pi),
          builder: (context, value) {
            return CustomPaint(
              foregroundPainter: _CurvePainter(value + offset),
            );
          }),
      );
    });
  }
}

class _CurvePainter extends CustomPainter {
  final double value;

  _CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
