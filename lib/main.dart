import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TapDanaGame()));
}

class Bubble {
  double x, y, dx, dy; Color color; bool isGone=false;
  Bubble(this.x, this.y, this.color, this.dx, this.dy);
}

class TapDanaGame extends StatefulWidget {
  @override State<TapDanaGame> createState() => _TapDanaGameState();
}

class _TapDanaGameState extends State<TapDanaGame> {
  int coins = 0; int playCount = 1;
  List<Bubble> bubbles = [];
  Timer? timer; Random rand = Random();
  RewardedAd? rewardedAd;
  bool adReady = false;

  // GANTI DENGAN ID ADMOB KAKAK YANG ASLI NANTI
  final String adUnitId = "ca-app-pub-3940256099942544/5224354917"; // ini TEST ID

  @override void initState(){
    super.initState();
    loadCoins();
    spawnBubbles();
    loadAd();
    timer = Timer.periodic(Duration(milliseconds: 16), (t){
      setState((){
        for(var b in bubbles){
          b.x += b.dx; b.y += b.dy;
          if(b.x < 0 || b.x > 1) b.dx *= -1;
          if(b.y < 0 || b.y > 0.75) b.dy *= -1;
        }
      });
      if(bubbles.every((b)=> b.isGone)) _showRewardAd();
    });
  }

  Future<void> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    setState((){
      coins = prefs.getInt('coins')?? 0;
      playCount = prefs.getInt('play')?? 1;
    });
  }
  Future<void> saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('coins', coins);
    prefs.setInt('play', playCount);
  }

  void loadAd(){
    RewardedAd.load(adUnitId: adUnitId, request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad){ rewardedAd = ad; adReady = true; },
        onAdFailedToLoad: (e){ adReady = false; Future.delayed(Duration(seconds:3), loadAd); }
      )
    );
  }

  void spawnBubbles(){
    List<Color> colors = [Colors.redAccent, Colors.orange, Colors.amber.shade600, Colors.lightBlue, Colors.green.shade400, Colors.purple.shade300, Colors.pinkAccent];
    bubbles = List.generate(18, (i)=> Bubble(rand.nextDouble(), rand.nextDouble()*0.6+0.1, colors[rand.nextInt(colors.length)], (rand.nextDouble()-0.5)*0.008, (rand.nextDouble()-0.5)*0.008));
    setState((){});
  }

  void tapBubble(int i){
    if(bubbles[i].isGone) return;
    setState((){
      bubbles[i].isGone = true;
      coins += 1;
    });
    saveCoins();
  }

  void _showRewardAd(){
    int reward = 30 + rand.nextInt(21);
    showDialog(context: context, barrierDismissible: false, builder: (_)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("RONDE HABIS!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Icon(Icons.card_giftcard, size:70, color: Colors.orange),
        SizedBox(height:10),
        Text("Tonton iklan untuk dapat", style: TextStyle(fontSize:13)),
        Text("+$reward KOIN", style: TextStyle(fontSize:30, fontWeight: FontWeight.bold, color: Colors.orange)),
        Text(adReady? "Iklan siap" : "Memuat iklan...", style: TextStyle(fontSize:11, color: Colors.grey)),
      ]),
      actions: [SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(vertical:13), shape: StadiumBorder()),
        onPressed: (){
          Navigator.pop(context);
          if(adReady && rewardedAd!= null){
            rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(onAdDismissedFullScreenContent: (ad){ ad.dispose(); loadAd(); finishRound(reward); }, onAdFailedToShowFullScreenContent: (ad,e){ ad.dispose(); loadAd(); finishRound(reward); });
            rewardedAd!.show(onUserEarnedReward: (ad, r){});
          } else {
            finishRound(reward); // kalau iklan belum siap tetap kasih reward biar user gak kabur
          }
        },
        child: Text("TONTON IKLAN +$reward", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
      ))],
    ));
  }

  void finishRound(int reward){
    setState((){
      coins += reward;
      playCount++;
    });
    saveCoins();
    spawnBubbles();
  }

  void openTukar(){
    showModalBottomSheet(context: context, isScrollControlled: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_)=> WithdrawSheet(coins: coins, onWithdraw: (int used){
        setState(()=> coins -= used);
        saveCoins();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil! Tarik $used Koin = Rp $used ke DANA diproses 1x24 jam"), backgroundColor: Colors.green));
      })
    );
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7ED6C8), Color(0xFF8DE4A0)])),
        child: SafeArea(child: Column(children:[
          Padding(padding: EdgeInsets.all(12), child: Row(children:[
            Container(padding: EdgeInsets.symmetric(horizontal:14, vertical:7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children:[Icon(Icons.monetization_on, color: Colors.orange), SizedBox(width:6), Text("$coins", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16))])),
            Spacer(),
            Container(padding: EdgeInsets.symmetric(horizontal:14, vertical:7), decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(20)), child: Text("Rp $coins", style: TextStyle(fontWeight: FontWeight.bold))),
          ])),
          Container(padding: EdgeInsets.symmetric(horizontal:14, vertical:5), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Text("1x Tap = 1 Coin | Iklan = 30-50 Coin | Tarik Rp 100 s/d 100RB", style: TextStyle(color: Colors.white, fontSize:10))),
          SizedBox(height:10),
          Expanded(child: LayoutBuilder(builder: (ctx, cons){
            return Stack(children: List.generate(bubbles.length, (i){
              var b = bubbles[i];
              if(b.isGone) return SizedBox();
              return Positioned(
                left: b.x * (cons.maxWidth-56), top: b.y * (cons.maxHeight-56),
                child: GestureDetector(onTap: ()=> tapBubble(i),
                  child: Container(width:54, height:54, decoration: BoxDecoration(color: b.color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width:3), boxShadow: [BoxShadow(color: Colors.black26, blurRadius:4)]), child: Icon(Icons.fingerprint, color: Colors.white, size:24)),
                ),
              );
            }));
          })),
          Container(margin: EdgeInsets.all(12), padding: EdgeInsets.symmetric(horizontal:14, vertical:12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children:[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("Main $playCount x", style: TextStyle(fontWeight: FontWeight.bold)), Text("Coin kesimpen otomatis", style: TextStyle(fontSize:11, color: Colors.green))]),
            Spacer(),
            ElevatedButton(onPressed: openTukar, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, shape: StadiumBorder(), padding: EdgeInsets.symmetric(horizontal:24, vertical:10)), child: Text("TUKAR SALDO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
          ]))
        ])),
      ),
    );
  }
}

