
import 'package:color_grid/tile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'drag_and_drop_gridview/drag.dart';
import 'drag_and_drop_gridview/devdrag.dart';

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

  // late List<ValueNotifier<Color>> colorGrid;
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

  @override
  void initState() {
    super.initState();
    // colorGrid = [
    //   for (var i = 0; i < gridHeight*gridWidth; i++)
    //     ValueNotifier(const Color(0xFFDCDCDC))
    // ];
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
          isDraggable: dots[i].value,
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
                final temp = tiles[oldIndex];
                tiles[oldIndex] = tiles[newIndex];
                tiles[newIndex] = temp;
                tiles[newIndex].index = newIndex;
                tiles[oldIndex].index = oldIndex;
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
                    height: 205,
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
          return SlidePicker(
            pickerColor: tiles[val].color.value == Colors.transparent ? const Color(0xFFD3D8DB) : tiles[val].color.value,
            onColorChanged: (color) {
              tiles[val].color.value = color;
            },
            enableAlpha: false,
            colorModel: ColorModel.hsv,
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
