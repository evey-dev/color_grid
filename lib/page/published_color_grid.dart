import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_grid/const/theme.dart';
import 'package:color_grid/tools/fake_tile.dart';
import 'package:color_grid/tools/tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:color_grid/tools/drag_and_drop_gridview/drag.dart';
import 'package:color_grid/tools/drag_and_drop_gridview/devdrag.dart';
import 'package:color_grid/const/color.dart';
class PublishedColorGrid extends StatefulWidget {
  final String gridId;
  const PublishedColorGrid(this.gridId, {Key? key}) : super(key: key);

  @override
  _PublishedColorGridState createState() => _PublishedColorGridState();
}

class _PublishedColorGridState extends State<PublishedColorGrid> {
  final int gridHeight = 5;
  final int gridWidth = 5;
  late List<FakeTile> tiles;
  final List<FakeTile> userTiles = [];
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
      for (FakeTile tile in tiles) {
        tile.autoColor.value = Colors.transparent;
      }
      return;
    }
    double power = 2;
    for (FakeTile tile in tiles) {
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
    for (FakeTile userTile in userTiles) {
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
        FakeTile(
          index: i,
          setSelected: setSelected,
          addToUserTiles: addToUserTiles,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70,
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.arrow_back), color: greyTextColor,),
        title: Text(name, style: const TextStyle(fontSize: 20, color: mainTextColor),),
        backgroundColor: backgroundColor,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
            color: greyTextColor,
            padding: const EdgeInsets.only(right: 30, left: 20),
          )
        ],
      ),
      body: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridWidth,
            ),
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              return tiles[index];
            },
            itemCount: gridHeight*gridWidth,
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }

}
