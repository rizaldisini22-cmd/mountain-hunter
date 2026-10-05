import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const GoldMinerApp());
}

class GoldMinerApp extends StatelessWidget {
  const GoldMinerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int coins = 0;
  int totalTap = 0;
  int level = 1;
  double miningPower = 1;
  List<Offset> floatCoins = [];

  BannerAd? bannerAd;
  RewardedAd? rewardedAd;
  InterstitialAd? interstitialAd;
  int tapCountForInter = 0;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _bounceAnim = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeOut));
    loadData();
    loadAds();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins')?? 486;
      level = prefs.getInt('level')?? 1;
      miningPower = prefs.getDouble('power')?? 1;
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('coins', coins);
    prefs.setInt('level', level);
    prefs.setDouble('power', miningPower);
  }

  void loadAds() {
    BannerAd(adUnitId: 'ca-app-pub-3940256099942544/6300978111', size: AdSize.banner, request: AdRequest(), listener: BannerAdListener()).load().then((ad) {}); // simplified
    bannerAd = BannerAd(adUnitId: 'ca-app-pub-3940256099942544/6300978111', size: AdSize.banner, request: AdRequest(), listener: BannerAdListener(onAdLoaded: (ad)=>setState((){})))..load();

    RewardedAd.load(adUnitId: 'ca-app-pub-3940256099942544/5224354917', request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad)=>rewardedAd=ad, onAdFailedToLoad: (e)=>{}));
    InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/1033173712', request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad)=>interstitialAd=ad, onAdFailedToLoad: (e)=>{}));
  }

  void onTapMine(Offset pos) {
    _bounceController.forward().then((_)=>_bounceController.reverse());
    setState(() {
      int earn = miningPower.toInt();
      coins += earn;
      totalTap++;
      tapCountForInter++;
      floatCoins.add(pos);
    });
    saveData();
    Future.delayed(Duration(milliseconds: 800), ()=>setState(()=>floatCoins.removeAt(0)));

    // Setiap 10 tap muncul kesempatan iklan rewarded 30-50 koin
    if(totalTap % 10 == 0) showRewardChest();

    // Interstitial tiap 25 tap biar aman AdMob
    if(tapCountForInter >= 25 && interstitialAd!= null){
      interstitialAd!.show();
      tapCountForInter = 0;
      InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/1033173712', request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad)=>interstitialAd=ad, onAdFailedToLoad: (e)=>{}));
    }
  }

  void showRewardChest(){
    showDialog(context: context, builder: (c)=>AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('🎉 PETI HARTA DITEMUKAN!'),
      content: Text('Nonton iklan 15 detik untuk dapat 30-50 koin bonus!'),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(c), child: Text('Nanti')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: (){
            Navigator.pop(c);
            if(rewardedAd!= null){
              rewardedAd!.show(onUserEarnedReward: (ad, r){
                int bonus = 30 + Random().nextInt(21);
                setState(()=>coins+=bonus);
                saveData();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dapat bonus +$bonus koin!')));
              });
              RewardedAd.load(adUnitId: 'ca-app-pub-3940256099942544/5224354917', request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad)=>rewardedAd=ad, onAdFailedToLoad: (e)=>{}));
            }
          },
          child: Text('TONTON IKLAN +30-50', style: TextStyle(color: Colors.white)),
        )
      ],
    ));
  }

  void buyUpgrade(){
    if(coins >= level*100){
      setState((){coins-=level*100; level++; miningPower+=0.5;});
      saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Background tambang
          Container(
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF16213E), Color(0xFF0F3460), Color(0xFF1A1A2E)])),
          ),
          // Header
          SafeArea(child: Padding(padding: EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: EdgeInsets.symmetric(horizontal:16, vertical:8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)), child: Row(children:[Icon(Icons.monetization_on, color: Colors.amber), SizedBox(width:6), Text('$coins', style: TextStyle(fontWeight: FontWeight.bold, fontSize:16))])),
            Container(padding: EdgeInsets.symmetric(horizontal:16, vertical:8), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(30)), child: Text('LV $level • Power x${miningPower.toStringAsFixed(1)}', style: TextStyle(fontWeight: FontWeight.bold))),
          ]))),

          // Area Game
          Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('TAP UNTUK MENAMBANG!', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
              SizedBox(height: 20),
              ScaleTransition(
                scale: _bounceAnim,
                child: GestureDetector(
                  onTapDown: (d)=>onTapMine(d.globalPosition),
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 6), boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 30, spreadRadius: 10)]),
                    child: Icon(Icons.diamond, size: 90, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('+${miningPower.toInt()} koin / tap', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ]),
          ),

          // Floating +1 animation
         ...floatCoins.map((p)=>Positioned(left: p.dx, top: p.dy-20, child: TweenAnimationBuilder<double>(tween: Tween(begin:0,end:1), duration: Duration(milliseconds:800), builder:(c,v,child){return Opacity(opacity: 1-v, child: Transform.translate(offset: Offset(0,-v*50), child: Text('+${miningPower.toInt()}', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize:18))));}))),

          // Bottom Menu kayak game umum
          Positioned(bottom: 0, left:0, right:0, child: Column(children:[
            if(bannerAd!=null) Container(height:60, color: Colors.black, child: AdWidget(ad: bannerAd!)),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
              child: Row(children:[
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Upgrade Beliung', style:TextStyle(fontWeight: FontWeight.bold)), Text('Harga: ${level*100} koin • Auto power +0.5', style:TextStyle(fontSize:11, color: Colors.grey))]) ),
                ElevatedButton(onPressed: buyUpgrade, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F3460), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Text('BELI', style: TextStyle(color: Colors.white))),
                SizedBox(width: 10),
                ElevatedButton(onPressed: showRewardChest, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Text('PETI +30-50', style: TextStyle(color: Colors.white, fontSize: 11))),
              ]),
            )
          ]))
        ],
      ),
    );
  }
}
