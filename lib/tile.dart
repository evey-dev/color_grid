import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'tools/ValueListenableBuilder3.dart';
class Tile extends StatefulWidget {
  ValueNotifier<Color> userColor = ValueNotifier(Colors.transparent);
  ValueNotifier<Color> autoColor = ValueNotifier(Colors.transparent);
  ValueNotifier<bool> selected = ValueNotifier(false);
  final double size;
  bool dot = false;
  int index;
  final void Function(int) setSelected;
  final void Function(int, bool) addToUserTiles;


  Tile({required this.index, required this.size, required this.setSelected, required this.addToUserTiles, Key? key}) : super(key: key);

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.setSelected(widget.index);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: ValueListenableBuilder3<Color,Color, bool>(
            first: widget.userColor,
            second: widget.autoColor,
            third: widget.selected,
            builder: (BuildContext context, Color color1, Color color2, bool value, Widget? child) {
              if (color1 != Colors.transparent) {
                if (!widget.dot) widget.addToUserTiles(widget.index, true);
                widget.dot = true;
              } else {
                if (widget.dot) widget.addToUserTiles(widget.index, false);
                widget.dot = false;

              }
              return Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  depth: 6,
                  lightSource: LightSource.topLeft,
                  intensity: .5,
                  color: color1 == Colors.transparent ? color2 == Colors.transparent ? const Color(0xFFD3D8DB) : color2 : color1,
                  border: NeumorphicBorder(width:  value ? 2 : .5, color: Colors.black12),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  height: widget.size,
                  width: widget.size,
                  padding: const EdgeInsets.all(5),
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.all(Radius.circular(widget.size / 10)),
                  //   color: widget.color,
                  //   border: Border.all(color: Colors.black12),
                  // ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.circle,
                      size: 15,
                      color: widget.dot ? value ? Colors.black54 : Colors.black12 : Colors.transparent,
                    ),
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}
