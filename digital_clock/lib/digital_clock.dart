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

final Map _weather = {
  'cloudy': '03d',
  'cloudy_night': '02n',
  'foggy': '50d',
  'foggy_night': '50d',
  'night': '01n',
  'rainy': '09d',
  'rainy_night': '10n',
  'snowy': '13d',
  'snowy_night': '13d',
  'sunny': '01d',
  'thunderstorm': '11d_rain',
  'thunderstorm_night': '11d_rain',
  'windy': 'wind',
  'windy_night': 'wind',
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
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
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
        // Positioned.fill(child: _AnimatedBackground()),
        Positioned.fill(child: _TimeBackground(
          hour: int.parse(_hour),
        )),
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
        Positioned.fill(child: _buildBackgroundColorOverlay()),
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

  Widget _buildBackgroundColorOverlay() {
    return AnimatedContainer(
      curve: Curves.easeInOutSine,
      decoration: BoxDecoration(
        color: _isLightTheme ? Colors.transparent : Colors.black54,
      ),
      duration: Duration(seconds: 1),
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
                  animation: flareAnimationName,
                );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRowCenter() {
    return Container(
      child: _buildTime(
        hour: _hour,
        minute: _minute,
        meridiem: _meridiem,
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

  TextStyle get _defaultTextStyle => TextStyle(
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

  String get flareAnimationName {
    var _key = '${widget.model.weatherString}';
    if (!_isDay) {
      if (widget.model.weatherCondition == WeatherCondition.sunny)
        _key = 'night';
      else
        _key += '_night';
    }
    return _weather[_key];
  }

  TextStyle get _timeTextStyle => TextStyle(
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

  TextStyle get _meridiemTextStyle => TextStyle(
    color: _colors[_Element.text],
    fontFamily: _defaultFontFamily,
    fontSize: 30.0,
  );

  Map<_Element, Color> get _colors => _isLightTheme ? _lightTheme : _darkTheme;

  double get _fontSize => MediaQuery.of(context).size.width / 3.5;

  String get _hour => DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);

  bool get _isDay {
    final _hour = int.parse(DateFormat('HH').format(_dateTime));
    return _hour >= 6 && _hour <= 18;
  }

  bool get _isLightTheme => Theme.of(context).brightness == Brightness.light;

  String get _minute => DateFormat('mm').format(_dateTime);

  String get _meridiem => widget.model.is24HourFormat ? null : DateFormat('a').format(_dateTime);
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


class _TimeBackground extends StatelessWidget {
  final int hour;
  final List<List<int>> _colorShifts = [
    [0xff012459, 0xff001322],
    [0xff003972, 0xff001322],
    [0xff003972, 0xff001322],
    [0xff004372, 0xff00182B],
    [0xff004372, 0xff011D34],
    [0xff016792, 0xff00182B],
    [0xff07729F, 0xff042C47],
    [0xff12A1C0, 0xff07506E],
    [0xff74D4CC, 0xff1386A6],
    [0xffEFEEBC, 0xff61D0CF],
    [0xfffee154, 0xffa3dec6],
    [0xfffdc352, 0xffe8ed92],
    [0xffffac6f, 0xffffe467],
    [0xfffda65a, 0xffffe467],
    [0xfffd9e58, 0xffffe467],
    [0xfff18448, 0xffffd364],
    [0xfff06b7e, 0xfff9a856],
    [0xffca5a92, 0xfff4896b],
    [0xff5b2c83, 0xffd1628b],
    [0xff371a79, 0xff713684],
    [0xff28166b, 0xff45217c],
    [0xff192861, 0xff372074],
    [0xff040b3c, 0xff233072],
    [0xff040b3c, 0xff012459],
  ];

  _TimeBackground({
    Key key,
    this.hour: 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.easeInOutSine,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(_colorShifts[hour][0]),
            Color(_colorShifts[hour][1])
          ],
        ),
      ),
      duration: Duration(seconds: 1),
    );
  }
}