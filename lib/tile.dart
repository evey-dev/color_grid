import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'tools/ValueListenableBuilder2.dart';
class Tile extends StatefulWidget {
  ValueNotifier<Color> color = ValueNotifier(Colors.transparent);
  ValueNotifier<bool> selected = ValueNotifier(false);
  final double size;
  bool dot = false;
  int index;
  final void Function(int) callback;

  Tile({required this.index, required this.size, required this.callback, Key? key}) : super(key: key);

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // widget.dot = true;
        widget.callback(widget.index);
        setState(() {
        });
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: ValueListenableBuilder2<Color,bool>(
          first: widget.color,
          second: widget.selected,
          builder: (BuildContext context, Color val1, bool val2, Widget? child) {
            if (val1 != Colors.transparent) widget.dot = true;
            return Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                depth: 6,
                lightSource: LightSource.topLeft,
                intensity: .5,
                color: val1,
                border: NeumorphicBorder(width:  val2 ? 2 : .5, color: Colors.black12),
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
                    color: widget.dot ? val2 ? Colors.black54 : Colors.black12 : Colors.transparent,
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
