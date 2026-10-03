import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MaterialApp(home: LevelMapScreen(), debugShowCheckedModeBanner: false));

class LevelMapScreen extends StatefulWidget {
  @override State<LevelMapScreen> createState() => _LevelMapScreenState();
}
class _LevelMapScreenState extends State<LevelMapScreen> {
  int unlocked = 1;
  void initState(){super.initState(); SharedPreferences.getInstance().then((p)=>setState(()=>unlocked=p.getInt('unlocked')??1));}
  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF0A2A4A),
      appBar: AppBar(title: Text("MOUNTAIN HUNTER - 100 LEVELS", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF0A2A4A), foregroundColor: Colors.white),
      body: GridView.builder(
        padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: 100,
        itemBuilder: (_, i){
          int lvl=i+1; bool open=lvl<=unlocked;
          return GestureDetector(
            onTap: open?(){Navigator.push(context, MaterialPageRoute(builder: (_)=>GameScreen(level: lvl))).then((_)=>SharedPreferences.getInstance().then((p)=>setState(()=>unlocked=p.getInt('unlocked')??1)));}:null,
            child: Container(decoration: BoxDecoration(color: open? (lvl%10==0?Colors.orange:Colors.blue) : Colors.grey[800], borderRadius: BorderRadius.circular(12), border: Border.all(color: open?Colors.white:Colors.transparent)), child: Center(child: Text("$lvl", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)))),
          );
        },
      ),
    );
  }
}

// GAME INTI - BOLA UKURAN SAMA + WARNA BANYAK
class GameScreen extends StatefulWidget{
  final int level; GameScreen({required this.level});
  @override State<GameScreen> createState()=> _GameScreenState();
}
class _GameScreenState extends State<GameScreen> {
  // WARNA KAYAK DI FOTO KAKAK
  final List<Color> gameColors = [Color(0xFF4CAF50), Color(0xFFFF9800), Color(0xFF2196F3), Color(0xFF9C27B0), Color(0xFFE91E63)];
  List<List<Color?>> grid = [];
  Color nextColor = Colors.purple;
  int moves = 20;
  int score = 0;
  final int cols = 11;
  final double bubbleRadius = 18; // UKURAN SAMA SEMUA!

  @override void initState(){
    super.initState();
    generateLevel(widget.level);
  }

  void generateLevel(int level){
    Random rand = Random(level);
    int rows = 6 + (level ~/ 10); // level tinggi makin banyak baris
    if(rows>14) rows=14;
    grid = List.generate(rows, (_) => List.generate(cols, (_) => null));

    int colorCount = 3;
    if(level>15) colorCount=4;
    if(level>40) colorCount=5;

    // BIKIN POLA KAYAK BINTANG DI LEVEL 5,10,15
    for(int r=0;r<rows;r++){
      for(int c=0;c<cols;c++){
        // Staggered grid biar rapet kayak foto
        if(r%2==1 && c==cols-1) continue;
        grid[r][c] = gameColors[rand.nextInt(colorCount)];
      }
    }
    nextColor = gameColors[rand.nextInt(colorCount)];
    moves = 15 + level;
    score = 0;
    setState((){});
  }

  void shootBubble(int col){
    if(moves<=0) return;
    // Cari baris kosong dari bawah
    for(int r=grid.length-1; r>=0; r--){
      if(r%2==1 && col==cols-1) continue;
      if(grid[r][col]==null){
        setState((){
          grid[r][col]=nextColor;
          nextColor = gameColors[Random().nextInt(gameColors.length)];
          moves--;
          checkMatch(r,col);
          if(isWin()) win();
          if(moves<=0) gameOver();
        });
        break;
      }
    }
  }

  void checkMatch(int r, int c){
    Color? target = grid[r][c];
    if(target==null) return;
    List<Point> visited=[];
    List<Point> toCheck=[Point(r,c)];

    while(toCheck.isNotEmpty){
      var p=toCheck.removeLast();
      if(visited.contains(p)) continue;
      visited.add(p);
      // Cek 6 tetangga (hex grid)
      for(var d in [Point(-1,0), Point(1,0), Point(0,-1), Point(0,1), Point(-1,-1), Point(1,1)]){
        int nr=p.x.toInt()+d.x.toInt();
        int nc=p.y.toInt()+d.y.toInt();
        if(nr>=0 && nr<grid.length && nc>=0 && nc<cols && grid[nr][nc]==target){
          if(!visited.contains(Point(nr,nc))) toCheck.add(Point(nr,nc));
        }
      }
    }
    if(visited.length>=3){
      for(var p in visited) grid[p.x.toInt()][p.y.toInt()]=null;
      score+=visited.length*100;
    }
  }

  bool isWin(){ return grid.every((row)=>row.every((c)=>c==null)); }
  void win() async{
    final prefs=await SharedPreferences.getInstance();
    if(widget.level>= (prefs.getInt('unlocked')??1)) await prefs.setInt('unlocked', widget.level+1);
    showDialog(context: context, barrierDismissible: false, builder: (_)=>AlertDialog(title: Text("MENANG! ⭐"), content: Text("Score $score"), actions: [TextButton(onPressed: (){Navigator.pop(context);Navigator.pop(context);}, child: Text("PETA")), ElevatedButton(onPressed: (){Navigator.pop(context);Navigator.pop(context);Navigator.push(context, MaterialPageRoute(builder: (_)=>GameScreen(level: widget.level+1)));}, child: Text("NEXT LEVEL"))]));
  }
  void gameOver(){ showDialog(context: context, builder: (_)=>AlertDialog(title: Text("Game Over"), content: Text("Ulangi level ${widget.level}?"), actions: [ElevatedButton(onPressed: (){Navigator.pop(context); generateLevel(widget.level);}, child: Text("ULANG"))])); }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF0A3D62),
      appBar: AppBar(title: Text("Level ${widget.level}"), backgroundColor: Colors.blue[900], foregroundColor: Colors.white, actions: [Padding(padding: EdgeInsets.all(12), child: Center(child: Text("Score: $score | Moves: $moves", style: TextStyle(fontWeight: FontWeight.bold))))]),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(grid.length, (r){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(cols, (c){
                      if(r%2==1 && c==cols-1) return SizedBox(width: bubbleRadius*2);
                      Color? col = grid[r][c];
                      return GestureDetector(
                        onTap: ()=>shootBubble(c),
                        child: Container(
                          width: bubbleRadius*2, height: bubbleRadius*2,
                          margin: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: col,
                            gradient: col!=null? RadialGradient(colors: [Colors.white.withOpacity(0.8), col, col.withOpacity(0.8)], center: Alignment(-0.3,-0.3)): null,
                            boxShadow: col!=null? [BoxShadow(color: col.withOpacity(0.6), blurRadius: 4)]: null,
                            border: Border.all(color: Colors.white24, width: 0.5),
                          ),
                          child: col!=null? Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle))): null,
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16), color: Color(0xFF082F49),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("NEXT:", style: TextStyle(color: Colors.white)),
                SizedBox(width: 12),
                Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: nextColor, boxShadow: [BoxShadow(color: nextColor.withOpacity(0.8), blurRadius: 10)], border: Border.all(color: Colors.white, width: 2))),
                SizedBox(width: 20),
                Text("Tap kolom untuk tembak!", style: TextStyle(color: Colors.white70, fontSize: 12))
              ],
            ),
          )
        ],
      ),
    );
  }
}
class Point{ int x,y; Point(this.x,this.y);
  @override bool operator ==(Object other)=>other is Point && other.x==x && other.y==y;
  @override int get hashCode=>x*100+y;
}