class WithdrawSheet extends StatefulWidget {
  final int coins; final Function(int) onWithdraw;
  WithdrawSheet({required this.coins, required this.onWithdraw});
  @override State<WithdrawSheet> createState()=> _WithdrawSheetState();
}
class _WithdrawSheetState extends State<WithdrawSheet>{
  TextEditingController danaCtrl = TextEditingController();
  int selected = 100;
  List<int> options = [100, 500, 1000, 5000, 10000, 20000, 50000, 100000];
  @override Widget build(BuildContext context){
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left:16, right:16, top:16),
      child: Column(mainAxisSize: MainAxisSize.min, children:[
        Container(width:40, height:5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
        SizedBox(height:16),
        Text("TUKAR KE DANA", style: TextStyle(fontWeight: FontWeight.bold, fontSize:20)),
        SizedBox(height:6),
        Text("Saldo: ${widget.coins} Coin = Rp ${widget.coins}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        SizedBox(height:14),
        TextField(controller: danaCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Nomor DANA", hintText: "08xxxxxxxxxx", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.wallet))),
        SizedBox(height:12),
        GridView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemCount: options.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.6, crossAxisSpacing:8, mainAxisSpacing:8),
          itemBuilder: (_, i){
            bool sel = selected == options[i]; bool can = widget.coins >= options[i];
            return GestureDetector(onTap: can?(){ setState(()=> selected = options[i]); }: null, child: Container(decoration: BoxDecoration(color: sel? Colors.blue: can? Colors.white: Colors.grey[200], borderRadius: BorderRadius.circular(10), border: Border.all(color: sel? Colors.blue: Colors.grey.shade300)), child: Center(child: Text("${options[i]}\nRp ${options[i]}", textAlign: TextAlign.center, style: TextStyle(color: sel? Colors.white: can? Colors.black87: Colors.grey, fontSize:11, fontWeight: FontWeight.bold)))));
          }
        ),
        SizedBox(height:16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: selected <= widget.coins? Colors.blue: Colors.grey, padding: EdgeInsets.symmetric(vertical:14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: selected <= widget.coins && danaCtrl.text.length>=10? ()=> widget.onWithdraw(selected) : null,
          child: Text("TARIK Rp $selected KE DANA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        )),
        SizedBox(height:20),
      ])
    );
  }
}
