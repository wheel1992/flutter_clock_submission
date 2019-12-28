import 'dart:async';
import 'dart:math';
import 'package:after_layout/after_layout.dart';
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

final _assetFlareWeatherIconsPath = 'assets/animations/Weather_Flat_Icons.flr';

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

final _darkThemeOverlayGradients = [
  Color(0x8A000000),
  Color(0x54000000),
  Color(0x8A000000),
];

final _defaultFontFamily = 'VarelaRoundRegular';

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Color(0x66000000),
};

final _lightThemeOverlayGradients = [
  Color(0x44000000),
  Color(0x1F000000),
  Color(0x44000000),
];

final Map _weather = {
  'cloudy': '03d',
  'cloudy_night': '03n',
  'foggy': '50d',
  'foggy_night': '50n',
  'night': '01n',
  'rainy': '09d',
  'rainy_night': '09n',
  'snowy': '13d',
  'snowy_night': '13n',
  'sunny': '01d',
  'thunderstorm': '11d_rain',
  'thunderstorm_night': '11n_rain',
  'windy': 'wind',
  'windy_night': 'wind',
};

final _weatherIconSize = 36.0;

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with AfterLayoutMixin<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  double _screenHeight = 10.0;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
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
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
                child: _TimeBackground(
              hour: int.parse(_hourIn24Format),
            )),
            onBottom(_AnimatedWave(
              height: waveHeightByTime,
              speed: 1.0,
            )),
            onBottom(_AnimatedWave(
              height: waveHeightByTime * 0.8,
              speed: 0.9,
              offset: pi,
            )),
            onBottom(_AnimatedWave(
              height: waveHeightByTime * 0.6,
              speed: 0.8,
              offset: pi / 2,
            )),
            Positioned.fill(
                child: _buildBackgroundColorOverlay(
              height: 480, // constraints.maxHeight,
              width: 800, // constraints.maxWidth,
            )),
            Positioned.fill(
                child: _buildContent(
              height: 480, // constraints.maxHeight,
              width: 800, // constraints.maxWidth,
            )),
          ],
        );
      },
    );
  }

  Widget _buildContent({double width, double height}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      child: Column(
        children: <Widget>[
          _buildBarTemperature(),
          _buildTime(
            hour: _hour,
            minute: _minute,
            meridiem: _meridiem,
          ),
          _buildLocation(),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
      ),
      height: height,
      width: width,
    );
  }

  Widget _buildBackgroundColorOverlay({double width, double height}) {
    return AnimatedContainer(
      curve: Curves.easeInOutSine,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isLightTheme
              ? _lightThemeOverlayGradients
              : _darkThemeOverlayGradients,
        ),
      ),
      duration: Duration(seconds: 1),
      height: height,
      width: width,
    );
  }

  Widget _buildBarTemperature() {
    return Container(
      child: Row(
        children: <Widget>[
          _buildWeatherAndTemperature(),
          _buildLowHighTemperature(),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
      ),
    );
  }

  Widget _buildWeatherAndTemperature() {
    return Container(
      child: Row(
        children: <Widget>[
          _buildWeatherIcon(),
          _buildCurrentTemperature(),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
      ),
    );
  }

  Widget _buildWeatherIcon() {
    return Container(
      height: _weatherIconSize,
      width: _weatherIconSize,
      child: FlareCacheBuilder(
        [_assetFlareWeatherIconsPath],
        builder: (BuildContext context, bool isWarm) {
          return !isWarm
              ? Container()
              : FlareActor(
                  _assetFlareWeatherIconsPath,
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: flareAnimationName,
                );
        },
      ),
    );
  }

  Widget _buildCurrentTemperature() {
    return Container(
      child: _buildTemperatureText(temperature: widget.model.temperature),
    );
  }

  Widget _buildLowHighTemperature() {
    return Container(
      child: Row(
        children: <Widget>[
          _buildTemperatureText(temperature: widget.model.low),
          Text(
            '  |  ',
            style: _defaultTextStyle.copyWith(
              fontSize: 12.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          _buildTemperatureText(temperature: widget.model.high),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
      ),
    );
  }

  Widget _buildTemperatureText({num temperature}) {
    return Container(
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '$temperature',
              style: _defaultTextStyle.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: ' ${widget.model.unitString}',
              style: _defaultTextStyle.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      alignment: Alignment.center,
      child: DefaultTextStyle(
        child: Text(
          widget.model.location,
          maxLines: 1,
          overflow: TextOverflow.clip,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
        style: _defaultTextStyle.copyWith(
            fontSize: 18.0, fontWeight: FontWeight.w200),
      ),
    );
  }

  Widget get _buildSingleDot {
    return Container(
      height: 15.0,
      alignment: Alignment.center,
      child: Center(
        child: RawMaterialButton(
          constraints: BoxConstraints.tight(Size(15.0, 15.0)),
          onPressed: () {},
          shape: CircleBorder(),
          elevation: 1.0,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget get _buildColonMark {
    return Container(
      child: Column(
        children: <Widget>[
          _buildSingleDot,
          const SizedBox(
            height: 16.0,
          ),
          _buildSingleDot,
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.0),
    );
  }

  Widget _buildTime(
      {@required String hour,
      @required String minute,
      @required String meridiem}) {
    List<Widget> _numbers = [
      DefaultTextStyle(
        style: _timeTextStyle,
        child: Text('$hour'),
      ),
      _buildColonMark,
      DefaultTextStyle(
        style: _timeTextStyle,
        child: Text('$minute'),
      ),
    ];

    Widget _numberGroup = Row(
      children: _numbers,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
    );

    List<Widget> _groups = [_numberGroup];

    if (meridiem != null && meridiem != '') {
      _groups.addAll([
        Container(
          child: DefaultTextStyle(
            style: _meridiemTextStyle,
            child: Text('${meridiem ?? ""}'),
          ),
          padding: EdgeInsets.only(bottom: 18.0),
        )
      ]);
    }

    return Container(
      child: IntrinsicHeight(
        child: Row(
          children: _groups,
          crossAxisAlignment: CrossAxisAlignment.end,
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
        fontWeight: FontWeight.w400,
        shadows: [
          Shadow(
            blurRadius: 1.5,
            color: _colors[_Element.shadow],
            offset: Offset(0, 1.5),
          ),
        ],
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

  TextStyle get _timeTextStyle => _defaultTextStyle.copyWith(
        fontSize: 100.0,
        fontWeight: FontWeight.w500,
      );

  TextStyle get _meridiemTextStyle => _defaultTextStyle.copyWith(
        fontSize: 30.0,
      );

  Map<_Element, Color> get _colors => _isLightTheme ? _lightTheme : _darkTheme;

  String get _hour =>
      DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);

  String get _hourIn24Format => DateFormat('HH').format(_dateTime);

  bool get _isDay {
    final _hour = int.parse(DateFormat('HH').format(_dateTime));
    return _hour >= 6 && _hour <= 18;
  }

  bool get _isLightTheme => Theme.of(context).brightness == Brightness.light;

  String get _minute => DateFormat('mm').format(_dateTime);

  String get _meridiem =>
      widget.model.is24HourFormat ? null : DateFormat('a').format(_dateTime);

  double get waveHeightByTime {
    int _hr = int.parse(_hourIn24Format);
    int _min = int.parse(_minute);
    int _currentMin = ((_hr * 60) + _min);
    if (_hr == 0 && _min == 0) return _screenHeight;

    if (_currentMin < 60) return _screenHeight * (60.0 / 1440.0);

    return _screenHeight * (_currentMin / 1440.0);
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
          colors: [Color(_colorShifts[hour][0]), Color(_colorShifts[hour][1])],
        ),
      ),
      duration: Duration(seconds: 1),
    );
  }
}
