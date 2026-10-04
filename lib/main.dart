import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: GamePage()));
}

class BubbleData {
  double x, y, dx, dy, size;
  Color color;
  BubbleData({required this.x, required this.y, required this.dx, required this.dy, required this.size, required this.color});
}

class GamePage extends StatefulWidget {
  @override _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<BubbleData> bubbles = [];
  int coin = 486, misi = 6, totalMain = 6, totalIklan = 0;
  Random rnd = Random();
  Timer? loop;
  RewardedAd? rewardedAd;

  // NANTI kalau Sheet sudah jadi, ganti URL disini
  final String SHEET_URL = "";

  List<Color> colors = [Color(0xFF2196F3), Color(0xFFFF9800), Color(0xFF4CAF50), Color(0xFFE91E63), Color(0xFF9C27B0)];

  @override
  void initState() {
    super.initState();
    loadData();
    spawnBubbles();
    loadAd();
    loop = Timer.periodic(Duration(milliseconds: 16), (t) {
      if (!mounted) return;
      setState(() {
        for (var b in bubbles) {
          b.x += b.dx; b.y += b.dy;
          if (b.x <= 0 || b.x >= 1) b.dx *= -1;
          if (b.y <= 0.15 || b.y >= 0.88) b.dy *= -1;
        }
      });
    });
  }

  void loadAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => rewardedAd = ad,
        onAdFailedToLoad: (_) => Future.delayed(Duration(seconds: 3), loadAd),
      ),
    );
  }

  void loadData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      coin = p.getInt('coin') ?? 486;
      misi = p.getInt('misi') ?? 6;
      totalMain = p.getInt('total') ?? 6;
      totalIklan = p.getInt('iklan') ?? 0;
    });
  }

  void saveData() async {
    final p = await SharedPreferences.getInstance();
    p.setInt('coin', coin); p.setInt('misi', misi); p.setInt('total', totalMain); p.setInt('iklan', totalIklan);
  }

  void spawnBubbles() {
    bubbles.clear();
    for (int i = 0; i < 12; i++) {
      bubbles.add(BubbleData(
        x: rnd.nextDouble(), y: rnd.nextDouble() * 0.6 + 0.2,
        dx: (rnd.nextDouble() - 0.5) * 0.012, dy: (rnd.nextDouble() - 0.5) * 0.012,
        size: 55 + rnd.nextDouble() * 25, color: colors[rnd.nextInt(colors.length)]));
    }
  }

  void popBubble(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      coin += 1; // 1 KLIK = 1 COIN
      bubbles.removeAt(index);
      saveData();
      if (bubbles.isEmpty) {
        totalMain++; misi++; if (misi > 20) misi = 1;
        _showBonus();
      }
    });
  }

  void _showBonus() {
    int bonus = 30 + rnd.nextInt(21); // 30-50
    void kasihBonus() {
      setState(() { coin += bonus; totalIklan++; spawnBubbles(); saveData(); });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎉 HABIS! +$bonus Coin Bonus!'), backgroundColor: Colors.green));
    }
    if (rewardedAd != null) {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) { ad.dispose(); loadAd(); kasihBonus(); },
        onAdFailedToShowFullScreenContent: (ad, e) { ad.dispose(); loadAd(); kasihBonus(); },
      );
      rewardedAd!.show(onUserEarnedReward: (a, r) {});
      rewardedAd = null;
    } else {
      kasihBonus(); loadAd();
    }
  }

  @override void dispose() { loop?.cancel(); rewardedAd?.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7DD8C6), Color(0xFF8ED081)])),
        child: Stack(children: [
          Positioned(top: 40, left: 12, right: 12, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('🪙 $coin', style: TextStyle(fontWeight: FontWeight.bold))),
            Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('Misi $misi/20', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Color(0xFFFFEB3B), borderRadius: BorderRadius.circular(20)), child: Text('Rp $coin', style: TextStyle(fontWeight: FontWeight.bold))),
          ])),
          Positioned(top: 80, left: 0, right: 0, child: Center(child: Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: Text('1 Klik = 1 Coin | Clear = Bonus 30-50', style: TextStyle(color: Colors.white, fontSize: 10))))),
          ...bubbles.asMap().entries.map((e) => Positioned(
            left: e.value.x * (size.width - e.value.size), top: e.value.y * size.height,
            child: GestureDetector(onTap: () => popBubble(e.key), child: Container(width: e.value.size, height: e.value.size, decoration: BoxDecoration(color: e.value.color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]), child: Icon(Icons.touch_app, color: Colors.white70, size: 20))),
          )),
          Positioned(bottom: 20, left: 12, right: 12, child: Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Main $totalMain x\nIklan $totalIklan x', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TukarPage(coin: coin, totalIklan: totalIklan, sheetUrl: SHEET_URL, onTukar: (c) { setState(() { coin = c; }); saveData(); }))), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: StadiumBorder()), child: Text('TUKAR SALDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))
          ]))),
        ]),
      ),
    );
  }
}

class TukarPage extends StatefulWidget {
  final int coin, totalIklan; final String sheetUrl; final Function(int) onTukar;
  TukarPage({required this.coin, required this.totalIklan, required this.sheetUrl, required this.onTukar});
  @override _TukarPageState createState() => _TukarPageState();
}

class _TukarPageState extends State<TukarPage> {
  late int coin; TextEditingController danaCtrl = TextEditingController(); List<String> riwayat = []; bool loading = false;
  @override void initState() { super.initState(); coin = widget.coin; }
  void tukar(int n) async {
    if (coin < n) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saldo kurang!'), backgroundColor: Colors.red)); return; }
    if (danaCtrl.text.length < 10) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Isi No DANA dulu!'))); return; }
    setState(() => loading = true);
    // Kirim ke Sheet kalau URL sudah diisi, kalau belum tetap jalan lokal
    if (widget.sheetUrl.isNotEmpty && widget.sheetUrl.startsWith('http')) {
      try {
        await http.post(Uri.parse(widget.sheetUrl), headers: {"Content-Type": "application/json"},
          body: jsonEncode({"tanggal": "${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}", "no_dana": danaCtrl.text, "jumlah": "Rp $n", "coin_sisa": "${coin - n}", "total_iklan": "${widget.totalIklan}x"}));
      } catch (e) {}
    }
    setState(() { coin -= n; riwayat.insert(0, 'Rp $n ke ${danaCtrl.text}'); loading = false; });
    widget.onTukar(coin);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Rp $n Berhasil!'), backgroundColor: Colors.green));
    danaCtrl.clear();
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Tukar DANA'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Color(0xFFFFEB3B), borderRadius: BorderRadius.circular(12)), child: Text('Saldo: Rp $coin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        SizedBox(height: 12), TextField(controller: danaCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'No DANA 08xxx', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), prefixIcon: Icon(Icons.phone))),
        SizedBox(height: 12),
        Expanded(child: ListView(children: [for (int i in [100, 500, 1000, 5000]) Card(child: ListTile(title: Text('Tarik Rp $i'), trailing: loading ? CircularProgressIndicator() : ElevatedButton(onPressed: () => tukar(i), child: Text('TUKAR')))) ])),
      ])),
    );
  }
}
