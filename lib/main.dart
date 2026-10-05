import 'dart:async';
import 'dart:math';
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
      title: 'Bubble Cuan PRO',
      home: const BubbleGamePro(),
    );
  }
}

class Bubble {
  double x, y, size, speed;
  Color color;
  Bubble({required this.x, required this.y, required this.size, required this.speed, required this.color});
}

class BubbleGamePro extends StatefulWidget {
  const BubbleGamePro({super.key});
  @override
  State<BubbleGamePro> createState() => _BubbleGameProState();
}

class _BubbleGameProState extends State<BubbleGamePro> {
  int coins = 0;
  int combo = 0;
  List<Bubble> bubbles = [];
  Random rand = Random();
  Timer? spawnTimer;
  Timer? gameLoop;
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;

  @override
  void initState() {
    super.initState();
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
    loadInterstitial();
    spawnTimer = Timer.periodic(const Duration(milliseconds: 600), (_) => spawnBubble());
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) => updateBubbles());
  }

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => interstitialAd = ad,
        onAdFailedToLoad: (e) => print('gagal load $e'),
      ),
    );
  }

  void spawnBubble() {
    if (bubbles.length > 15) return;
    setState(() {
      bubbles.add(Bubble(
        x: rand.nextDouble(),
        y: 1.1,
        size: 50 + rand.nextDouble() * 70,
        speed: 0.002 + rand.nextDouble() * 0.008,
        color: [Colors.yellow, Colors.cyan, Colors.pink, Colors.lime, Colors.orange][rand.nextInt(5)],
      ));
    });
  }

  void updateBubbles() {
    setState(() {
      for (var b in bubbles) b.y -= b.speed;
      bubbles.removeWhere((b) => b.y < -0.2);
    });
  }

  void popBubble(int index) {
    setState(() {
      coins += 10;
      combo++;
      bubbles.removeAt(index);
    });

    // TIAP 20 KOIN MUNCUL IKLAN
    if (coins % 20 == 0 && coins != 0) {
      if (interstitialAd != null) {
        interstitialAd!.show();
        loadInterstitial(); // load lagi buat next
      }
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => combo = 0);
    });
  }

  @override
  void dispose() {
    spawnTimer?.cancel();
    gameLoop?.cancel();
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0E7A0D), Color(0xFF1B5E20)]),
        ),
        child: Stack(
          children: [
            SafeArea
