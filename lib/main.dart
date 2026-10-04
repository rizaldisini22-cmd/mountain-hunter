import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Bubble DANA Cuan",
    home: GameKu()));
}

class GameKu extends StatefulWidget {
  @override
  State<GameKu> createState() => _SGame();
}

class _SGame extends State<GameKu> {
  int coin = 0;
  int misi = 0;
  int totalMain = 0;
  List<Map<String, dynamic>> bubbles = [];
  Random r = Random();
  Timer? tm;
  List<String> history = [];
  List<int> nominal = [100, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000];
  List<Color> warna = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink, Colors.teal, Colors.amber];

  @override
  void initState() {
    super.initState();
    loadData();
    startGame();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coin = prefs.getInt('coin')?? 0;
      totalMain = prefs.getInt('totalMain')?? 0;
      history = prefs.getStringList('history')?? [];
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coin', coin);
    await prefs.setInt('totalMain', totalMain);
    await prefs.setStringList('history', history);
  }

  void startGame() {
    bubbles.clear();
    for (int i = 0; i < 12; i++) {
      bubbles.add({
        "x": r.nextDouble() * 300,
        "y": r.nextDouble() * 500 + 100,
        "c": warna[r.nextInt(warna.length)],
      });
    }
    tm?.cancel();
    tm = Timer.periodic(Duration(milliseconds: 50), (t) {
      if (!mounted) return;
      setState(() {
        for (int j = 0; j < bubbles.length; j++) {
          bubbles[j]["y"] = bubbles[j]["y"] - 1.5;
          if (bubbles[j]["y"] < -50) {
            bubbles[j]["y"] = 700.0;
            bubbles[j]["x"] = r.nextDouble() * 300;
          }
        }
      });
    });
  }

  void tapBubble(int idx) {
    setState(() {
      misi++;
      bubbles[idx]["y"] = 700.0;
      bubbles[idx]["x"] = r.nextDouble() * 300;
      bubbles[idx]["c"] = warna[r.nextInt(warna.length)];
      if (misi >= 20) {
        int dapat = 30 + r.nextInt(21);
        coin += dapat;
        totalMain++;
        misi = 0;
        saveData();
        showDialog(
            context: context,
            builder: (c) => AlertDialog(
                  title: Text("MISI SELESAI! 🎉"),
                  content: Text("+$dapat Coin! Main ke-$totalMain\n1x Main = 30-50 Coin\nSaldo sekarang Rp $coin",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  actions: [
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("LANJUT MAIN"))
                  ],
                ));
      }
    });
  }

  Widget halamanTarik() {
    TextEditingController hp = TextEditingController();
    return StatefulBuilder(builder: (context, setS) {
      return Scaffold(
        appBar: AppBar(
            title: Text("Tukar Saldo DANA - Bubble Cuan"),
            backgroundColor: Color(0xFF0081DF),
            foregroundColor: Colors.white),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Text("SALDO: $coin Coin = Rp $coin",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0081DF)), textAlign: TextAlign.center),
                    SizedBox(height: 4),
                    Text("Tersimpan otomatis, gak hilang walau tutup APK",
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                  controller: hp,
                  decoration: InputDecoration(
                      labelText: "No DANA 08xxx",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.wallet)),
                  keyboardType: TextInputType.phone),
              SizedBox(height: 16),
              Text("PILIH NOMINAL:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: nominal.length,
                  itemBuilder: (c, i) {
                    int n = nominal[i];
                    bool bisa = coin >= n;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: bisa? Color(0xFF0081DF) : Colors.grey.shade300),
                      onPressed: () {
                        if (!bisa) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Butuh ${n - coin} coin lagi")));
                          return;
                        }
                        if (hp.text.length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Isi No DANA dulu")));
                          return;
                        }
                        setState(() {
                          coin -= n;
                          history.insert(0, "Rp $n ke ${hp.text} - ${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}");
                        });
                        saveData();
                        setS(() {});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SUKSES Rp $n ke ${hp.text}"), backgroundColor: Colors.green));
                      },
                      child: Text("Rp $n", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: bisa? Colors.white : Colors.black45)),
                    );
                  }),
              SizedBox(height: 20),
              Divider(),
              Text("RIWAYAT PENARIKAN:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              if (history.isEmpty) Text("Belum ada penarikan", style: TextStyle(color: Colors.grey, fontSize: 12)),
              for (int k = 0; k < history.length; k++)
                Card(
                  child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text(history[k], style: TextStyle(fontSize: 12)),
                      dense: true),
                ),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    tm?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7DD3D8), Color(0xFF5AB9A8), Color(0xFF6DBF7B)])),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text("🪙 $coin", style: TextStyle(fontWeight: FontWeight.bold))),
                  Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text("Misi $misi/20", style: TextStyle(fontWeight: FontWeight.bold))),
                  Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Color(0xFFFFEB3B), borderRadius: BorderRadius.circular(20)), child: Text("Rp $coin", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              SizedBox(height: 8),
              Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Text("1x Main = 30-50 Coin | Tarik Rp 100 s/d 100RB", style: TextStyle(color: Colors.white, fontSize: 11))),
              Expanded(
                child: Stack(
                  children: [
                    for (int i = 0; i < bubbles.length; i++)
                      Positioned(
                        left: bubbles[i]["x"],
                        top: bubbles[i]["y"],
                        child: GestureDetector(
                          onTap: () => tapBubble(i),
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(color: bubbles[i]["c"], shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                            child: Icon(Icons.touch_app, color: Colors.white),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Main $totalMain x\nCoin kesimpen otomatis", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0081DF)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => halamanTarik()));
                        },
                        child: Text("TUKAR SALDO", style: TextStyle(color: Colors.white))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
