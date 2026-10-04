import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: FruitGame()));

class FruitGame extends StatefulWidget {
  const FruitGame({super.key});
  @override State<FruitGame> createState() => _FruitGameState();
}

class _FruitGameState extends State<FruitGame> {
  int emas = 4732;
  int score = 0;
  List<Map> fruits = [];
  Random rand = Random();

  @override
  void initState() {
    super.initState();
    spawnFruit();
  }

  void spawnFruit() {
    Future.delayed(Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        fruits.add({
          "x": rand.nextDouble() * 300,
          "y": 600.0,
          "type": ["🍍","🥥","🥭","🍊","🥝"][rand.nextInt(5)],
          "speed": 4 + rand.nextDouble()*4,
        });
      });
      if (fruits.length < 8) spawnFruit();
    });
  }

  void potongBuah(int i){
    setState(() {
      score += 10;
      emas += 15;
      fruits.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background game
          Container(color: Color(0xFF87CEEB)),
          // Buah jatuh
         ...fruits.asMap().entries.map((e){
            int i = e.key;
            var f = e.value;
            return Positioned(
              left: f["x"], top: f["y"],
              child: GestureDetector(
                onTap: () => potongBuah(i),
                child: Text(f["type"], style: TextStyle(fontSize: 50)),
              ),
            );
          }),
          // UI Atas
          SafeArea(child: Column(children: [
            Container(margin: EdgeInsets.all(12), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [
              Text("🍍 Fruit blast Dana", style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Container(padding: EdgeInsets.symmetric(horizontal:10,vertical:4), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)), child: Text("$emas Emas", style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(width:8),
              ElevatedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> TarikDanaOnly(coins: emas, onTarik: (newEmas){setState(()=> emas=newEmas);}))), child: Text("Tarik"), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF118EEA), foregroundColor: Colors.white)),
            ])),
            Spacer(),
            Text("TAP BUAH UNTUK POTONG! 🍉", style: TextStyle(fontWeight: FontWeight.w900, fontSize:18, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
            SizedBox(height: 20),
            Text("Score: $score", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 80),
          ]))
        ],
      ),
    );
  }
}

// === HALAMAN TARIK DANA KAKAK TADI (UDAH SAYA HUBUNGIN) ===
class TarikDanaOnly extends StatefulWidget {
  final int coins; final Function(int) onTarik;
  const TarikDanaOnly({super.key, required this.coins, required this.onTarik});
  @override State<TarikDanaOnly> createState() => _TarikOnly();
}
class _TarikOnly extends State<TarikDanaOnly> {
  late int cur; String noDana = "";
  @override void initState(){super.initState(); cur=widget.coins;}
  final List<Map<String, dynamic>> list = [
    {"rp": 50, "emas": 2950, "limit": "10 Kali/Hari"},
    {"rp": 100, "emas": 5900, "limit": "15 Kali/Hari"},
    {"rp": 300, "emas": 17700, "limit": "15 Kali/Hari"},
    {"rp": 1000, "emas": 59000, "limit": "5 Kali/Hari"},
    {"rp": 5000, "emas": 295000, "limit": "5 Kali/Hari"},
    {"rp": 10000, "emas": 590000, "limit": "1 Kali/Hari"},
    {"rp": 30000, "emas": 1770000, "limit": "1 Kali/Hari"},
  ];
  @override Widget build(BuildContext context){
    double rp = cur / 59.0;
    return Scaffold(backgroundColor: Color(0xFF8B5A2B), appBar: AppBar(title: Text("Fruit blast Dana - Tarik"), backgroundColor: Color(0xFF8B5A2B)), body: SafeArea(child: Column(children: [
      Container(margin: EdgeInsets.all(12), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Color(0xFFFFF3A0), borderRadius: BorderRadius.circular(16)), child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("≈ Rp${rp.toStringAsFixed(0)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Text("$cur Emas", style: TextStyle(fontWeight: FontWeight.bold))]),
        Spacer(), Text("Fruit blast Dana\n🇮🇩", textAlign: TextAlign.center),
      ])),
      Expanded(child: GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.6, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: list.length, itemBuilder: (c,i){var it=list[i]; bool bisa=cur>=it["emas"]; return InkWell(onTap: bisa?(){setState(()=> cur-=it["emas"] as int); widget.onTarik(cur); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SUKSES Tarik Rp${it["rp"]}"), backgroundColor: Colors.green));}: null, child: Container(decoration: BoxDecoration(color: Color(0xFFFFF8B0), borderRadius: BorderRadius.circular(16), border: Border.all(color: bisa? Colors.green: Colors.grey)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Rp${it["rp"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text("${it["emas"]} Emas", style: TextStyle(fontSize: 10)), SizedBox(height:6), Container(padding: EdgeInsets.symmetric(horizontal:10,vertical:4), decoration: BoxDecoration(color: bisa? Colors.amber: Colors.grey, borderRadius: BorderRadius.circular(10)), child: Text(it["limit"], style: TextStyle(fontSize:9)))])));})),
    ])));
  }
}
