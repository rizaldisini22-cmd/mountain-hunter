import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MaterialApp(home: LevelMapScreen(), debugShowCheckedModeBanner: false));
}

// SCREEN 1: PETA LEVEL 1-100
class LevelMapScreen extends StatefulWidget {
  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  int unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unlockedLevel = prefs.getInt('unlockedLevel')?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D2C3E),
      appBar: AppBar(
        title: Text("Mountain Hunter - 100 LEVELS ⛰️", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF0D2C3E),
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: 100,
        itemBuilder: (context, index) {
          int levelNum = index + 1;
          bool isUnlocked = levelNum <= unlockedLevel;
          bool isBoss = levelNum % 10 == 0;

          return GestureDetector(
            onTap: isUnlocked? () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BubbleGameScreen(level: levelNum)));
            } : null,
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked? (isBoss? Colors.orange : Colors.blue) : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: isBoss? Border.all(color: Colors.yellow, width: 2) : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$levelNum", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    if(isBoss) Text("⭐", style: TextStyle(fontSize: 10)),
                    if(!isUnlocked) Icon(Icons.lock, color: Colors.white54, size: 14)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// SCREEN 2: GAME BUBBLE SHOOTER NYA
class BubbleGameScreen extends StatefulWidget {
  final int level;
  BubbleGameScreen({required this.level});
  @override
  State<BubbleGameScreen> createState() => _BubbleGameScreenState();
}

class _BubbleGameScreenState extends State<BubbleGameScreen> {
  int score = 0;
  int moves = 0;
  List<Color> bubbles = [];
  Color nextBubble = Colors.blue;
  RewardedAd? _rewardedAd;
  final String adUnitId = "ca-app-pub-6482727132974147/xxxx"; // GANTI ID REWARDED KAKAK

  @override
  void initState() {
    super.initState();
    generateLevel(widget.level);
    loadAd();
  }

  void generateLevel(int level) {
    Random rand = Random(level); // seed dari level biar tiap level beda tapi tetap sama kalau diulang
    int bubbleCount = 10 + (level * 0.8).toInt(); // makin tinggi level makin banyak bola
    if(bubbleCount > 60) bubbleCount = 60;

    List<Color> colors = [Colors.purple, Colors.blue, Colors.green];
    if(level > 20) colors.add(Colors.orange);
    if(level > 50) colors.add(Colors.red);

    bubbles = List.generate(bubbleCount, (_) => colors[rand.nextInt(colors.length)]);
    moves = 15 + (level ~/ 2);
    nextBubble = colors[rand.nextInt(colors.length)];
    score = 0;
  }

  void loadAd() {
    RewardedAd.load(adUnitId: adUnitId, request: AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (ad) => _rewardedAd = ad,
      onAdFailedToLoad: (e) => print("Ad failed $e"),
    ));
  }

  void shootBubble() {
    setState(() {
      // Logika simpel: tembak warna yang sama bakal hilang
      if(bubbles.contains(nextBubble)) {
        bubbles.removeWhere((c) => c == nextBubble);
        score += 100;
      } else {
        bubbles.add(nextBubble);
        moves--;
      }
      nextBubble = [Colors.purple, Colors.blue, Colors.green, Colors.orange][Random().nextInt(4)];

      if(bubbles.isEmpty) {
        winLevel();
      }
      if(moves <= 0 && bubbles.isNotEmpty) {
        showGameOver();
      }
    });
  }

  void winLevel() async {
    final prefs = await SharedPreferences.getInstance();
    int unlocked = prefs.getInt('unlockedLevel')?? 1;
    if(widget.level >= unlocked) {
      await prefs.setInt('unlockedLevel', widget.level + 1);
    }
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      title: Text("🎉 LEVEL ${widget.level} MENANG!"),
      content: Text("Score: $score\nLanjut ke level ${widget.level + 1}?"),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(context); Navigator.pop(context);
        }, child: Text("KE PETA")),
        ElevatedButton(onPressed: () {
          Navigator.pop(context); Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => BubbleGameScreen(level: widget.level + 1)));
        }, child: Text("LANJUT"))
      ],
    ));
  }

  void showGameOver() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Game Over 😢"),
      content: Text("Nonton iklan untuk +5 moves?"),
      actions: [
        TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: Text("KELUAR")),
        ElevatedButton(onPressed: () {
          if(_rewardedAd!= null) {
            _rewardedAd!.show(onUserEarnedReward: (_, __) {
              setState(() { moves += 5; }); Navigator.pop(context);
            });
          }
        }, child: Text("NONTON IKLAN +5"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5F9),
      appBar: AppBar(title: Text("Level ${widget.level}"), backgroundColor: Colors.blue,
        actions: [Center(child: Padding(padding: EdgeInsets.only(right: 16), child: Text("Score: $score | Moves: $moves", style: TextStyle(fontWeight: FontWeight.bold))))],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
              itemCount: bubbles.length,
              itemBuilder: (_, i) => Container(
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(color: bubbles[i], shape: BoxShape.circle, boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)]),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Text("NEXT:"), SizedBox(height: 8),
                Container(width: 50, height: 50, decoration: BoxDecoration(color: nextBubble, shape: BoxShape.circle)),
                SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.orange),
                  onPressed: shootBubble,
                  child: Text("TEMBAK! 💥", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
