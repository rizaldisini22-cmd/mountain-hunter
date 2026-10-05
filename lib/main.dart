import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TapDanaGame()));

class Bubble {
  double x, y, dx, dy;
  Color color;
  bool isGone = false;
  Bubble(this.x, this.y, this.color, this.dx, this.dy);
}

class TapDanaGame extends StatefulWidget {
  @override State<TapDanaGame> createState() => _TapDanaGameState();
}

class _TapDanaGameState extends State<TapDanaGame> {
  int coins = 0;
  int rupiah = 0;
  List<Bubble> bubbles = [];
  Timer? gameTimer;
  int playCount = 1;
  Random rand = Random();

  @override void initState(){
    super.initState();
    spawnBubbles();
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (t){
      setState((){
        for(var b in bubbles){
          b.x += b.dx;
          b.y += b.dy;
          if(b.x < 0 || b.x > 1) b.dx *= -1;
          if(b.y < 0 || b.y > 0.75) b.dy *= -1;
        }
      });
      if(bubbles.every((b)=> b.isGone)) _showRewardAd();
    });
  }

  void spawnBubbles(){
    List<Color> colors = [Colors.redAccent, Colors.orange, Colors.amber.shade600, Colors.lightBlue, Colors.green.shade300, Colors.purple.shade300, Colors.pinkAccent];
    bubbles = List.generate(18, (i){
      return Bubble(rand.nextDouble(), rand.nextDouble()*0.6+0.1, colors[rand.nextInt(colors.length)], (rand.nextDouble()-0.5)*0.008, (rand.nextDouble()-0.5)*0.008);
    });
    setState((){});
  }

  void tapBubble(int index){
    if(bubbles[index].isGone) return;
    setState((){
      bubbles[index].isGone = true;
      coins += 1;
      rupiah += 1;
    });
  }

  void _showRewardAd(){
    int reward = 30 + rand.nextInt(21);
    showDialog(context: context, barrierDismissible: false, builder: (_)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("RONDE SELESAI!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Container(width:80,height:80, decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle), child: Icon(Icons.play_circle_fill, size:60, color: Colors.green)),
        SizedBox(height:12),
        Text("Tonton iklan untuk lanjut", style: TextStyle(fontSize:14)),
        SizedBox(height:8),
        Text("+$reward KOIN", style: TextStyle(fontSize:28, fontWeight: FontWeight.bold, color: Colors.orange)),
        Text("= Rp $reward", style: TextStyle(color: Colors.grey)),
      ]),
      actions: [SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(vertical:12), shape: StadiumBorder()),
        onPressed: (){
          setState((){
            coins += reward;
            rupiah += reward;
            playCount++;
          });
          Navigator.pop(context);
          spawnBubbles();
        },
        child: Text("TONTON IKLAN & DAPAT $reward KOIN", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize:12))
      ))],
    ));
  }

  void openTukarSaldo(){
    showModalBottomSheet(context: context, isScrollControlled: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_)=> WithdrawSheet(coins: coins, onWithdraw: (int coinUsed){
        setState((){
          coins -= coinUsed;
          rupiah -= coinUsed;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Penukaran $coinUsed koin ke DANA diproses!"), backgroundColor: Colors.green));
      })
    );
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7ED6C8), Color(0xFF8DE4A0)])),
        child: SafeArea(child: Column(children:[
          Padding(padding: EdgeInsets.symmetric(horizontal:12, vertical:8), child: Row(children:[
            Container(padding: EdgeInsets.symmetric(horizontal:14, vertical:6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children:[Icon(Icons.monetization_on, color: Colors.orange, size:20), SizedBox(width:6), Text("$coins", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16))])),
            Spacer(),
            Container(padding: EdgeInsets.symmetric(horizontal:14, vertical:6), decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(20)), child: Text("Rp $rupiah", style: TextStyle(fontWeight: FontWeight.bold))),
          ])),
          Container(margin: EdgeInsets.symmetric(horizontal:12), padding: EdgeInsets.symmetric(horizontal:14, vertical:6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Text("1x Main = 30-50 Coin | Tarik Rp 100 s/d 100RB", style: TextStyle(color: Colors.white, fontSize:11, fontWeight: FontWeight.w500))),
          SizedBox(height:10),
          Expanded(child: LayoutBuilder(builder: (ctx, cons){
            return Stack(children: List.generate(bubbles.length, (i){
              var b = bubbles[i];
              if(b.isGone) return SizedBox();
              return Positioned(
                left: b.x * (cons.maxWidth-56),
                top: b.y * (cons.maxHeight-56),
                child: GestureDetector(
                  onTap: ()=> tapBubble(i),
                  child: Container(width:54, height:54, decoration: BoxDecoration(color: b.color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width:3), boxShadow: [BoxShadow(color: Colors.black26, blurRadius:4, offset: Offset(0,2))]), child: Icon(Icons.lock_open_rounded, color: Colors.white.withOpacity(0.9), size:20)),
                ),
              );
            }));
          })),
          Container(margin: EdgeInsets.all(12), padding: EdgeInsets.symmetric(horizontal:14, vertical:12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius:10)]), child: Row(children:[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Text("Main $playCount x", style: TextStyle(fontWeight: FontWeight.bold, fontSize:13)),
              Text("Coin kesimpen otomatis", style: TextStyle(fontSize:11, color: Colors.grey)),
            ]),
            Spacer(),
            ElevatedButton(onPressed: openTukarSaldo, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: EdgeInsets.symmetric(horizontal:20, vertical:10)), child: Text("TUKAR SALDO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:12)))
          ]))
        ])),
      ),
    );
  }
}

class WithdrawSheet extends StatefulWidget {
  final int coins;
  final Function(int) onWithdraw;
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
        SizedBox(height:4),
        Text("Saldo: ${widget.coins} Coin", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        SizedBox(height:14),
        TextField(controller: danaCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Nomor DANA 08xxxx", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.wallet))),
        SizedBox(height:14),
        Align(alignment: Alignment.centerLeft, child: Text("Pilih Nominal:", style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(height:8),
        GridView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemCount: options.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.6, crossAxisSpacing:8, mainAxisSpacing:8),
          itemBuilder: (_, i){
            bool sel = selected == options[i];
            bool can = widget.coins >= options[i];
            return GestureDetector(onTap: can?(){ setState(()=> selected = options[i]); }: null, child: Container(decoration: BoxDecoration(color: sel? Colors.blue: can? Colors.white: Colors.grey[200], borderRadius: BorderRadius.circular(10), border: Border.all(color: sel? Colors.blue: Colors.grey.shade300)), child: Center(child: Text("${options[i]}\n= Rp ${options[i]}", textAlign: TextAlign.center, style: TextStyle(color: sel? Colors.white: can? Colors.black87: Colors.grey, fontSize:11, fontWeight: FontWeight.bold)))));
          }
        ),
        SizedBox(height:16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: selected <= widget.coins? Colors.blue: Colors.grey, padding: EdgeInsets.symmetric(vertical:14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: selected <= widget.coins && danaCtrl.text.length>=10? ()=> widget.onWithdraw(selected) : null,
          child: Text("TARIK Rp $selected", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:16))
        )),
        SizedBox(height:6),
        Text("Min 100 Koin = Rp 100 | Proses 1-24 Jam", style: TextStyle(fontSize:11, color: Colors.grey)),
        SizedBox(height:20),
      ])
    );
  }
}
