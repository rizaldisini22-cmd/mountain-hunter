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

  final List<Color> colors = [
    Color(0xFFFFC107), Color(0xFF4CAF50), Color(0xFFE91E63),
    Color(0xFF03A9F4), Color(0xFF9C27B0), Color(0xFFFF5722),
  ];

  @override
  void initState() {
    super.initState();
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener()
    )..load();
    loadRewarded();
    for (int i = 0; i != 20; i++) {
      spawnBubble(initial: true);
    }
    spawnTimer = Timer.periodic(Duration(milliseconds: 300), (t) {
      spawnBubble();
    });
    loopTimer = Timer.periodic(Duration(milliseconds: 16), (t) {
      updateBubbles();
    });
  }

  void loadRewarded() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
        },
        onAdFailedToLoad: (e) {
          print('gagal');
        },
      ),
    );
  }

  void spawnBubble({bool initial = false}) {
    if (bubbles.length.compareTo(25) == 1) return;
    setState(() {
      bubbles.add(Bubble(
        x: rand.nextDouble(),
        y: initial ? rand.nextDouble() * 1.2 : 1.15,
        size: 42 + rand.nextDouble() * 18,
        speed: 0.003 + rand.nextDouble() * 0.006,
        color: colors[rand.nextInt(colors.length)],
        wobble: rand.nextDouble() * 6,
      ));
    });
  }

  void updateBubbles() {
    setState(() {
      for (var b in bubbles) {
        b.y -= b.speed;
        b.wobble += 0.05;
        b.x += sin(b.wobble) * 0.002;
      }
      bubbles.removeWhere((b) {
        return b.y.compareTo(-0.2) == -1;
      });
    });
  }

  void tapBubble(int index) {
    setState(() {
      coins += 1;
      bubbles.removeAt(index);
    });
    if (rewardedAd != null) {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewarded();
        },
        onAdFailedToShowFullScreenContent: (ad, e) {
          ad.dispose();
          loadRewarded();
        },
      );
      rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          int bonus = 30 + rand.nextInt(21);
          setState(() {
            coins += bonus;
          });
        },
      );
      rewardedAd = null;
    } else {
      loadRewarded();
    }
  }

  @override
  void dispose() {
    spawnTimer?.cancel();
    loopTimer?.cancel();
    bannerAd?.dispose();
    rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8ED6A3),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB2E8C0), Color(0xFF7ED1A0)]),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('$coins')),
                    Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: Text('Misi $misi/20', style: TextStyle(color: Colors.white))),
                    Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(20)), child: Text('Rp $coins')),
                  ],
                ),
              ),
            ),
            ...bubbles.asMap().entries.map((e) {
              int idx = e.key;
              Bubble b = e.value;
              return Positioned(
                left: MediaQuery.of(context).size.width * b.x - b.size / 2,
                top: MediaQuery.of(context).size.height * b.y,
                child: GestureDetector(
                  onTap: () {
                    tapBubble(idx);
                  },
                  child: Container(
                    width: b.size,
                    height: b.size,
                    decoration: BoxDecoration(color: b.color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
                    child: Center(child: Icon(Icons.pets, color: Colors.white, size: 18)),
                  ),
                ),
              );
            }).toList(),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: bannerAd != null ? SizedBox(height: bannerAd!.size.height.toDouble(), child: AdWidget(ad: bannerAd!)) : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
