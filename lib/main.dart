import 'dart:math';
import 'package:flutter/material.dart';
void main()=>runApp(MaterialApp(home: TarikDanaOnly(coins: 4732), debugShowCheckedModeBanner: false));

class TarikDanaOnly extends StatefulWidget{
  final int coins; const TarikDanaOnly({super.key, required this.coins});
  @override State<TarikDanaOnly> createState()=> _TarikOnly();
}

class _TarikOnly extends State<TarikDanaOnly>{
  late int cur; String noDana="";
  @override void initState(){super.initState(); cur=widget.coins;}
  double get rpTotal => cur / 59.0; // 59 Emas = Rp1 (sesuai foto kakak)

  final List<Map> list = [
    {"rp":50, "emas":2950, "limit":"10 Kali/Hari"},
    {"rp":100, "emas":5900, "limit":"15 Kali/Hari"},
    {"rp":300, "emas":17700, "limit":"15 Kali/Hari"},
    {"rp":1000, "emas":59000, "limit":"5 Kali/Hari"},
    {"rp":5000, "emas":295000, "limit":"5 Kali/Hari"},
    {"rp":10000, "emas":590000, "limit":"1 Kali/Hari"},
    {"rp":30000, "emas":1770000, "limit":"1 Kali/Hari"},
    {"rp":100000, "emas":5900000, "limit":"1 Kali/Hari"},
    {"rp":200000, "emas":11800000, "limit":"1 Kali/Hari"},
  ];

  void prosesTarik(Map it){
    if(cur < it["emas"]){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Emas kurang! Butuh ${it["emas"]}, kamu ${cur}")));
      return;
    }
    showDialog(context: context, builder: (c)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("TUKAR SALDO DANA", style: TextStyle(fontWeight: FontWeight.w900, fontSize:16)),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)), child: Row(children:[
          Image.network("https://upload.wikimedia.org/wikipedia/commons/7/72/Logo_dana_blue.png", width:40, errorBuilder: (c,e,s)=> Icon(Icons.account_balance_wallet, color: Colors.blue)),
          SizedBox(width:10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text("Rp${it["rp"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize:18)),
            Text("${it["emas"]} Emas", style: TextStyle(fontSize:12))
          ])
        ])),
        SizedBox(height:12),
        TextField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "No. DANA",
            hintText: "08xxxxxxxxxx",
            prefixIcon: Icon(Icons.phone_android, color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
          ),
          onChanged: (v)=> noDana=v,
        ),
        SizedBox(height:8),
        Text("Penarikan manual 1x24 jam akan di TF admin ke No. DANA kamu", style: TextStyle(fontSize:10, color: Colors.grey))
      ]),
      actions:[
        TextButton(onPressed: ()=> Navigator.pop(c), child: Text("BATAL")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF118EEA)),
          onPressed: (){
            if(noDana.length < 10){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Isi No. DANA dulu kak!")));
              return;
            }
            setState(()=> cur -= it["emas"] as int);
            Navigator.pop(c);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("BERHASIL! Rp${it["rp"]} ke DANA $noDana - PENDING - Admin akan TF 24 jam"),
              backgroundColor: Colors.green,
              duration: Duration(seconds:4),
            ));
          },
          child: Text("TUKAR SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        )
      ],
    ));
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        color: Color(0xFF8B5A2B), // kayu
        child: SafeArea(child: Column(children:[
          // Header Tarik Dana
          Padding(padding: EdgeInsets.all(12), child: Row(children:[
            Container(padding: EdgeInsets.symmetric(horizontal:12,vertical:6), decoration: BoxDecoration(color: Color(0xFFFFE8A0), borderRadius: BorderRadius.circular(20)), child: Text("Tarik Dana", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037)))),
            Spacer(),
            Icon(Icons.access_time, color: Colors.white70)
          ])),
          // Saldo
          Container(margin: EdgeInsets.all(12), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Color(0xFFFFF3A0), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.brown, width:2)),
            child: Row(children:[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Text("≈ Rp${rpTotal.toStringAsFixed(0)}", style: TextStyle(fontSize:24, fontWeight: FontWeight.w900, color: Color(0xFF8B5A2B))),
                Row(children:[Icon(Icons.monetization_on, color: Colors.orange, size:20), SizedBox(width:4), Text("$cur Emas", style: TextStyle(fontWeight: FontWeight.bold))])
              ]),
              Spacer(),
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Column(children:[Text("Indonesia"), Text("(IDR)", style: TextStyle(fontWeight: FontWeight.bold)), Text("🇮🇩")]))
            ]),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal:12), child: Align(alignment: Alignment.centerLeft, child: Text("Metode penarikan", style: TextStyle(color: Colors.white70, fontSize:12)))),
          SizedBox(height:6),
          Container(margin: EdgeInsets.symmetric(horizontal:12), padding: EdgeInsets.symmetric(horizontal:12,vertical:10), decoration: BoxDecoration(color: Color(0xFFFFF8B0), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white, width:2)), child: Row(children:[Icon(Icons.account_balance_wallet, color: Color(0xFF118EEA)), SizedBox(width:8), Text("Dana", style: TextStyle(fontWeight: FontWeight.bold)), Spacer(), Icon(Icons.check_circle, color: Colors.green)])),

          SizedBox(height:12),
          Expanded(child: Container(margin: EdgeInsets.symmetric(horizontal:12), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing:10, mainAxisSpacing:10), itemCount: list.length, itemBuilder: (c,i){
            var it=list[i]; bool bisa=cur>=it["emas"];
            return Container(decoration: BoxDecoration(color: Color(0xFFFFF8B0), borderRadius: BorderRadius.circular(16), border: Border.all(color: bisa? Colors.green: Colors.grey)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
                Text("Rp${it["rp"]}", style: TextStyle(fontWeight: FontWeight.w900, fontSize:18)),
                Text("${it["emas"]} Emas", style: TextStyle(fontSize:10)),
                SizedBox(height:8),
                GestureDetector(onTap: bisa? ()=> prosesTarik(it): null, child: Container(padding: EdgeInsets.symmetric(horizontal:12,vertical:4), decoration: BoxDecoration(color: bisa? Color(0xFFFFC400): Colors.grey, borderRadius: BorderRadius.circular(12)), child: Text(it["limit"], style: TextStyle(fontSize:9, fontWeight: FontWeight.bold))))
              ]),
            );
          }))),
          // Tombol Tarik Semua
          Container(padding: EdgeInsets.all(12), child: Column(children:[
            GestureDetector(onTap: ()=> prosesTarik(list[0]), child: Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical:14), decoration: BoxDecoration(color: Color(0xFFFFD000), borderRadius: BorderRadius.circular(24)), child: Center(child: Text("Tarik Semua", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16))))),
            SizedBox(height:4),
            Text("Tarik jumlah ini: Rp${rpTotal.toStringAsFixed(0)}", style: TextStyle(color: Colors.white70, fontSize:10))
          ]))
        ])),
      ),
    );
  }
}
