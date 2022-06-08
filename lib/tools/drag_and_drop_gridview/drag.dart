import 'package:flutter/material.dart';

class DragItem extends StatefulWidget {
  final bool isDraggable;
  final bool isDropable;
  final Widget child;

  const DragItem({Key? key,
    this.isDraggable = true,
    this.isDropable = true,
    /*required*/ required this.child,
  }) : super(key: key);

  @override
  _DragItemState createState() => _DragItemState();
}

class _DragItemState extends State<DragItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      child: widget.child,
    );
  }
}