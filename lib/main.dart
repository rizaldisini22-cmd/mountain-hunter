import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: BubbleCrushDana()));

class BubbleCrushDana extends StatefulWidget {
  const BubbleCrushDana({super.key});
  @override State<BubbleCrushDana> createState() => _BubbleState();
}

class _BubbleState extends State<BubbleCrushDana> {
  int emas = 0; // MULAI DARI 0 KAK!
  int level = 0; // MULAI DARI 0 KAK!
  int maxLevel = 1000;

  List<Map<String, dynamic>> bubbles = [];
  Timer? gameLoop;
  Random rand = Random();

  Map<String, Color> colorMap = {
    "blue": Color(0xFF29B6F6),
    "purple": Color(0xFFAB47BC),
    "green": Color(0xFF8BC34A),
    "pink": Color(0xFFF48FB1),
    "yellow": Color(0xFFFFEB3B),
    "orange": Color(0xFFFF9800),
    "red": Color(0xFFEF5350),
  };

  late Map<String, int> targets;
  late Map<String, int> progress;
  late int totalNeed;
  List<Map> obstacles = [];
  String bottleShape = "normal";

  @override
  void initState(){
    super.initState();
    loadLevel(level);
    startGame();
  }

  void loadLevel(int lvl){
    bubbles.clear();
    obstacles.clear();

    int colorCount = 3;
    if(lvl > 10) colorCount = 4;
    if(lvl > 50) colorCount = 5;
    if(lvl > 200) colorCount = 6;
    if(lvl > 500) colorCount = 7;

    List<String> allColors = colorMap.keys.toList()..shuffle();
    List<String> levelColors = allColors.take(colorCount).toList();

    if(lvl % 7 == 0 && lvl!=0) bottleShape = "rock";
    else if(lvl % 5 == 0 && lvl!=0) bottleShape = "narrow";
    else bottleShape = "normal";

    if(bottleShape == "rock"){
      obstacles.add({"x": 110, "y": 350, "w": 80, "h": 80});
    }

    // Level 0 = target 8 bola aja (tutorial)
    int baseTarget = lvl==0? 8 : 10 + (lvl * 0.12).toInt();
    if(baseTarget > 150) baseTarget = 150;

    int targetTypes = lvl==0? 1 : (lvl > 30? 2 : 1);
    targets = {};
    progress = {};
    var targetColors = (levelColors..shuffle()).take(targetTypes).toList();
    for(var c in targetColors){
      int need = lvl==0? 8 : (baseTarget / targetTypes).ceil() + rand.nextInt(3);
      targets[c] = need;
      progress[c] = 0;
    }
    totalNeed = targets.values.fold(0,(a,b)=>a+b);

    int initialBubbles = lvl==0? 15 : 25 + (lvl/10).clamp(0, 25).toInt();
    for(int i=0;i<initialBubbles;i++){
      double x = 30+rand.nextDouble()*220;
      double y = 300+rand.nextDouble()*230;
      bubbles.add({
        "x": x, "y": y,
        "color": levelColors[rand.nextInt(levelColors.length)],
        "vx": (rand.nextDouble()-0.5)*1.5,
        "vy": 0.0,
        "settled": true,
      });
    }
    setState(() {});
  }

  void startGame(){
    gameLoop?.cancel();
    gameLoop = Timer.periodic(Duration(milliseconds: 32), (_){
      if(!mounted) return;
      setState(() {
        for(var b in bubbles){
          if(!b["settled"]){
            b["vy"] += 0.28;
            b["y"] += b["vy"];
            b["x"] += b["vx"];
            if(b["y"] > 530){ b["y"]=530; b["vy"]=0; b["settled"]=true; }
            if(b["x"]<25){b["x"]=25; b["vx"]*=-0.7;}
            if(b["x"]>265){b["x"]=265; b["vx"]*=-0.7;}
          }
        }
        if(bubbles.length < 48 && rand.nextDouble() > 0.82){
          var avail = targets.keys.toList() + colorMap.keys.toList();
          bubbles.add({
            "x": 90+rand.nextDouble()*120,
            "y": -30.0,
            "color": avail[rand.nextInt(avail.length)],
            "vx": (rand.nextDouble()-0.5)*2.8,
            "vy": 0.5,
            "settled": false,
          });
        }
      });
    });
  }

