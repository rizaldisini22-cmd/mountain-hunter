import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: BubbleCrushDana()));

class BubbleCrushDana extends StatefulWidget {
  const BubbleCrushDana({super.key});
  @override State<BubbleCrushDana> createState() => _BubbleState();
}

class _BubbleState extends State<BubbleCrushDana> {
  int emas = 0;
  int level = 0;
  List<Map<String, dynamic>> bubbles = [];
  Timer? loop;
  Random rand = Random();

  Map<String, Color> cmap = {
    "blue": Color(0xFF29B6F6),
    "purple": Color(0xFFAB47BC),
    "green": Color(0xFF8BC34A),
    "pink": Color(0xFFF48FB1),
    "yellow": Color(0xFFFFEB3B),
    "orange": Color(0xFFFF9800),
  };

  Map<String, int> targets = {"blue": 8};
  Map<String, int> progress = {"blue": 0};

  @override
  void initState(){
    super.initState();
    loadLevel();
    startLoop();
  }

  void loadLevel(){
    bubbles.clear();
    if(level==0){
      targets = {"blue": 8};
      progress = {"blue": 0};
    } else {
      int need = 10 + (level*2);
      if(need>120) need=120;
      String col = cmap.keys.elementAt(level % cmap.length);
      targets = {col: need};
      progress = {col: 0};
    }
    for(int i=0;i<20;i++){
      bubbles.add({
        "x": 30+rand.nextDouble()*220,
        "y": 300+rand.nextDouble()*200,
        "color": cmap.keys.elementAt(rand.nextInt(cmap.length)),
        "vx": (rand.nextDouble()-0.5)*1.2,
        "vy": 0.0,
        "settled": true,
      });
    }
    setState((){});
  }

  void startLoop(){
    loop?.cancel();
    loop = Timer.periodic(Duration(milliseconds: 35), (t){
      if(!mounted) return;
      setState(() {
        for(var b in bubbles){
          if(b["settled"]==false){
            b["vy"]+=0.28;
            b["y"]+=b["vy"];
            b["x"]+=b["vx"];
            if(b["y"]>530){b["y"]=530; b["settled"]=true; b["vy"]=0;}
            if(b["x"]<25 || b["x"]>265){b["vx"]*=-1;}
          }
        }
        if(bubbles.length<45 && rand.nextDouble()>0.8){
          bubbles.add({
            "x": 100+rand.nextDouble()*100,
            "y": -20.0,
            "color": targets.keys.first,
            "vx": (rand.nextDouble()-0.5)*2,
            "vy": 1.0,
            "settled": false,
          });
        }
      });
    });
  }

  void tapB(int idx){
    String col = bubbles[idx]["color"];
    List<int> grp=[];
    for(int i=0;i<bubbles.length;i
