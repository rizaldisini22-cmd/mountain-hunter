import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
void main(){runApp(MaterialApp(debugShowCheckedModeBanner:false, home:Bubble73()));}
class Bubble73 extends StatefulWidget{const Bubble73({super.key});@override State createState()=>_S();}
class _S extends State{
int coin=0;int level=1;int misi=0;int totalMain=0;var bubbles=[];var r=Random();Timer? t;
var history=[];
var col={"blue":Color(0xFF29B6F6),"purple":Color(0xFF6C5CE7),"cyan":Color(0xFF00BCD4),"red":Color(0xFFFF5252),"green":Color(0xFF66BB6A)};
var nominal=[100,500,1000,2000,5000,10000,20000,50000,100000];

@override void initState(){super.initState();start();}
void start(){
bubbles=[];int i=0;while(15>i){bubbles.add(B(x:20+r.nextDouble()*280,y:200+r.nextDouble()*400,c:col.keys.elementAt(r.nextInt(col.length)),s:42));i++;}
t?.cancel();
t=Timer.periodic(Duration(milliseconds:45),(timer){if(!mounted)return;setState((){
for(var b in bubbles){b.y-=0.7+r.nextDouble(); b.x+=sin(b.y/30)*0.9; if(-60>b.y){b.y=700; b.x=r.nextDouble()*300;}}
if(20>bubbles.length&&r.nextDouble()>0.90){bubbles.add(B(x:r.nextDouble()*300,y:750,c:col.keys.elementAt(r.nextInt(col.length)),s:42));}
});});}

void tapB(int idx){
if(bubbles.length<=idx)return;
setState((){
misi+=1;
bubbles.removeAt(idx);
if(20>bubbles.length){bubbles.add(B(x:r.nextDouble()*300,y:750,c:col.keys.elementAt(r.nextInt(col.length)),s:42));}
if(20<=misi){
// 1x MAIN SELESAI DAPET 10 COIN
coin+=10;
totalMain+=1;
misi=0;
level+=1;
showDialog(context:context,barrierDismissible:false,builder:(_)=>AlertDialog(
title:Text("MISI SELESAI! 🎉"),
content:Column(mainAxisSize:MainAxisSize.min,children:[
Text("Main ke-$totalMain",style:TextStyle(fontWeight:FontWeight.bold)),
SizedBox(height:8),
Container(padding:EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.green.shade50,borderRadius:BorderRadius.circular(10)),child:Text("+10 Coin = Rp 10",style:TextStyle(fontWeight:FontWeight.bold,fontSize:18,color:Colors.green))),
SizedBox(height:8),
Text("Total: $coin Coin = Rp $coin"),
Text("${10-totalMain%10} main lagi bisa tarik Rp 100",style:TextStyle(fontSize:11,color:Colors.orange)),
]),
actions:[ElevatedButton(onPressed:(){Navigator.pop(context);},child:Text("MAIN LAGI"))]));
}
});
}