  void popBubble(int idx){
    if(idx>=bubbles.length) return;
    String col = bubbles[idx]["color"];
    List<int> group = [];
    for(int i=0;i<bubbles.length;i++){
      if(bubbles[i]["color"]==col){
        double dx = (bubbles[i]["x"]-bubbles[idx]["x"]).abs();
        double dy = (bubbles[i]["y"]-bubbles[idx]["y"]).abs();
        if(dx<46 && dy<46) group.add(i);
      }
    }
    if(group.length>=2){
      setState(() {
        group.sort((a,b)=>b.compareTo(a));
        for(var g in group) bubbles.removeAt(g);
        int got = group.length * (50 + level*2);
        if(level==0) got = group.length * 20; // level 0 dikit aja
        emas += got;
        if(progress.containsKey(col)){
          progress[col] = (progress[col]! + group.length).clamp(0, targets[col]!);
        }
        checkComplete();
      });
    }
  }

  void checkComplete(){
    bool done = true;
    for(var k in targets.keys){ if(progress[k]! < targets[k]!) done=false; }
    if(done){
      gameLoop?.cancel();
      int bonus = level==0? 100 : 2000 + level*20;
      emas += bonus;
      showDialog(context: context, barrierDismissible: false, builder: (_)=> AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(level==0? "TUTORIAL SELESAI! 🎉" : "LEVEL $level SELESAI! 🎉", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Bonus: +$bonus Emas", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Colors.orange)),
          Text("Total: $emas Emas\n≈ Rp${(emas/59).toStringAsFixed(0)}", textAlign: TextAlign.center),
        ]),
        actions: [Center(child: ElevatedButton(onPressed: (){
          Navigator.pop(context);
          setState(() { level++; loadLevel(level); startGame(); });
        }, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFC107), padding: EdgeInsets.symmetric(horizontal:40,vertical:14), shape: StadiumBorder()), child: Text(level==0? "MULAI LEVEL 1 ▶":"LANJUT LEVEL ${level+1} ▶", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)))))],
      ));
    }
  }

  @override void dispose(){ gameLoop?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context){
    int totalProg = progress.values.fold(0,(a,b)=>a+b);
    double percent = totalNeed==0?0:totalProg/totalNeed;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7A8FC4), Color(0xFF5A6DAF)])),
        child: Stack(children: [
          CustomPaint(size: Size.infinite, painter: BrickPainter()),
          SafeArea(child: Column(children: [
            SizedBox(height:6),
            Expanded(child: Center(child: Stack(alignment: Alignment.center, children: [
              Container(width: 340, height: 650, decoration: BoxDecoration(color: Color(0xFFFFC107), borderRadius: BorderRadius.circular(42), border: Border.all(color: Color(0xFFFFD54F), width:6), boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15, offset: Offset(0,8))])),
              Container(width: 298, height: 610, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32))),
              Container(width: 282, height: 594, decoration: BoxDecoration(color: Color(0xFF4A3C7A), borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22), bottomLeft: Radius.circular(145), bottomRight: Radius.circular(145)), border: Border.all(color: Color(0xFF7A6BA6), width:10)), child: ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(140), bottomRight: Radius.circular(140)), child: Column(children: [
                Container(padding: EdgeInsets.symmetric(horizontal:10,vertical:6), color: Color(0xFF4A3C7A), child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(padding: EdgeInsets.symmetric(horizontal:10,vertical:4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width:12,height:12, decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle)), SizedBox(width:4), Text("$emas", style: TextStyle(fontWeight: FontWeight.bold, fontSize:11))])),
                    Container(padding: EdgeInsets.symmetric(horizontal:12,vertical:3), decoration: BoxDecoration(color: Color(0xFFFFE082), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white,width:2)), child: Text(level==0? "TUTORIAL" : "LEVEL $level / $maxLevel", style: TextStyle(fontWeight: FontWeight.w900, fontSize:11, color: Colors.brown))),
                    Icon(Icons.volume_up, color: Colors.white70, size:18),
                  ]),
                  SizedBox(height:6),
                  Wrap(alignment: WrapAlignment.center, spacing:8, children: targets.entries.map((e){
                    bool isDone = progress[e.key]! >= e.value;
                    int left = e.value - progress[e.key]!;
                    return Stack(alignment: Alignment.bottomRight, children: [
                      Container(width:42,height:42, decoration: BoxDecoration(color: isDone? Colors.grey.shade400 : colorMap[e.key], shape: BoxShape.circle, border: Border.all(color: Colors.white, width:2.5)), child: Center(child: Text("♥", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize:14)))),
                      if(isDone) Container(width:16,height:16, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color:
