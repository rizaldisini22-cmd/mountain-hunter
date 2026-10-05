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
    return MaterialApp(debugShowCheckedModeBanner: false, home: const BubbleCuanVideo());
  }
}

class Bubble {
  double x, y, size, speed, wobble;
  Color color;
  Bubble({required this.x, required this.y, required this.size, required this.speed, required this.color, required this.wobble});
}

class BubbleCuanVideo extends StatefulWidget {
  const BubbleCuanVideo({super.key});
  @override
  State<BubbleCuanVideo> createState() => _BubbleCuanVideoState();
}

class _BubbleCuanVideoState extends State<BubbleCuanVideo> {
  int coins = 486;
  int misi = 6;
  List<Bubble> bubbles = [];
  Random rand = Random();
  Timer? spawnTimer;
  Timer? loopTimer;
  BannerAd? bannerAd;
  RewardedAd? rewardedAd;
  bool isAdLoading = false;

  final List<Color> colors = [
    Color(0xFFFFC107), Color(0xFF4CAF50), Color(0xFFE91E63),
    Color(0xFF03A9F4), Color(0xFF9C27B0), Color(0xFFFF5722),
  ];

  @override
  void initState() {
    super.initState();
    bannerAd = BannerAd(adUnitId: 'ca-app-pub-3940256099942544/6300978111', size: AdSize.banner, request: const AdRequest(), listener: const BannerAdListener())..load();
    loadRewarded();
    for (int i = 0; i
