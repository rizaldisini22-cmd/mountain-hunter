import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: GameKu()));
}

class GameKu extends StatefulWidget {
  @override
  State createState() => SGame();
}

class SGame extends State {
  int coin = 0;
  int misi = 0;
  int totalMain = 0;
  int level = 1;
  List bubbles = [];
  Random r = Random();
  Timer? tm;
  List history = [];

  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    bubbles = [];
    int i = 0;
    while (i < 12) {
      bubbles.add({
        "x": r.nextDouble() * 300,
        "y": r.nextDouble() * 500 + 100,
        "c": Colors.primaries[r.nextInt(Colors.primaries.length)],
        "s": 45.0
      });
      i++;
    }
    tm?.cancel();
    tm = Timer.periodic(Duration(milliseconds: 50), (t) {
      if (!mounted) return;
      setState(() {
        for (var b in bubbles) {
          b["y"] = b["y"] - 1.2;
          if (b["y"] < -60) {
            b["y"] = 750.0;
            b["x"] = r.nextDouble() * 300;
          }
        }
        if (bubbles.length < 12) {
          if (r.nextDouble() > 0.9) {
            bubbles.add({
              "x": r.nextDouble() * 300,
              "y": 750.0,
              "c": Colors.primaries[r.nextInt(Colors.primaries.length)],
              "s": 45.0
            });
          }
        }
      });
    });
  }

  void tapBubble(int idx) {
    if (bubbles.length <= idx) return;
    setState(() {
      misi++;
      bubbles.removeAt(idx);
      bubbles.add({
        "x": r.nextDouble() * 300,
        "y": 750.0,
        "c": Colors.primaries[r.nextInt(Colors.primaries.length)],
        "s": 45.0
      });
      if (misi >= 20) {
        int dapat = 30 + r.nextInt(21);
        coin = coin + dapat;
        totalMain = totalMain + 1;
        misi = 0;
        level++;
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => AlertDialog(
                  title: Text("MISI SELESAI! 🎉"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Main ke-$totalMain"),
                      SizedBox(height: 8),
                      Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text("+$dapat Coin",
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.green))),
                      SizedBox(height: 8),
                      Text("Total: $coin Coin = Rp $coin"),
                      Text("30-50 Coin acak tiap main!",
                          style: TextStyle(fontSize: 11, color: Colors.orange)),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("MAIN LAGI"))
                  ],
                ));
      }
    });
  }

  Widget halamanTarik() {
    TextEditingController hp = TextEditingController();
    return Scaffold(
      appBar: AppBar(
          title: Text("Tarik - 1x Main 30-50 Coin"),
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
                  Text("TOTAL MAIN: $totalMain x | 1x = 30-50 Coin"),
                  Text("$coin Coin = Rp $coin",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0081DF))),
                  SizedBox(height: 8),
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: coin >= 100? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                          coin >= 100
                            ? "BISA TARIK Rp 100!"
                              : "Main ${3 - totalMain} x lagi bisa tarik",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextField(
                controller: hp,
                decoration: InputDecoration(
                    labelText: "No Dana 08xxx",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wallet)),
                keyboardType: TextInputType.phone),
            SizedBox(height: 16),
            Text("Pilih Nominal:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int n in [100, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000])
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            coin >= n? Color(0xFF0081DF) : Colors.grey.shade300),
                    onPressed: () {
                      if (coin < n) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Kurang ${n - coin} Coin!")));
                        return;
                      }
                      if (hp.text.length < 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Isi No Dana dulu!")));
                        return;
                      }
                      setState(() {
                        coin = coin - n;
                        history.insert(0, "Rp $n ke ${hp.text}");
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("SUKSES! Rp $n dikirim ke ${hp.text}"),
                          backgroundColor: Colors.green));
                    },
                    child: Text(coin >= n? "Rp $n" : "Rp $n",
                        style: TextStyle(
                            color: coin >= n? Colors.white : Colors.black45,
                            fontSize: 12)),
                  )
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            for (var h in history)
              ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(h, style: TextStyle(fontSize: 13)),
                  dense: true),
          ],
        ),
      ),
    );
  }

  void dispose() {
    tm?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Color(0xFF7DD3D8),
              Color(0xFF5AB9A8),
              Color(0xFF6DBF7B),
              Color(0xFF8B6D3A)
            ])),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text("🪙 $coin",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text("Main $totalMain x",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                          color: Color(0xFFFFEB3B),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text("Rp $coin",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              SizedBox(height: 8),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text("Misi $misi/20 | 1x Main = 30-50 Coin Acak",
                      style: TextStyle(color: Colors.white, fontSize: 11))),
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
                            width: bubbles[i]["s"],
                            height: bubbles[i]["s"],
                            decoration: BoxDecoration(
                                color: bubbles[i]["c"],
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2.5)),
                            child: Center(
                                child: Text("${20 - misi}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10))),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("1x Main = 30-50 Coin",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("$coin Coin = Rp $coin",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.green)),
                      ],
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0081DF)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => halamanTarik()));
                        },
                        child: Text("TUKAR DANA",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12))),
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
