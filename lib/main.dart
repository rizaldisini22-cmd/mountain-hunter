import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
void main(){runApp(MaterialApp(debugShowCheckedModeBanner:false, home:BubbleCrush()));}
class BubbleCrush extends StatefulWidget{const BubbleCrush({super.key});@override State createState()=>_S();}
class _S extends State{
int emas=0;int level=0;var bubbles=[];var r=Random();Timer? t;
var col={"blue":Color(0xFF29B6F6),"purple":Color(0xFFAB47BC),"green":Color(0xFF8BC34A),"pink":Color(0xFFF48FB1),"yellow":Color(0xFFFFEB3B)};
String target="blue";int need=8;int have=0;
@override void initState(){super.initState();start();}
void start(){
bubbles=[];have=0;
if(level==0){target="blue";need=8;}else{var ks=col.keys.toList();target=ks[level%ks.length];need=10+level*2;if(need>120)need=120;}
int i=0;while(20>i){bubbles.add(Bubble(x:30+r.nextDouble()*220,y:320+r.nextDouble()*180,c:col.keys.elementAt(r.nextInt(col.length)),settled:true));i++;}
t?.cancel();t=Timer.periodic(Duration(milliseconds:40),(timer){if(!mounted)return;setState((){
for(var b in bubbles){if(!b.settled){b.vy+=0.3;b.y+=b.vy;b.x+=b.vx;if(b.y>520){b.y=520;b.settled=true;}if(b.x>270||20>b.x){b.vx*=-1;}}}
if(40>bubbles.length&&r.nextDouble()>0.85){bubbles.add(Bubble(x:100+r.nextDouble()*100,y:-20,c:target,settled:false));}
});});}
void tapBubble(int idx){
String c=bubbles[idx].c;var grp=[];int j=0;while(bubbles.length>j){if(bubbles[j].c==c){double dx=(bubbles[j].x-bubbles[idx].x).abs();double dy=(bubbles[j].y-bubbles[idx].y).abs();if(50>dx&&50>dy)grp.add(j);}j++;}
if(grp.length>=2){setState((){grp.sort((a,b)=>b.compareTo(a));for(var g in grp){if(bubbles.length>g)bubbles.removeAt(g);}int add=level==0?20:50;emas+=grp.length*add;if(c==target){have+=grp.length;if(have>need)have=need;}
if(have>=need){t?.cancel();int bonus=level==0?100:2000;emas+=bonus;showDialog(context:context,barrierDismissible:false,builder:(_)=>AlertDialog(title:Text(level==0?"TUTORIAL SELESAI":"LEVEL $level SELESAI"),content:Text("Bonus $bonus\nTotal $emas"),actions:[ElevatedButton(onPressed:(){Navigator.pop(context);level++;start();setState((){});},child:Text(level==0?"MULAI LEVEL 1":"LANJUT"))]));}});}}
@override void dispose(){t?.cancel();super.dispose();}
@override Widget build(BuildContext context){
double pct=need==0?0:have/need;
return Scaffold(body:Container(decoration:BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF7A8FC4),Color(0xFF5A6DAF)])),child:SafeArea(child:Column(children:[
Container(padding:EdgeInsets.all(12),color:Color(0xFF4A3C7A),child:Column(children:[
Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Container(padding:EdgeInsets.symmetric(horizontal:10,vertical:4),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Text("$emas Emas")),Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:4),decoration:BoxDecoration(color:Color(0xFFFFE082),borderRadius:BorderRadius.circular(20)),child:Text(level==0?"TUTORIAL":"LEVEL $level / 1000")),Icon(Icons.volume_up,color:Colors.white70)]),
SizedBox(height:8),Row(mainAxisAlignment:MainAxisAlignment.center,children:[Container(width:44,height:44,decoration:BoxDecoration(color:have>=need?Colors.grey:col[target],shape:BoxShape.circle,border:Border.all(color:Colors.white,width:2))),SizedBox(width:8),Text("${need-have} lagi",style:TextStyle(color:Colors.white)),SizedBox(width:12),Container(width:160,height:8,decoration:BoxDecoration(color:Colors.black38,borderRadius:BorderRadius.circular(10)),child:FractionallySizedBox(alignment:Alignment.centerLeft,widthFactor:pct,child:Container(decoration:BoxDecoration(color:Colors.greenAccent,borderRadius:BorderRadius.circular(10))))),]),])),
Expanded(child:Center(child:Container(width:290,height:560,decoration:BoxDecoration(color:Color(0xFF4A3C7A),borderRadius:BorderRadius.circular(30),border:Border.all(color:Color(0xFFFFC107),width:8)),child:Stack(children:List.generate(bubbles.length,(i){return Positioned(left:bubbles[i].x,top:bubbles[i].y,child:GestureDetector(onTap:()=>tapBubble(i),child:Container(width:38,height:38,decoration:BoxDecoration(color:col[bubbles[i].c],shape:BoxShape.circle,border:Border.all(color:Colors.white,width:2)))));}))))),
Text("Bubble Crush",style:TextStyle(fontSize:28,fontWeight:FontWeight.w900,color:Colors.white)),
Row(mainAxisAlignment:MainAxisAlignment.center,children:[Text("Level $level | Emas $emas",style:TextStyle(color:Colors.white)),SizedBox(width:10),ElevatedButton(onPressed:(){Navigator.push(context,MaterialPageRoute(builder:(_)=>Scaffold(backgroundColor:Color(0xFF8B5A2B),appBar:AppBar(title:Text("Tarik Dana")),body:Center(child:Text("Emas $emas")))));},child:Text("Tarik"))]),SizedBox(height:10)]))));}}
class Bubble{double x;double y;String c;bool settled;double vx;double vy;Bubble({required this.x,required this.y,required this.c,required this.settled}):vx=(Random().nextDouble()-0.5)*2,vy=0;}
