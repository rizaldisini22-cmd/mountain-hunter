import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(BubbleCuanV2());

class BubbleCuanV2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bubble DANA Cuan V2',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GamePage(),
    );
  }
}

class BubbleData {
  double x, y, dx, dy, size;
  Color color;
  bool popped = false;
  BubbleData({required this.x, required this.y, required this.dx, required this.dy, required this.size, required this.color});
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  List<BubbleData> bubbles = [];
  int coin = 0;
  int misi = 0;
  int totalMain = 0;
  final player = AudioPlayer();
  Random rnd = Random();
  Timer? gameLoop;
  List<String> riwayat = [];

  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.pink];

  @override
  void initState() {
    super.initState();
    loadData();
    spawnBubbles();
    // Game loop 60fps biar bubble terbang
    gameLoop = Timer.periodic(Duration(milliseconds: 16), (t) {
      setState(() {
        for (var b in bubbles) {
          b.x += b.dx;
          b.y += b.dy;
          // pantul dinding
          if (b.x <= 0 || b.x >= 1) b.dx *= -1;
          if (b.y <= 0.15 || b.y >= 0.85) b.dy *= -1;
        }
      });
    });
  }

  void loadData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      coin = p.getInt('coin')?? 0;
      misi = p.getInt('misi')?? 0;
      totalMain = p.getInt('total')?? 0;
      riwayat = p.getStringList('riwayat')?? [];
    });
  }

  void saveData() async {
    final p = await SharedPreferences.getInstance();
    p.setInt('coin', coin);
    p.setInt('misi', misi);
    p.setInt('total', totalMain);
    p.setStringList('riwayat', riwayat);
  }

  void spawnBubbles() {
    bubbles.clear();
    for (int i = 0; i < 12; i++) {
      bubbles.add(BubbleData(
        x: rnd.nextDouble(),
        y: rnd.nextDouble() * 0.6 + 0.15,
        dx: (rnd.nextDouble() - 0.5) * 0.015,
        dy: (rnd.nextDouble() - 0.5) * 0.015,
        size: 55 + rnd.nextDouble() * 25,
        color: colors[rnd.nextInt(colors.length)],
      ));
    }
  }

  void popBubble(int index) async {
    HapticFeedback.mediumImpact();
    // Suara POP (pakai beep system kalau gak ada file)
    try {
      await player.play(AssetSource('pop.mp3'));
    } catch (_) {}

    setState(() {
      coin += 3 + rnd.nextInt(5); // 3-7 coin per bubble
      bubbles.removeAt(index);
      if (bubbles.isEmpty) {
        misi++;
        totalMain++;
        spawnBubbles();
        if (misi >= 20) misi = 0;
        saveData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎉 MISI SELESAI! +30 Coin Bonus!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
        );
        coin += 30;
      }
      saveData();
    });
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7DD8C6), Color(0xFF5AC8A0), Color(0xFF8ED081)])
        ),
        child: Stack(
          children: [
            // TOP BAR
            Positioned(
              top: 35, left: 15, right: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pill('🪙 $coin', Colors.white),
                  _pill('Misi $misi/20', Colors.white, bold: true),
                  _pill('Rp $coin', Color(0xFFFFEB3B)),
                ],
              ),
            ),
            Positioned(
              top: 80, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text('1x Main = 30-50 Coin | Tarik Rp 100 s/d 100RB', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
            // BUBBLE TERBANG
           ...bubbles.asMap().entries.map((e) {
              int idx = e.key;
              BubbleData b = e.value;
              return Positioned(
                left: b.x * (size.width - b.size),
                top: b.y * size.height,
                child: GestureDetector(
                  onTap: () => popBubble(idx),
                  child: Container(
                    width: b.size, height: b.size,
                    decoration: BoxDecoration(
                      color: b.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0,3))],
                    ),
                    child: Icon(Icons.touch_app, color: Colors.white, size: b.size * 0.5),
                  ),
                ),
              );
            }).toList(),
            // BOTTOM BAR
            Positioned(
              bottom: 20, left: 15, right: 15,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Main $totalMain x\nCoin kesimpen otomatis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TukarPage(coin: coin, riwayat: riwayat, onTukar: (c, r) {
                        setState(() { coin = c; riwayat = r; saveData(); });
                      }))),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: StadiumBorder(), padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12)),
                      child: Text('TUKAR SALDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, {bool bold = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Text(text, style: TextStyle(fontWeight: bold? FontWeight.bold : FontWeight.w600, fontSize: 14)),
    );
  }
}

class TukarPage extends StatefulWidget {
  final int coin; final List<String> riwayat; final Function(int, List<String>) onTukar;
  TukarPage({required this.coin, required this.riwayat, required this.onTukar});
  @override
  _TukarPageState createState() => _TukarPageState();
}

class _TukarPageState extends State<TukarPage> {
  TextEditingController danaCtrl = TextEditingController();
  late int coin; late List<String> riwayat;
  @override
  void initState() { super.initState(); coin = widget.coin; riwayat = widget.riwayat; }
  void tukar(int nominal) {
    if (coin < nominal) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saldo kurang! Main lagi'), backgroundColor: Colors.red));
      return;
    }
    if (danaCtrl.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Isi No DANA dulu!')));
      return;
    }
    setState(() {
      coin -= nominal;
      String log = 'Rp $nominal ke ${danaCtrl.text} - ${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2,'0')}';
      riwayat.insert(0, log);
    });
    widget.onTukar(coin, riwayat);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Berhasil tarik Rp $nominal!'), backgroundColor: Colors.green));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tukar Saldo DANA - Bubble C...'), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Text('SALDO: $coin Coin = Rp $coin', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 22)),
                SizedBox(height: 4),
                Text('Tersimpan otomatis, gak hilang walau tutup APK', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
            SizedBox(height: 16),
            TextField(controller: danaCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(prefixIcon: Icon(Icons.account_balance_wallet), hintText: 'No DANA 08xxx', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            SizedBox(height: 16),
            Text('PILIH NOMINAL:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.5,
              children: [100,500,1000,2000,5000,10000,20000,50000,100000].map((n) => ElevatedButton(onPressed: () => tukar(n), style: ElevatedButton.styleFrom(backgroundColor: coin >= n? Colors.blue : Colors.grey[300], foregroundColor: coin >= n? Colors.white : Colors.grey, shape: StadiumBorder()), child: Text('Rp $n', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
            ),
            SizedBox(height: 20), Divider(),
            Text('RIWAYAT PENARIKAN:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
           ...riwayat.map((r) => Container(margin: EdgeInsets.only(bottom: 8), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Expanded(child: Text(r, style: TextStyle(fontSize: 13)))]))).toList(),
            if (riwayat.isEmpty) Text('Belum ada penarikan', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
