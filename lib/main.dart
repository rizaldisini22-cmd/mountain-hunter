import 'dart:math';
import 'package:flutter/material.dart';
void main() => runApp(const TapDanaCuanApp());
class TapDanaCuanApp extends StatelessWidget {
  const TapDanaCuanApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'TAP DANA CUAN', home: const GameScreen());
  }
}
class Bubble {
  double x, y, speed; Color color; double size;
  Bubble({required this.x, required this.y, required this.speed, required this.color, this.size=60});
}
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}
class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  int coin = 486; int rupiah = 486;
  List<Bubble> bubbles = [];
  final Random rnd = Random();
  late AnimationController _controller;
  List<Color> colors = [Color(0xFFB983FF), Color(0xFFE85A5A), Color(0xFF6BCB77), Color(0xFFFFC93C), Color(0xFF4D96FF), Color(0xFFFFA500)];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 16))..repeat();
    _controller.addListener(_update);
    for(int i=0;i<15;i++) _spawnBubble();
  }
  void _spawnBubble(){
    if(bubbles.length>22) return;
    setState((){
      bubbles.add(Bubble(x: rnd.nextDouble()*0.85+0.02, y: 1.1+rnd.nextDouble()*0.5, speed: 0.003+rnd.nextDouble()*0.007, color: colors[rnd.nextInt(colors.length)], size: 52+rnd.nextDouble()*18));
    });
  }
  void _update(){
    if(!mounted) return;
    setState((){
      for(var b in bubbles) b.y -= b.speed;
      bubbles.removeWhere((b)=> b.y < -0.2);
      if(bubbles.length < 12) _spawnBubble();
    });
  }
  void _tapBubble(int index){
    // Simpan bubble yang di tap
    Bubble tapped = bubbles[index];
    setState(()=> bubbles.removeAt(index));
    _showAdReward();
  }

  void _showAdReward(){
    int bonus = 30 + rnd.nextInt(21); // 30-50
    showDialog(context: context, barrierDismissible: false, builder: (_)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.orange[100], shape: BoxShape.circle), child: Icon(Icons.play_circle_fill, size: 60, color: Colors.orange)),
        SizedBox(height: 15),
        Text('IKLAN SELESAI!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 8),
        Text('Tap = 1 Koin', style: TextStyle(fontSize: 14)),
        Text('Bonus Iklan = $bonus Koin', style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)), child: Text('+${1+bonus} KOIN', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green))),
      ]),
      actions: [SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: (){
          setState((){
            coin += 1 + bonus;
            rupiah += 1 + bonus;
          });
          Navigator.pop(context);
          _spawnBubble();
        },
        child: Text('AMBIL ${1+bonus} KOIN & LANJUT TAP!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ))],
    ));
  }

  void _showTukar(){
    showModalBottomSheet(context: context, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_){
      return Padding(padding: EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('TUKAR SALDO DANA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('Saldo: Rp $rupiah ($coin Koin)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        SizedBox(height: 10),
        _tile('Rp 100', 100), _tile('Rp 500', 500), _tile('Rp 1.000', 1000), _tile('Rp 5.000', 5000),
        Text('*Simulasi hiburan - Tiap tap ada iklan', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ]));
    });
  }
  Widget _tile(String label, int need){
    bool can = coin >= need;
    return Card(child: ListTile(
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('$need koin'),
      trailing: ElevatedButton(onPressed: can?(){setState((){coin-=need; rupiah-=need;}); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tarik $label berhasil!')));} : null, child: Text('Tarik')),
    ));
  }
  @override
  void dispose(){ _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7DE2FF), Color(0xFFB0F5B5)])),
        child: SafeArea(child: Column(children: [
          Padding(padding: EdgeInsets.all(10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.monetization_on, color: Colors.amber), SizedBox(width: 6), Text('$coin Koin', style: TextStyle(fontWeight: FontWeight.bold))])),
            Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('Rp $rupiah', style: TextStyle(fontWeight: FontWeight.bold))),
          ])),
          Container(margin: EdgeInsets.symmetric(horizontal: 10), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text('TAP = 1 KOIN + IKLAN = 30-50 KOIN | Tarik Rp 100 s/d 100RB', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500))),
          Expanded(child: LayoutBuilder(builder: (ctx, c)=> Stack(children: [
            for(int i=0;i<bubbles.length;i++) Positioned(
              left: bubbles[i].x*c.maxWidth, top: bubbles[i].y*c.maxHeight,
              child: GestureDetector(onTap: ()=>_tapBubble(i), child: Container(width: bubbles[i].size, height: bubbles[i].size, decoration: BoxDecoration(color: bubbles[i].color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(blurRadius: 5)]), child: Icon(Icons.touch_app, color: Colors.white))),
            )
          ]))),
          Container(margin: EdgeInsets.all(12), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TAP TERUS!', style: TextStyle(fontWeight: FontWeight.bold)), Text('Coin auto kesimpen', style: TextStyle(fontSize: 11, color: Colors.grey))]),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), onPressed: _showTukar, child: Text('TUKAR SALDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ])),
        ])),
      ),
    );
  }
}
