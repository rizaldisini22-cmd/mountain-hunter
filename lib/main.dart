// V3.4 FIX - 1 KLIK = 1 COIN, HABIS = IKLAN 30-50
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: GamePage()));
}

class BubbleData {
  double x,y,dx,dy,size; Color color;
  BubbleData({required this.x, required this.y, required this.dx, required this.dy, required this.size, required this.color});
}

class GamePage extends StatefulWidget { @override _GamePageState createState()=>_GamePageState(); }

class _GamePageState extends State<GamePage> {
  List<BubbleData> bubbles=[];
  int coin=486, misi=6, totalMain=6;
  Random rnd=Random();
  Timer? loop;
  RewardedAd? rewardedAd;
  InterstitialAd? interstitialAd; // BACKUP BIAR PASTI MUNCUL

  List<Color> colors=[Color(0xFF2196F3), Color(0xFFFF9800), Color(0xFF4CAF50), Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF00BCD4)];

  @override void initState(){
    super.initState();
    loadData(); spawnBubbles(); loadAds();
    loop=Timer.periodic(Duration(milliseconds:16),(t){
      if(!mounted) return;
      setState((){
        for(var b in bubbles){ b.x+=b.dx; b.y+=b.dy; if(b.x<=0||b.x>=1) b.dx*=-1; if(b.y<=0.15||b.y>=0.88) b.dy*=-1; }
      });
    });
  }

  void loadAds(){
    RewardedAd.load(adUnitId:'ca-app-pub-3940256099942544/5224354917', request:AdRequest(), rewardedAdLoadCallback:RewardedAdLoadCallback(onAdLoaded:(ad)=>rewardedAd=ad, onAdFailedToLoad:(_)=>Future.delayed(Duration(seconds:2),loadAds)));
    InterstitialAd.load(adUnitId:'ca-app-pub-3940256099942544/1033173712', request:AdRequest(), adLoadCallback:InterstitialAdLoadCallback(onAdLoaded:(ad)=>interstitialAd=ad, onAdFailedToLoad:(_){}));
  }
  void loadData() async { final p=await SharedPreferences.getInstance(); setState((){coin=p.getInt('coin')??486; misi=p.getInt('misi')??6; totalMain=p.getInt('total')??6;});}
  void saveData() async { final p=await SharedPreferences.getInstance(); p.setInt('coin',coin); p.setInt('misi',misi); p.setInt('total',totalMain);}

  void spawnBubbles(){ bubbles.clear(); for(int i=0;i<12;i++){ bubbles.add(BubbleData(x:rnd.nextDouble(), y:rnd.nextDouble()*0.65+0.15, dx:(rnd.nextDouble()-0.5)*0.015, dy:(rnd.nextDouble()-0.5)*0.015, size:52+rnd.nextDouble()*28, color:colors[rnd.nextInt(colors.length)])); } }

  void popBubble(int index){
    HapticFeedback.lightImpact();
    setState((){
      coin += 1; // PASTI 1 COIN
      bubbles.removeAt(index);
      saveData();
      if(bubbles.isEmpty){
        totalMain++; misi++; if(misi>20) misi=1;
        _showAdAndBonus();
      }
    });
  }

  void _showAdAndBonus(){
    int bonus = 30 + rnd.nextInt(21); // 30-50
    
    if(rewardedAd!=null){
      rewardedAd!.fullScreenContentCallback=FullScreenContentCallback(
        onAdDismissedFullScreenContent:(ad){ ad.dispose(); loadAds(); setState((){ coin+=bonus; spawnBubbles(); saveData(); }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('🎉 +$bonus Coin dari Iklan!'), backgroundColor:Colors.green)); },
        onAdFailedToShowFullScreenContent:(ad, e){ ad.dispose(); loadAds(); setState((){ coin+=bonus; spawnBubbles(); saveData(); }); }
      );
      rewardedAd!.show(onUserEarnedReward:(a,r){});
      rewardedAd=null;
    } else if(interstitialAd!=null){
      // BACKUP: KALO REWARDED GAGAL, PAKAI INTERSTITIAL
      interstitialAd!.fullScreenContentCallback=FullScreenContentCallback(
        onAdDismissedFullScreenContent:(ad){ ad.dispose(); loadAds(); setState((){ coin+=bonus; spawnBubbles(); saveData(); }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('✅ MISI SELESAI +$bonus Coin!'), backgroundColor:Colors.green)); }
      );
      interstitialAd!.show();
      interstitialAd=null;
    } else {
      setState((){ coin+=bonus; spawnBubbles(); saveData(); });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('✅ MISI SELESAI +$bonus Coin Bonus!'), backgroundColor:Colors.green));
      loadAds();
    }
  }

  @override void dispose(){ loop?.cancel(); rewardedAd?.dispose(); interstitialAd?.dispose(); super.dispose(); }

  @override Widget build(BuildContext context){
    final size=MediaQuery.of(context).size;
    return Scaffold(body:Container(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter, end:Alignment.bottomCenter, colors:[Color(0xFF7DD8C6), Color(0xFF8ED081)])), child:Stack(children:[
      Positioned(top:35,left:12,right:12,child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Text('🪙 $coin',style:TextStyle(fontWeight:FontWeight.bold,fontSize:13))),
        Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Text('Misi $misi/20',style:TextStyle(fontWeight:FontWeight.bold,fontSize:12))),
        Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Color(0xFFFFEB3B),borderRadius:BorderRadius.circular(20)),child:Text('Rp $coin',style:TextStyle(fontWeight:FontWeight.bold,fontSize:13))),
      ])),
      Positioned(top:70,left:0,right:0,child:Center(child:Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:4),decoration:BoxDecoration(color:Colors.black54,borderRadius:BorderRadius.circular(12)),child:Text('1x Main = 30-50 Coin | Tarik Rp 100 s/d 100RB',style:TextStyle(color:Colors.white,fontSize:10))))),
      ...bubbles.asMap().entries.map((e)=>Positioned(left:e.value.x*(size.width-e.value.size),top:e.value.y*size.height,child:GestureDetector(onTap:()=>popBubble(e.key),child:Container(width:e.value.size,height:e.value.size,decoration:BoxDecoration(color:e.value.color,shape:BoxShape.circle,border:Border.all(color:Colors.white,width:3),boxShadow:[BoxShadow(color:Colors.black26,blurRadius:5)]),child:Icon(Icons.touch_app,color:Colors.white,size:22))))),
      Positioned(bottom:15,left:12,right:12,child:Container(padding:EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Main $totalMain x\nCoin kesimpen otomatis',style:TextStyle(fontSize:11,fontWeight:FontWeight.w600)),ElevatedButton(onPressed:(){},style:ElevatedButton.styleFrom(backgroundColor:Colors.blue,shape:StadiumBorder()),child:Text('TUKAR SALDO',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:12)))]))),
    ])));
  }
}
