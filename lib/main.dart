import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bubble Cuan',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const BubbleGame(),
    );
  }
}

class BubbleGame extends StatefulWidget {
  const BubbleGame({super.key});
  @override
  State<BubbleGame> createState() => _BubbleGameState();
}

class _BubbleGameState extends State<BubbleGame> {
  int coins = 0;
  BannerAd? bannerAd;
  @override
  void initState() {
    super.initState();
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E7A0D),
      appBar: AppBar(title: Text('Bubble Cuan - Rp $coins'), backgroundColor: Colors.green[800]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tap Bubble Dapat Cuan!', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => setState(() => coins += 10),
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(color: Colors.yellow, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                child: const Center(child: Text('Rp', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bannerAd!= null? SizedBox(height: bannerAd!.size.height.toDouble(), child: AdWidget(ad: bannerAd!)) : null,
    );
  }
}
