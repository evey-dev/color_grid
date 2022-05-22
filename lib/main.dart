
import 'dart:developer';

import 'package:color_grid/tile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'drag_and_drop_gridview/drag.dart';
import 'drag_and_drop_gridview/devdrag.dart';
import 'Pages/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final int gridHeight = 5;
  final int gridWidth = 5;
  late List<Tile> tiles;
  late List<DragItem> tilesWrapper;
  late List<ValueNotifier<bool>> dots;

  ValueNotifier<int> selected = ValueNotifier<int>(-1);


  void setSelected(int index) {
    if (selected.value!=-1) {
      tiles[selected.value].selected.value = false;
    }
    selected.value = index;
    if (selected.value!=-1) {
      tiles[index].selected.value = true;
    }
    dots[index].value = true;
  }

  // col: index % gridWidth
  // row: index ~/ gridHeight

  void calculateGrid() {
    for (int i = 0; i < gridWidth * gridHeight; i++) {
      tiles[i].autoColor.value = Colors.transparent;
    }
    for (int i = 0; i < gridWidth * gridHeight; i++) {
      if (tiles[i].userColor.value != Colors.transparent) {
        continue;
      }
      int dUp = distanceToClosestInclude(i,1);
      int dDown = distanceToClosestInclude(i,2);
      int dRight = distanceToClosestInclude(i,3);
      int dLeft = distanceToClosestInclude(i,4);
      double p = 1/(1/dUp + 1/dDown + 1/dRight + 1/dLeft);;
      if (dUp < gridHeight && dDown < gridHeight && dRight < gridWidth && dLeft < gridWidth) {
        // var R = (tiles[i-gridHeight*dUp].userColor.value == Colors.transparent ? tiles[i-gridHeight*dUp].autoColor.value.red * p/dUp : tiles[i-gridHeight*dUp].userColor.value.red * p/dUp)
        //       + (tiles[i+gridHeight*dDown].userColor.value == Colors.transparent ? tiles[i+gridHeight*dDown].autoColor.value.red * p/dDown : tiles[i+gridHeight*dDown].userColor.value.red * p/dDown)
        //       + (tiles[i+dRight].userColor.value == Colors.transparent ? tiles[i+dRight].autoColor.value.red * p/dRight : tiles[i+dRight].userColor.value.red * p/dRight)
        //       + (tiles[i-dLeft].userColor.value == Colors.transparent ? tiles[i-dLeft].autoColor.value.red * p/dLeft : tiles[i-dLeft].userColor.value.red * p/dLeft);
        // var G = (tiles[i-gridHeight*dUp].userColor.value == Colors.transparent ? tiles[i-gridHeight*dUp].autoColor.value.red * p/dUp : tiles[i-gridHeight*dUp].userColor.value.red * p/dUp)
        //     + (tiles[i+gridHeight*dDown].userColor.value == Colors.transparent ? tiles[i+gridHeight*dDown].autoColor.value.red * p/dDown : tiles[i+gridHeight*dDown].userColor.value.red * p/dDown)
        //     + (tiles[i+dRight].userColor.value == Colors.transparent ? tiles[i+dRight].autoColor.value.red * p/dRight : tiles[i+dRight].userColor.value.red * p/dRight)
        //     + (tiles[i-dLeft].userColor.value == Colors.transparent ? tiles[i-dLeft].autoColor.value.red * p/dLeft : tiles[i-dLeft].userColor.value.red * p/dLeft);
        // var B = (tiles[i-gridHeight*dUp].userColor.value == Colors.transparent ? tiles[i-gridHeight*dUp].autoColor.value.red * p/dUp : tiles[i-gridHeight*dUp].userColor.value.red * p/dUp)
        //     + (tiles[i+gridHeight*dDown].userColor.value == Colors.transparent ? tiles[i+gridHeight*dDown].autoColor.value.red * p/dDown : tiles[i+gridHeight*dDown].userColor.value.red * p/dDown)
        //     + (tiles[i+dRight].userColor.value == Colors.transparent ? tiles[i+dRight].autoColor.value.red * p/dRight : tiles[i+dRight].userColor.value.red * p/dRight)
        //     + (tiles[i-dLeft].userColor.value == Colors.transparent ? tiles[i-dLeft].autoColor.value.red * p/dLeft : tiles[i-dLeft].userColor.value.red * p/dLeft);
        int R = ((tiles[i-gridHeight*dUp].userColor.value.red * p/dUp)
            + (tiles[i+gridHeight*dDown].userColor.value.red * p/dDown)
            + (tiles[i+dRight].userColor.value.red * p/dRight)
            + (tiles[i-dLeft].userColor.value.red * p/dLeft)).round();
        int G = ((tiles[i-gridHeight*dUp].userColor.value.green * p/dUp)
            + (tiles[i+gridHeight*dDown].userColor.value.green * p/dDown)
            + (tiles[i+dRight].userColor.value.green * p/dRight)
            + (tiles[i-dLeft].userColor.value.green * p/dLeft)).round();
        int B = ((tiles[i-gridHeight*dUp].userColor.value.blue * p/dUp)
            + (tiles[i+gridHeight*dDown].userColor.value.blue * p/dDown)
            + (tiles[i+dRight].userColor.value.blue * p/dRight)
            + (tiles[i-dLeft].userColor.value.blue * p/dLeft)).round();
        tiles[i].autoColor.value = Color.fromRGBO(R, G, B, 1);
      }
    }
    for (int i = 0; i < gridWidth * gridHeight; i++) {
      if (tiles[i].userColor.value != Colors.transparent || tiles[i].autoColor.value != Colors.transparent) {
        continue;
      }
      int dUp = distanceToClosestInclude(i,1);
      int dDown = distanceToClosestInclude(i,2);
      double p = 1/(1/dUp + 1/dDown);
      if (dUp < gridHeight && dDown < gridHeight) {
        Color upColor = tiles[i-gridHeight*dUp].userColor.value == Colors.transparent? tiles[i-gridHeight*dUp].autoColor.value : tiles[i-gridHeight*dUp].userColor.value;
        Color downColor = tiles[i+gridHeight*dDown].userColor.value == Colors.transparent? tiles[i+gridHeight*dDown].autoColor.value : tiles[i+gridHeight*dDown].userColor.value;
        int R = ((upColor.red * p/dUp)
            + (downColor.red * p/dDown)).round();
        int G = ((upColor.green * p/dUp)
            + (downColor.green * p/dDown)).round();
        int B = ((upColor.blue * p/dUp)
            + (downColor.blue * p/dDown)).round();
        tiles[i].autoColor.value = Color.fromRGBO(R, G, B, 1);
      }
    }
    for (int i = 0; i < gridWidth * gridHeight; i++) {
      if (tiles[i].userColor.value != Colors.transparent || tiles[i].autoColor.value != Colors.transparent) {
        continue;
      }
      int dRight = distanceToClosestInclude(i,3);
      int dLeft = distanceToClosestInclude(i,4);
      double p = 1/(1/dRight + 1/dLeft);
      if (dRight < gridHeight && dLeft < gridHeight) {
        Color leftColor = tiles[i-dLeft].userColor.value == Colors.transparent? tiles[i-dLeft].autoColor.value : tiles[i-dLeft].userColor.value;
        Color rightColor = tiles[i+dRight].userColor.value == Colors.transparent? tiles[i+dRight].autoColor.value : tiles[i+dRight].userColor.value;
        p = 1/(1/dRight + 1/dLeft);
        int R = ((rightColor.red * p/dRight)
            + (leftColor.red * p/dLeft)).round();
        int G = ((rightColor.green * p/dRight)
            + (leftColor.green * p/dLeft)).round();
        int B = ((rightColor.blue * p/dRight)
            + (leftColor.blue * p/dLeft)).round();
        tiles[i].autoColor.value = Color.fromRGBO(R, G, B, 1);

      }
    }

  }

  // return values: up/down=1, neither=0, right/left=-1
  // int closestDirectionUp(int index) {
  //
  //   return 1;
  // }

  // directions: up, down, right, left (1, 2, 3, 4)
  int distanceToClosestInclude(int index, int direction) {
    int row = index ~/ gridWidth;
    int col = index % gridWidth;
    int distance = 1;
    switch(direction) {
      case 1:
        for (int i = row - 1; i >= 0; i--) {
          if (tiles[i*gridWidth + col].userColor.value != Colors.transparent || tiles[i*gridWidth + col].autoColor.value != Colors.transparent) return distance; // || tiles[i*gridWidth + col].autoColor.value != Colors.transparent
          distance ++;
        }
        return gridHeight;
      case 2:
        for (int i = row + 1; i < gridHeight ; i++) {
          if (tiles[i*gridWidth + col].userColor.value != Colors.transparent || tiles[i*gridWidth + col].autoColor.value != Colors.transparent) return distance; // || tiles[i*gridWidth + col].autoColor.value != Colors.transparent
          distance++;
        }
        return gridHeight;
      case 3:
        for (int i = col + 1; i < gridWidth ; i++) {
          if (tiles[row*gridWidth + i].userColor.value != Colors.transparent || tiles[row*gridWidth + i].autoColor.value != Colors.transparent) return distance; // || tiles[row*gridWidth + i].autoColor.value != Colors.transparent
          distance++;
        }
        return gridWidth;
      case 4:
        for (int i = col - 1; i >=0 ; i--) {
          if (tiles[row*gridWidth + i].userColor.value != Colors.transparent || tiles[row*gridWidth + i].autoColor.value != Colors.transparent) return distance; // || tiles[row*gridWidth + i].autoColor.value != Colors.transparent
          distance++;
        }
        return gridWidth;
    }
    return 4;
  }
  int distanceToClosestExclude(int index, int direction) {
    int row = index ~/ gridWidth;
    int col = index % gridWidth;
    int distance = 1;
    switch(direction) {
      case 1:
        for (int i = row - 1; i >= 0; i--) {
          if (tiles[i*gridWidth + col].userColor.value != Colors.transparent) return distance; // || tiles[i*gridWidth + col].autoColor.value != Colors.transparent
          distance ++;
        }
        return gridHeight;
      case 2:
        for (int i = row + 1; i < gridHeight ; i++) {
          if (tiles[i*gridWidth + col].userColor.value != Colors.transparent) return distance; // || tiles[i*gridWidth + col].autoColor.value != Colors.transparent
          distance++;
        }
        return gridHeight;
      case 3:
        for (int i = col + 1; i < gridWidth ; i++) {
          if (tiles[row*gridWidth + i].userColor.value != Colors.transparent) return distance; // || tiles[row*gridWidth + i].autoColor.value != Colors.transparent
          distance++;
        }
        return gridWidth;
      case 4:
        for (int i = col - 1; i >=0 ; i--) {
          if (tiles[row*gridWidth + i].userColor.value != Colors.transparent) return distance; // || tiles[row*gridWidth + i].autoColor.value != Colors.transparent
          distance++;
        }
        return gridWidth;
    }
    return 4;
  }

  @override
  void initState() {
    super.initState();
    tiles = [
      for (var i = 0; i < gridHeight*gridWidth; i++)
        Tile(
          index: i,
          size: 100,
          callback: setSelected,
        )
    ];
    dots = [
      for (var i = 0; i < gridHeight*gridWidth; i++)
        ValueNotifier(false)
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
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFD3D8DB)), //0xFFDCDCDC
      home: Scaffold(
        body: Column(
          children: [
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
                calculateGrid();
                setState(() {});
              },
            ),
            Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                depth: 6,
                lightSource: LightSource.topLeft,
                intensity: .5,
                color: const Color(0xFFD3D8DB),
                border: const NeumorphicBorder(color: Colors.black12),
              ),
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
            pickerColor: tiles[val].userColor.value == Colors.transparent ? const Color(0xFFD3D8DB) : tiles[val].userColor.value,
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
              selected.value = -1;
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
          textStyle: NeumorphicTextStyle(fontSize: 30),
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            depth: 2,
            lightSource: LightSource.topLeft,
            intensity: 1,
            color: Colors.black54,
          ),
        ),
      );
    }
  }
}
