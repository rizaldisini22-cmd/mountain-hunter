import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MountainHunterApp());
}

class MountainHunterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mountain Hunter',
      theme: ThemeData(primarySwatch: Colors.green),
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  int coins = 0;
  int bestScore = 0;
  BannerAd? bannerAd;
  RewardedAd? rewardedAd;
  List<Widget> fallingCoins = [];
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadBanner();
    _loadRewarded();
  }

  void _loadBanner() {
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => rewardedAd = ad,
        onAdFailedToLoad: (e) {},
      ),
    );
  }

  void _tapMountain() {
    setState(() {
      coins++;
      if (coins > bestScore) bestScore = coins;
      _addFallingCoin();
    });
  }

  void _addFallingCoin() {
    final animController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    final animation = Tween(begin: 0.0, end: 300.0).animate(animController);
    animController.forward();
    setState(() {
      fallingCoins.add(
        AnimatedBuilder(
          animation: animation,
          builder: (c, child) => Positioned(
            left: random.nextDouble() * 300,
            top: animation.value,
            child: Text('🪙', style: TextStyle(fontSize: 30)),
          ),
        ),
      );
    });
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) setState(() => fallingCoins.removeAt(0));
    });
  }

  void _watchAdBonus() {
    if (rewardedAd!= null) {
      rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        setState(() => coins += 20);
        _loadRewarded();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Iklan belum siap, coba lagi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('MOUNTAIN HUNTER', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text('Koin: $coins', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text('Best: $bestScore', style: TextStyle(fontSize: 18)),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: _tapMountain,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(color: Colors.green[600], borderRadius: BorderRadius.circular(100), boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black26)]),
                    child: Center(child: Text('⛰️', style: TextStyle(fontSize: 100))),
                  ),
                ),
                SizedBox(height: 20),
                Text('TAP GUNUNGNYA!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _watchAdBonus,
                  icon: Icon(Icons.play_circle),
                  label: Text('Nonton Iklan +20 Koin'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                ),
              ],
            ),
          ),
         ...fallingCoins,
        ],
      ),
      bottomNavigationBar: bannerAd!= null? Container(height: 50, child: AdWidget(ad: bannerAd!)) : SizedBox(),
    );
  }
}
