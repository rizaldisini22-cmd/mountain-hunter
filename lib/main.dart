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
  List nominal = [100, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000];

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
                      Text("1x Main = 30-50 Coin",
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("LANJUT"))
                  ],
                ));
      }
    });
  }

  Widget halamanTarik() {
    TextEditingController hp = TextEditingController();
    return Scaffold(
      appBar: AppBar(
          title: Text("Tukar Saldo Dana"),
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
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0081DF))),
                  SizedBox(height: 6),
                  Text("100 Coin = Rp 100 | 1x Main 30-50 Coin",
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
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
            Text("MINIMAL PENARIKAN:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: nominal.length,
                itemBuilder: (c, i) {
                  int n = nominal[i];
                  bool bisa = coin >= n;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            bisa? Color(0xFF0081DF) : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (!bisa) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Kurang ${n - coin} Coin! Main lagi ${((n - coin) / 40).ceil()}x")));
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Rp $n",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: bisa? Colors.white : Colors.black45)),
                        Text(bisa? "Bisa Tarik" : "Butuh $n Coin",
                            style: TextStyle(
                                fontSize: 10,
                                color: bisa? Colors.white70 : Colors.black45)),
                      ],
                    ),
                  );
                }),
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
