import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'value_listenable_builder_3.dart';
import 'package:color_grid/const/color.dart';

class FakeTile extends StatefulWidget {
  ValueNotifier<Color> userColor = ValueNotifier(Colors.transparent);
  ValueNotifier<Color> autoColor = ValueNotifier(Colors.transparent);
  ValueNotifier<bool> selected = ValueNotifier(false);
  int index;
  final void Function(int) setSelected;
  final void Function(int, bool) addToUserTiles;

  FakeTile({required this.index, required this.setSelected, required this.addToUserTiles, Key? key}) : super(key: key);

  @override
  _FakeTileState createState() => _FakeTileState();
}

class _FakeTileState extends State<FakeTile> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: ValueListenableBuilder3<Color,Color, bool>(
        first: widget.userColor,
        second: widget.autoColor,
        third: widget.selected,
        builder: (BuildContext context, Color color1, Color color2, bool value, Widget? child) {
          return Neumorphic(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              depth: 6,
              lightSource: LightSource.topLeft,
              intensity: .5,
              color: color1 == Colors.transparent ? color2 == Colors.transparent ? backgroundColor : color2 : color1,
              border: NeumorphicBorder(width:  value ? 2 : .5, color: Colors.black12),
            ),
            padding: const EdgeInsets.all(2),
          );
        }
      ),
    );
  }
}
