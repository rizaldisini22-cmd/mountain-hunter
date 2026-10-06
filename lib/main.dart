import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const TapDanaCuanApp());
}

class TapDanaCuanApp extends StatelessWidget {
  const TapDanaCuanApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'TAP DANA CUAN', home: const GameScreen());
  }
}

class Bubble {
  double x, y, speed; Color color; double size;
  Bubble({required this.x, required this.y, required this.speed, required this.color, this.size=60});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  int coin = 486; int rupiah = 486; int misi = 6; int timerSec = 0;
  Timer? gameTimer, spawnTimer;
  List<Bubble> bubbles = [];
  final Random rnd = Random();
  late AnimationController _controller;
  List<Color> colors = [Color(0xFFB983FF), Color(0xFFE85A5A), Color(0xFF6BCB77), Color(0xFFFFC93C), Color(0xFF4D96FF), Color(0xFFFFA500)];

  RewardedAd? _rewardedAd;
  bool _isAdReady = false;
  // ID TEST - GANTI DENGAN ID ASLI KAKAK NANTI
  final String adUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 16))..repeat();
    _controller.addListener(_update);
    _loadAd();
    _startGame();
  }

  void _loadAd(){
    RewardedAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad){ setState((){ _rewardedAd = ad; _isAdReady = true; }); },
        onAdFailedToLoad: (e){ print('Ad failed $e'); _isAdReady=false; Future.delayed(Duration(seconds: 3), _loadAd); }
      )
    );
  }

  void _startGame() {
    timerSec = 0; bubbles.clear();
    for(int i=0;i<12;i++) _spawnBubble();
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(seconds: 1), (t){ setState(()=> timerSec++); if(timerSec >= 15) _finishRound(); });
    spawnTimer?.cancel();
    spawnTimer = Timer.periodic(Duration(milliseconds: 800), (_)=> _spawnBubble());
  }
  void _spawnBubble(){
    if(bubbles.length>18) return;
    setState((){ bubbles.add(Bubble(x: rnd.nextDouble()*0.85+0.02, y: 1.1+rnd.nextDouble()*0.3, speed: 0.003+rnd.nextDouble()*0.006, color: colors[rnd.nextInt(colors.length)], size: 55+rnd.nextDouble()*15)); });
  }
  void _update(){ setState((){ for(var b in bubbles) b.y-=b.speed; bubbles.removeWhere((b)=> b.y < -0.2); }); }
  void _tapBubble(int i){ setState((){ bubbles.removeAt(i); coin+=1; rupiah+=1; }); _spawnBubble(); }

  void _finishRound(){
    gameTimer?.cancel(); spawnTimer?.cancel();
    int reward = 30+rnd.nextInt(21); // 30-50
    showDialog(context: context, barrierDismissible: false, builder: (_)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('WAKTU HABIS!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.play_circle_fill, size: 80, color: Colors.orange),
        SizedBox(height: 10),
        Text(_isAdReady? 'Tonton iklan asli dapat bonus' : 'Loading iklan...', textAlign: TextAlign.center),
        Text('+$reward KOIN', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
      ]),
      actions: [SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: (){
          Navigator.pop(context);
          if(_isAdReady && _rewardedAd!= null){
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad){ ad.dispose(); _loadAd(); _claimReward(reward); },
              onAdFailedToShowFullScreenContent: (ad, err){ ad.dispose(); _loadAd(); _claimReward(reward); },
            );
            _rewardedAd!.show(onUserEarnedReward: (ad, rewardItem){});
          } else {
            _claimReward(reward);
          }
        },
        child: Text(_isAdReady? 'TONTON IKLAN ASLI +$reward' : 'CLAIM +$reward KOIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ))],
    ));
  }

  void _claimReward(int reward){
    setState((){ coin+=reward; rupiah+=reward; misi+=1; });
    _startGame();
  }

  void _showTukarSaldo(){
    showModalBottomSheet(context: context, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_){
      return Padding(padding: EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('TUKAR SALDO DANA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Saldo: Rp $rupiah ($coin Koin)'),
        ListTile(title: Text('Rp 100'), subtitle: Text('100 koin'), trailing: ElevatedButton(onPressed: coin>=100?(){setState((){coin-=100; rupiah-=100;}); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil tarik Rp100 ke DANA (Simulasi)')));} : null, child: Text('Tarik'))),
        ListTile(title: Text('Rp 500'), subtitle: Text('500 koin'), trailing: ElevatedButton(onPressed: coin>=500?(){setState((){coin-=500; rupiah-=500;}); Navigator.pop(context);} : null, child: Text('Tarik'))),
        ListTile(title: Text('Rp 1.000'), subtitle: Text('1000 koin'), trailing: ElevatedButton(onPressed: coin>=1000?(){setState((){coin-=1000; rupiah-=1000;}); Navigator.pop(context);} : null, child: Text('Tarik'))),
        Text('*Ganti AdMob ID test dengan ID asli biar dapat uang beneran', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ]));
    });
  }
  String _formatTimer(int s)=> '${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}';
  @override
  void dispose(){ _controller.dispose(); gameTimer?.cancel(); spawnTimer?.cancel(); _rewardedAd?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7DE2FF), Color(0xFF9BE89E)])), child: SafeArea(child: Column(children: [
      Padding(padding: EdgeInsets.all(10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.monetization_on, color: Colors.orange, size: 20), SizedBox(width: 5), Text('$coin', style: TextStyle(fontWeight: FontWeight.bold))])),
        Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: Text('Misi $misi/20 ${_formatTimer(timerSec)} ${_isAdReady? "AD READY" : "LOADING AD"}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
        Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('Rp $rupiah', style: TextStyle(fontWeight: FontWeight.bold))),
      ])),
      Container(margin: EdgeInsets.symmetric(horizontal: 12), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Text('1x Main = 30-50 Coin | Tarik Rp 100 s/d 100RB', style: TextStyle(color: Colors.white, fontSize: 11))),
      Expanded(child: LayoutBuilder(builder: (ctx, c)=> Stack(children: [for(int i=0;i<bubbles.length;i++) Positioned(left: bubbles[i].x*c.maxWidth, top: bubbles[i].y*c.maxHeight, child: GestureDetector(onTap: ()=>_tapBubble(i), child: Container(width: bubbles[i].size, height: bubbles[i].size, decoration: BoxDecoration(color: bubbles[i].color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: Icon(Icons.lock_open_rounded, color: Colors.white))))]))),
      Container(margin: EdgeInsets.all(12), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Main $misi x', style: TextStyle(fontWeight: FontWeight.bold)), Text('Coin kesimpen otomatis', style: TextStyle(fontSize: 11, color: Colors.grey))]),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), onPressed: _showTukarSaldo, child: Text('TUKAR SALDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ])),
    ]))));
  }
}
