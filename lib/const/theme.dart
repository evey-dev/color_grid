import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'color.dart';
NeumorphicStyle titleTextStyle = NeumorphicStyle(
  shape: NeumorphicShape.flat,
  boxShape:
  NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
  depth: 2.5,
  lightSource: LightSource.topLeft,
  intensity: 1,
  color: backgroundColor,
);

NeumorphicStyle textStyle = NeumorphicStyle(
  shape: NeumorphicShape.flat,
  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
  depth: 2,
  lightSource: LightSource.topLeft,
  intensity: 1,
  color: Colors.black54,
);

NeumorphicStyle textFieldStyle = NeumorphicStyle(
  shape: NeumorphicShape.concave,
  boxShape:
  NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
  depth: -4,
  lightSource: LightSource.topLeft,
  intensity: 1,
);

InputDecoration textFieldDecoration = const InputDecoration(
  contentPadding: EdgeInsets.all(10),
  border: InputBorder.none,
  labelStyle: TextStyle(color: Colors.black),
);

NeumorphicStyle containerStyle = NeumorphicStyle(
  shape: NeumorphicShape.flat,
  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
  depth: 6,
  lightSource: LightSource.topLeft,
  intensity: .5,
  color: backgroundColor,
  border: const NeumorphicBorder(color: Colors.black12),
);

NeumorphicStyle buttonStyle = NeumorphicStyle(
  shape: NeumorphicShape.flat,
  depth: 2,
  boxShape: NeumorphicBoxShape.roundRect(
      BorderRadius.circular(10)),
  color: backgroundColor,
);

NeumorphicStyle circleButtonStyle = NeumorphicStyle(
  shape: NeumorphicShape.flat,
  depth: 2,
  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
  color: backgroundColor,
);

TextStyle defaultTextStyle = const TextStyle(color: mainTextColor);
TextStyle linkTextStyle = const TextStyle(color: Colors.blue);