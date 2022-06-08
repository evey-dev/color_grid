import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_grid/const/theme.dart';
import 'package:color_grid/tools/tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:color_grid/tools/drag_and_drop_gridview/drag.dart';
import 'package:color_grid/tools/drag_and_drop_gridview/devdrag.dart';
import 'package:color_grid/const/color.dart';
class ColorGrid extends StatefulWidget {
  final String gridId;
  const ColorGrid(this.gridId, {Key? key}) : super(key: key);

  @override
  _ColorGridState createState() => _ColorGridState();
}

class _ColorGridState extends State<ColorGrid> {
  final int gridHeight = 5;
  final int gridWidth = 5;
  late List<Tile> tiles;
  final List<Tile> userTiles = [];
  late List<DragItem> tilesWrapper;
  late Map<String, dynamic> data = {};
  String name = 'Loading...';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
    double power = 2;
    for (Tile tile in tiles) {
      if (userTiles.contains(tile)) continue;
      List<double> list = getDistanceToUserTiles(tile.index);
      double p = 1/list.fold(0, (prev, e) => prev + 1/pow(e,power));
      double R = 0, G = 0, B = 0;
      for (int i = 0; i < userTiles.length; i++) {
        num temp = pow(list[i],power);
        R += userTiles[i].userColor.value.red * p/temp;
        G += userTiles[i].userColor.value.green * p/temp;
        B += userTiles[i].userColor.value.blue * p/temp;
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
    getFirestoreInstance();

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

  void getFirestoreInstance() async {
    await firestore
      .collection('grids')
      .doc(widget.gridId)
      .get()
      .then((value) {
        if (value.exists) {
          data = value.data()!;
          name = data['name'];
          data['colors'].forEach((k, v) {
            tiles[int.parse(k)].userColor.value =
                Color(int.parse(v.split('(0x')[1].split(')')[0], radix: 16))
                    .withOpacity(1);
            userTiles.add(tiles[int.parse(k)]);
          });
        }
        recalculate();
        setState(() {
        });
      });
  }

  void save() {
    firestore.collection('grids').doc(widget.gridId).update({'colors' : {for (var t in userTiles) t.index.toString() : t.userColor.value.toString()}});
  }
  void publish() {

    save();
    firestore.collection('grids').doc(widget.gridId).update({'published' : true});
    firestore.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({'grids' : FieldValue.arrayRemove([widget.gridId])});
    firestore.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({'published' : FieldValue.arrayUnion([widget.gridId])});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 70,
        leading: IconButton(onPressed: () {save(); Navigator.pop(context);}, icon: const Icon(Icons.arrow_back), color: greyTextColor,),
        title: Text(name, style: const TextStyle(fontSize: 20, color: mainTextColor),),
        backgroundColor: backgroundColor,
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              String newName = '';
              return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Change ColorGrid Name', textAlign: TextAlign.center,),
                    backgroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(20),
                    actionsAlignment: MainAxisAlignment.center ,
                    content: Neumorphic(
                      style: textFieldStyle,
                      child: TextField(
                        cursorColor: Colors.black,
                        onChanged: (value) => newName = value,
                        decoration: textFieldDecoration,
                      ),
                    ),
                    actions: <Widget> [
                      Padding (
                        padding: const EdgeInsets.only(bottom: 20),
                        child: NeumorphicButton (
                          style: buttonStyle,
                          child: const Text('Change'),
                          onPressed: () {
                            if (newName.trim() != '') {
                              firestore.collection('grids')
                                  .doc(widget.gridId)
                                  .update({'name': newName.trim()});
                              name = newName.trim();
                              Navigator.pop(context);
                              setState(() {});
                            }
                          },
                        ),
                      )
                    ],
                  );
                }
              );
            },
            icon: const Icon(Icons.edit_outlined),
            color: greyTextColor,
          ),
          IconButton(
            onPressed: () {publish(); Navigator.pop(context);},
            icon: const Icon(Icons.publish_outlined),
            color: greyTextColor,
            padding: const EdgeInsets.only(right: 30, left: 20),
          )
        ],
      ),
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
            child: const Icon(
              Icons.delete,
              size: 30,
              color: greyTextColor,
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
