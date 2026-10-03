import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: BubbleShooter(), debugShowCheckedModeBanner: false));

class BubbleShooter extends StatefulWidget {
  const BubbleShooter({super.key});
  @override State<BubbleShooter> createState() => _BubbleShooterState();
}

class _BubbleShooterState extends State<BubbleShooter> {
  static const cols = 10;
  List<List<int?>> grid = [];
  List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.cyan, Colors.orange];
  int cur = 0, next = 1;
  double cannonX = 0.5;
  double angle = -pi/2;
  bool shooting = false;
  double sx=0, sy=0, vx=0, vy=0;
  int level = 1, score = 0;
  final rand = Random();

  @override
  void initState(){super.initState(); genLevel(); cur=rand.nextInt(colors.length); next=rand.nextInt(colors.length);}

  void genLevel(){
    grid=[];
    int rows = 6 + (level~/3);
    if(rows>15) rows=15;
    for(int r=0;r<rows;r++){
      int cCount = (r%2==0)? cols : cols-1;
      grid.add(List.generate(cCount, (_)=> (r<4 || rand.nextDouble()>0.25)? rand.nextInt( min(4 + level~/10, colors.length)) : null));
    }
  }

  void shoot(){
    if(shooting) return;
    setState((){
      shooting=true; sx=cannonX; sy=0.88;
      vx=cos(angle)*0.028; vy=sin(angle)*0.028;
    });
    tick();
  }

  void tick() async {
    while(shooting){
      await Future.delayed(const Duration(milliseconds: 16));
      if(!mounted) return;
      setState((){
        sx+=vx; sy+=vy;
        if(sx<=0.04 || sx>=0.96) vx=-vx;
        if(sy<=0.05 || hitGrid(sx,sy)){ place(); return; }
        if(sy>1.0){ shooting=false; }
      });
    }
  }

  bool hitGrid(double x,double y){
    int r = ((y-0.06)/0.057).floor();
    if(r<0||r>=grid.length) return false;
    for(int c=0;c<grid[r].length;c++){
      if(grid[r][c]==null) continue;
      double gx = (c + (r%2==0?0.5:1.0))/cols;
      double gy = 0.06 + r*0.057;
      if(sqrt(pow(x-gx,2)+pow(y-gy,2)) < 0.06) return true;
    }
    return false;
  }

  void place(){
    int br=0, bc=0; double bd=999;
    for(int r=0;r<grid.length+1;r++){
      if(r>=grid.length) grid.add(List.filled(r%2==0?cols:cols-1,null));
      for(int c=0;c<grid[r].length;c++){
        if(grid[r][c]!=null) continue;
        double gx=(c+(r%2==0?0.5:1.0))/cols; double gy=0.06+r*0.057;
        double d=sqrt(pow(sx-gx,2)+pow(sy-gy,2));
        if(d<bd){bd=d; br=r; bc=c;}
      }
    }
    grid[br][bc]=cur;
    pop(br,bc);
    setState((){
      shooting=false; cur=next; next=rand.nextInt(min(4 + level~/8, colors.length));
      if(grid.every((row)=>row.every((e)=>e==null))){ level++; score+=200; genLevel(); }
      // kalah kalau turun kebawah
      if(grid.length>13){ level=1; score=0; genLevel(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Game Over! Bola sampai bawah")));}
    });
  }

  void pop(int r,int c){
    int col = grid[r][c]!;
    Set<String> vis={}; List<GPos> group=[];
    void dfs(int rr,int cc){
      if(rr<0||rr>=grid.length||cc<0||cc>=grid[rr].length) return;
      if(grid[rr][cc]!=col) return;
      String k="$rr,$cc"; if(vis.contains(k)) return; vis.add(k); group.add(GPos(rr,cc));
      for(var n in neigh(rr,cc)) dfs(n.r,n.c);
    }
    dfs(r,c);
    if(group.length>=3){
      for(var p in group) grid[p.r][p.c]=null;
      score+=group.length*15;
      dropFloat();
    }
  }

  void dropFloat(){
    Set<String> conn={};
    void dfs2(int r,int c){
      if(r<0||r>=grid.length||c<0||c>=grid[r].length||grid[r][c]==null) return;
      String k="$r,$c"; if(conn.contains(k)) return; conn.add(k);
      for(var n in neigh(r,c)) dfs2(n.r,n.c);
    }
    for(int c=0;c<grid[0].length;c++) dfs2(0,c);
    for(int r=0;r<grid.length;r++) for(int c=0;c<grid[r].length;c++) if(grid[r][c]!=null &&!conn.contains("$r,$c")){ grid[r][c]=null; score+=10; }
  }

  List<GPos> neigh(int r,int c){
    int off = (r%2==0)?-1:1;
    return [GPos(r,c-1), GPos(r,c+1), GPos(r-1,c), GPos(r-1,c+off), GPos(r+1,c), GPos(r+1,c+off)];
  }

  @override
  Widget build(BuildContext context){
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFD8CBFF),
      body: GestureDetector(
        onPanUpdate: (d){
          setState((){
            cannonX = (d.globalPosition.dx/w).clamp(0.1, 0.9);
            double dx = d.globalPosition.dx - w*cannonX;
            double dy = d.globalPosition.dy - MediaQuery.of(context).size.height*0.88;
            angle = atan2(dy,dx);
            if(angle>-0.15) angle=-0.15; if(angle<-pi+0.15) angle=-pi+0.15;
          });
        },
        onTap: shoot,
        child: Stack(
          children: [
            Container(decoration: BoxDecoration(border: Border.all(color: Colors.white54, width: 2), borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.fromLTRB(8, 35, 8, 140)),
            // bubbles
            for(int r=0;r<grid.length;r++) for(int c=0;c<grid[r].length;c++) if(grid[r][c]!=null)
              Positioned(left: w*(c+(r%2==0?0.5:1.0))/cols - 19, top: 42 + r*38.5, child: bubble(colors[grid[r][c]!], 38)),
            if(shooting) Positioned(left: w*sx-19, top: MediaQuery.of(context).size.height*sy-19, child: bubble(colors[cur], 38)),
            CustomPaint(size: Size.infinite, painter: AimPaint(cannonX, angle, shooting)),
            // UI
            Positioned(top: 45, left: 15, child: chip("🏆 $score")),
            Positioned(top: 45, right: 15, child: chip("⛰️ Lv $level/2000")),
            Positioned(
              bottom: 0, left: 0, right: 0, child: Container(
                height: 135, decoration: const BoxDecoration(color: Color(0xFFEDE7FF), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(children: [
                  const SizedBox(height: 8),
                  const Text("2.000 LEVEL SERU", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFE0459E), letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Column(children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: colors[next], shape: BoxShape.circle)), const Text("NEXT", style: TextStyle(fontSize: 9))]),
                    const SizedBox(width: 20),
                    GestureDetector(onTap: shoot, child: bubble(colors[cur], 52)),
                  ]),
                  Text("Geser untuk arahkan • Tap untuk tembak", style: TextStyle(fontSize: 11, color: Colors.black54)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chip(String t)=>Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)));

  Widget bubble(Color c, double s){
    return Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white, c, c.withOpacity(0.8)], center: const Alignment(-0.3,-0.4), radius: 0.9), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1,2))], border: Border.all(color: Colors.white70, width: 1.5)),
      child: Container(margin: EdgeInsets.all(s*0.18), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.6))));
  }
}

class AimPaint extends CustomPainter {
  final double x, ang; final bool shooting;
  AimPaint(this.x,this.ang,this.shooting);
  @override void paint(Canvas canvas, Size size){
    if(shooting) return;
    var p=Paint()..color=Colors.yellowAccent..style=PaintingStyle.fill;
    double cx=size.width*x, cy=size.height*0.88;
    for(int i=1;i<14;i++){ double px=cx+cos(ang)*i*18; double py=cy+sin(ang)*i*18; if(py<45) break; canvas.drawCircle(Offset(px,py), i%2==0?5:3, p); }
  }
  @override bool shouldRepaint(covariant CustomPainter old)=>true;
}

class GPos{ final int r,c; GPos(this.r,this.c); }