Widget tarikPage(){
TextEditingController hp=TextEditingController();
int selected=100;
return StatefulBuilder(builder:(context,setSt){
int sisa=10-totalMain%10;if(sisa==10&&totalMain>0)sisa=0;
return Scaffold(appBar:AppBar(title:Text("Tarik Dana - 10x Main = Rp 100"),backgroundColor:Color(0xFF0081DF),foregroundColor:Colors.white),
body:Container(padding:EdgeInsets.all(16),child:SingleChildScrollView(child:Column(children:[
Container(width:double.infinity,padding:EdgeInsets.all(16),decoration:BoxDecoration(color:Color(0xFFE3F2FD),borderRadius:BorderRadius.circular(16)),child:Column(children:[
Text("KAMU SUDAH MAIN $totalMain x"),Text("$coin Coin = Rp $coin",style:TextStyle(fontSize:30,fontWeight:FontWeight.w900,color:Color(0xFF0081DF))),
SizedBox(height:6),
Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:totalMain>=10?Colors.green:Colors.orange,borderRadius:BorderRadius.circular(20)),child:Text(totalMain>=10?"✅ BISA TARIK Rp 100!":"${10-totalMain} main lagi bisa tarik Rp 100",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:12))),
SizedBox(height:6),Text("Aturan: 1x main (20 bola) = 10 Coin | 10x main = 100 Coin = Rp 100",style:TextStyle(fontSize:10,color:Colors.grey),textAlign:TextAlign.center),
])),
SizedBox(height:16),
TextField(controller:hp,decoration:InputDecoration(labelText:"No Dana 08xxxx",border:OutlineInputBorder(),prefixIcon:Icon(Icons.wallet)),keyboardType:TextInputType.phone),
SizedBox(height:16),Align(alignment:Alignment.centerLeft,child:Text("Pilih Nominal:",style:TextStyle(fontWeight:FontWeight.bold))),
SizedBox(height:8),
GridView.builder(shrinkWrap:true,physics:NeverScrollableScrollPhysics(),gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,childAspectRatio:2.3,crossAxisSpacing:8,mainAxisSpacing:8),itemCount:nominal.length,itemBuilder:(_,i){
int n=nominal[i];bool bisa=coin>=n;bool aktif=selected==n;
return GestureDetector(onTap:(){if(bisa)setSt(()=>selected=n);},child:Container(decoration:BoxDecoration(color:aktif?Color(0xFF0081DF):bisa?Colors.white:Colors.grey.shade200,borderRadius:BorderRadius.circular(12),border:Border.all(color:aktif?Color(0xFF0081DF):bisa?Colors.green:Colors.grey)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text("Rp $n",style:TextStyle(fontWeight:FontWeight.w900,color:aktif?Colors.white:bisa?Colors.black:Colors.grey,fontSize:12)),Text(bisa?"Bisa":"${n} Coin",style:TextStyle(fontSize:9,color:aktif?Colors.white70:bisa?Colors.green:Colors.grey)) ])));
}),
SizedBox(height:16),
SizedBox(width:double.infinity,height:48,child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:coin>=selected?Color(0xFF0081DF):Colors.grey),onPressed:(){
if(coin<selected){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Main dulu! Kurang ${selected-coin} Coin"))); return;}
if(hp.text.length<10){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Isi No Dana"))); return;}
setState((){coin-=selected; history.insert(0,"Rp $selected ke ${hp.text}");});
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("SUKSES! Rp $selected dikirim!"),backgroundColor:Colors.green));
},child:Text(coin>=selected?"TUKAR Rp $selected":"KURANG ${selected-coin} COIN",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)))),
SizedBox(height:20),Divider(),...history.map((h)=>ListTile(leading:Icon(Icons.check_circle,color:Colors.green),title:Text(h,style:TextStyle(fontSize:13)),dense:true)).toList(),
]))));
});
}

@override void dispose(){t?.cancel();super.dispose();}
@override Widget build(BuildContext context){
return Scaffold(body:Container(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xFF7DD3D8),Color(0xFF5AB9A8),Color(0xFF6DBF7B),Color(0xFF8B6D3A)])),
child:SafeArea(child:Column(children:[
SizedBox(height:10),
Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
Container(padding:EdgeInsets.symmetric(horizontal:14,vertical:7),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Text("🪙 $coin",style:TextStyle(fontWeight:FontWeight.bold))),
Container(padding:EdgeInsets.symmetric(horizontal:14,vertical:7),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Text("⛰️ Lv $level/100",style:TextStyle(fontWeight:FontWeight.bold))),
Container(padding:EdgeInsets.symmetric(horizontal:14,vertical:7),decoration:BoxDecoration(color:Color(0xFFFFEB3B),borderRadius:BorderRadius.circular(20)),child:Text("💰 Rp $coin",style:TextStyle(fontWeight:FontWeight.bold))),
]),
SizedBox(height:8),
Container(margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:Colors.black54,borderRadius:BorderRadius.circular(20)),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
Text("Main: $totalMain x | Misi $misi/20 ",style:TextStyle(color:Colors.white,fontSize:11)),
Container(width:60,height:5,decoration:BoxDecoration(color:Colors.white24,borderRadius:BorderRadius.circular(10)),child:FractionallySizedBox(alignment:Alignment.centerLeft,widthFactor:misi/20,child:Container(color:Colors.yellow))),
SizedBox(width:6),Text("10x = Rp 100",style:TextStyle(color:Colors.yellow,fontSize:10,fontWeight:FontWeight.bold))
])),
Expanded(child:Stack(children:List.generate(bubbles.length,(i){
var b=bubbles[i];Color c=col[b.c]??Colors.blue;
return Positioned(left:b.x,top:b.y,child:GestureDetector(onTap:()=>tapB(i),child:Container(width:b.s,height:b.s,decoration:BoxDecoration(color:c,shape:BoxShape.circle,border:Border.all(color:Colors.white,width:2.5)),child:Center(child:Icon(Icons.touch_app,color:Colors.white,size:18))))));
}))),
Container(margin:EdgeInsets.all(12),padding:EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("1x main = 10 Coin",style:TextStyle(fontSize:11,fontWeight:FontWeight.bold)),Text("$coin/100 Coin untuk tarik Rp 100",style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:totalMain>=10?Colors.green:Colors.orange))]),
ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF0081DF)),onPressed:(){Navigator.push(context,MaterialPageRoute(builder:(_)=>tarikPage()));},child:Text(totalMain>=10?"TARIK Rp 100":"TUKAR DANA",style:TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.bold)))
])),
])));}}
class B{double x;double y;String c;double s;B({required this.x,required this.y,required this.c,required this.s});}
