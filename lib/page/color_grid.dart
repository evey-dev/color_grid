import 'dart:math';
import 'package:color_grid/const/theme.dart';
import 'package:color_grid/tools/tile.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:color_grid/tools/drag_and_drop_gridview/drag.dart';
import 'package:color_grid/tools/drag_and_drop_gridview/devdrag.dart';
import 'package:color_grid/const/color.dart';
class ColorGrid extends StatefulWidget {
  const ColorGrid({Key? key}) : super(key: key);

  @override
  _ColorGridState createState() => _ColorGridState();
}

class _ColorGridState extends State<ColorGrid> {
  final int gridHeight = 5;
  final int gridWidth = 5;
  late List<Tile> tiles;
  final List<Tile> userTiles = [];
  late List<DragItem> tilesWrapper;

  ValueNotifier<int> selected = ValueNotifier<int>(-1);

  void setSelected(int index) {
    if (selected.value!=-1) {
      tiles[selected.value].selected.value = false;
    }
    if (selected.value != index) {
      selected.value = index;
      tiles[index].selected.value = true;
    }
    else {
      selected.value = -1;
      tiles[index].selected.value = false;

    }
  }

  void addToUserTiles(int index, bool add) {
    if (add) {
      userTiles.add(tiles[index]);
    } else {
      userTiles.remove(tiles[index]);
    }
  }
  void recalculate() {
    if (userTiles.isEmpty) {
      for (Tile tile in tiles) {
        tile.autoColor.value = Colors.transparent;
      }
      return;
    }
    for (Tile tile in tiles) {
      if (userTiles.contains(tile)) continue;
      List<double> list = getDistanceToUserTiles(tile.index);
      double p = 1/list.fold(0, (prev, e) => prev + 1/e);
      double R = 0, G = 0, B = 0;
      for (int i = 0; i < userTiles.length; i++) {
        R += userTiles[i].userColor.value.red * p/list[i];
        G += userTiles[i].userColor.value.green * p/list[i];
        B += userTiles[i].userColor.value.blue * p/list[i];
      }

      tile.autoColor.value = Color.fromRGBO(R.round(), G.round(), B.round(), 1);
    }
  }
  List<double> getDistanceToUserTiles(int index) {
    List <double> list = [];
    int row = index ~/ gridWidth;
    int col = index % gridWidth;
    for (Tile userTile in userTiles) {
      int curRow = userTile.index ~/ gridWidth;
      int curCol = userTile.index % gridHeight;
      list.add(sqrt(pow(curRow - row, 2) + pow(curCol - col, 2)));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    tiles = [
      for (var i = 0; i < gridHeight*gridWidth; i++)
        Tile(
          index: i,
          setSelected: setSelected,
          addToUserTiles: addToUserTiles,
        )
    ];
    tilesWrapper = [
      for (var i = 0; i < gridHeight*gridWidth; i++)
        DragItem(
          child: tiles[i],
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: backgroundColor), //0xFFDCDCDC
      home: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 10,),
            DragAndDropGridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridWidth,
              ),
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) => tilesWrapper[index],
              itemCount: gridHeight*gridWidth,
              isCustomFeedback: true,
              feedback: (pos) {
                return AbsorbPointer(
                  absorbing: true,
                  child: Transform.scale(scale: .5, child: tiles[pos]),
                );
              },
              onWillAccept: (oldIndex, newIndex) {
                return true;
              },
              onReorder: (oldIndex, newIndex) {
                final temp1 = tiles[oldIndex];
                tiles[oldIndex] = tiles[newIndex];
                tiles[newIndex] = temp1;
                final temp2 = tilesWrapper[oldIndex];
                tilesWrapper[oldIndex] = tilesWrapper[newIndex];
                tilesWrapper[newIndex] = temp2;
                tiles[newIndex].index = newIndex;
                tiles[oldIndex].index = oldIndex;
                tiles[newIndex].selected.value = false;
                tiles[oldIndex].selected.value = false;
                setSelected(newIndex);
                setState(() {});
                recalculate();
              },
            ),
            Neumorphic(
              style: containerStyle,
              child: ValueListenableBuilder<int>(
                  valueListenable: selected,
                  builder: (BuildContext context, int val, Widget? child) {
                    return SizedBox(
                      height: 255,
                      width: 280,
                      child: colorTile(val),
                    );
                  }
              ),
            ),
            const SizedBox(height: 10,),
            NeumorphicButton(
              style: buttonStyle,
              minDistance: 1,
              child: const Text('Calculate Grid'),
              onPressed: recalculate,
            ),
          ],
        ),
      ),
    );
  }

  Widget colorTile(int val) {
    if (val > -1) {
      return Column(
        children: [
          SlidePicker(
            pickerColor: tiles[val].userColor.value == Colors.transparent ? backgroundColor : tiles[val].userColor.value,
            onColorChanged: (color) {
              tiles[val].userColor.value = color;
            },
            enableAlpha: false,
            colorModel: ColorModel.hsv,
          ),
          GestureDetector(
            onTap: (){
              tiles[selected.value].userColor.value = Colors.transparent;
              tiles[selected.value].selected.value = false;
              userTiles.remove(tiles[selected.value]);
              selected.value = -1;
              recalculate();
            },
            child: NeumorphicIcon(
              Icons.delete,
              size: 30,
              style: NeumorphicStyle(
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                depth: 2,
                lightSource: LightSource.topLeft,
                intensity: 1,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: NeumorphicText(
          'Select a tile to change its color',
          textAlign: TextAlign.center,
          textStyle: NeumorphicTextStyle(fontSize: 30,),
          style: textStyle,
        ),
      );
    }
  }
}
