import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Tile extends StatefulWidget {
  Color color = Colors.white;
  final _TileState _ts = _TileState();
  final double size;

  Tile({required this.size, Key? key}) : super(key: key);

  @override
  _TileState createState() => _ts;

  void autoFill() {
    _ts.autoFill(color);
  }
}

class _TileState extends State<Tile> {
  void autoFill(Color color) {
    setState(() {
      widget.color = color;
    });
  }

  void userInput(Color color) {
    setState(() {
      widget.color = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Container(
        height: widget.size,
        width: widget.size,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.size / 10)),
          color: widget.color,
          border: Border.all(color: Colors.black)),
        child: const Align(
          alignment: Alignment.bottomRight,
          child: Icon(
            Icons.circle,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
