import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());
class MyApp extends StatelessWidget{const MyApp({super.key}); @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,home:GameScreen());}
class Ball{double x,baseY,y,speed,phase,size; Color color; Ball({required this.x,required this.baseY,required this.y,required this.speed,required this.phase,required this.color,required this.size});}
class GameScreen extends StatefulWidget{const GameScreen({super.key}); @override State<GameScreen> createState()=>_S();}
class _S extends State<GameScreen> with SingleTickerProviderStateMixin{
  int coin=486; int rp=486;
  List<Ball> balls=[]; final rnd=Random(); late AnimationController ctrl; double t=0;
  List<Color> colors=[Color(0xFFF7D060),Color(0xFF98D8AA),Color(0xFFB08BBB),Color(0xFFEF9A9A),Color(0xFF90CAF9)];
  @override void initState(){super.initState(); ctrl=AnimationController(vsync:this,duration:Duration(milliseconds:16))..repeat(); ctrl.addListener(loop); _init();}
  void _init(){balls.clear(); for(int i=0;i<15;i++){double bx=0.08+(i%5)*0.18+rnd.nextDouble()*0.05; double by=0.14+(i~/5)*0.22+rnd.nextDouble()*0.06; balls.add(Ball(x:bx.clamp(0.05,0.9),baseY:by,y:by,speed:0.6+rnd.nextDouble()*0.8,phase:rnd.nextDouble()*6.28,color:colors[i%colors.length],size:64));}}
  void loop(){t+=0.02; setState(()=> balls.forEach((b){b.y=b.baseY+sin(t*b.speed+b.phase)*0.10;}));}
  void tapBall(int i){setState(()=> balls.removeAt(i)); int bonus=30+rnd.nextInt(21); showDialog(context:context,barrierDismissible:false,builder:(_)=>Dialog(shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(24)),child:Padding(padding:EdgeInsets.all(22),child:Column(mainAxisSize:MainAxisSize.min,children:[Container(width:88,height:88,decoration:BoxDecoration(color:Color(0xFFFFF3CD),shape:BoxShape.circle),child:Icon(Icons.play_circle_fill,size:68,color:Colors.orange)),SizedBox(height:14),Text('IKLAN SELESAI!',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),Text('Tap = 1 Koin'),Text('Bonus Iklan = $bonus Koin',style:TextStyle(color:Colors.green,fontWeight:FontWeight.bold)),SizedBox(height:10),Container(padding:EdgeInsets.symmetric(horizontal:22,vertical:10),decoration:BoxDecoration(color:Color(0xFFE8F5E9),borderRadius:BorderRadius.circular(14)),child:Text('+${1+bonus} KOIN',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:Color(0xFF2E7D32)))),SizedBox(height:16),SizedBox(width:double.infinity,child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF2962FF),padding:EdgeInsets.symmetric(vertical:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),onPressed:(){setState((){coin+=1+bonus; rp+=1+bonus; double bx=rnd.nextDouble()*0.8+0.05; double by=rnd.nextDouble()*0.6+0.15; balls.add(Ball(x:bx,baseY:by,y:by,speed:0.6+rnd.nextDouble()*0.8,phase:rnd.nextDouble()*6.28,color:colors[rnd.nextInt(colors.length)],size:64));}); Navigator.pop(context);},child:Text('AMBIL ${1+bonus} & LANJUT',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))))]))));}
  void openDana() async { final result = await Navigator.push(context, MaterialPageRoute(builder:(_)=> DanaPage(coin:coin, rp:rp))); if(result!=null && result is int){ setState((){coin-=result; rp-=result;}); } }
  @override void dispose(){ctrl.dispose(); super.dispose();}
  @override Widget build(BuildContext context){
    return Scaffold(body:Container(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xFF9AD9FF),Color(0xFFBFF0BE)])),child:SafeArea(child:Column(children:[
      Padding(padding:EdgeInsets.all(10),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Container(padding:EdgeInsets.symmetric(horizontal:14,vertical:7),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Row(children:[Icon(Icons.monetization_on,color:Colors.amber,size:20),SizedBox(width:6),Text('$coin Koin',style:TextStyle(fontWeight:FontWeight.bold))])),Container(padding:EdgeInsets.symmetric(horizontal:14,vertical:7),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Text('Rp $rp',style:TextStyle(fontWeight:FontWeight.bold))) ])),
      Container(margin:EdgeInsets.symmetric(horizontal:12),padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Colors.black87,borderRadius:BorderRadius.circular(20)),child:Center(child:Text('TAP = 1 KOIN + IKLAN 30-50 | Tarik via WA Admin',style:TextStyle(color:Colors.white,fontSize:10)))),
      Expanded(child:LayoutBuilder(builder:(ctx,cons)=>Stack(children:[for(int i=0;i<balls.length;i++) Positioned(left:balls[i].x*cons.maxWidth, top:balls[i].y*cons.maxHeight, child:GestureDetector(onTap:()=>tapBall(i), child:Container(width:balls[i].size,height:balls[i].size,decoration:BoxDecoration(color:balls[i].color,shape:BoxShape.circle,border:Border.all(color:Colors.white,width:3)),child:Center(child:Text('\$',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:22))))))]))),
      Container(margin:EdgeInsets.all(12),padding:EdgeInsets.symmetric(horizontal:16,vertical:12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('TAP TERUS!',style:TextStyle(fontWeight:FontWeight.bold)),Text('Coin auto kesimpen',style:TextStyle(fontSize:11,color:Colors.grey))]),ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF2962FF),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),padding:EdgeInsets.symmetric(horizontal:22,vertical:10)),onPressed:openDana,child:Text('TUKAR SALDO',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))) ])),
    ]))));
  }
}

class DanaPage extends StatefulWidget{
  final int coin; final int rp;
  const DanaPage({super.key, required this.coin, required this.rp});
  @override State<DanaPage> createState()=>_DanaPageState();
}
class _DanaPageState extends State<DanaPage>{
  final _phoneCtrl = TextEditingController(text: '08');
  int sel=-1;
  // GANTI NOMOR WA KAKAK DISINI YA!
  final String adminWA = '6281234567890'; // <- Ganti jadi nomor WA kakak pakai 62
  List<Map<String,dynamic>> nom=[
    {'rp':100, 'koin':100, 'pop':false},
    {'rp':500, 'koin':500, 'pop':true},
    {'rp':1000, 'koin':1000, 'pop':false},
    {'rp':5000, 'koin':5000, 'pop':false},
    {'rp':10000, 'koin':10000, 'pop':false},
    {'rp':50000, 'koin':50000, 'pop':false},
  ];

  Future<void> _tarikWA() async {
    if(_phoneCtrl.text.length<10){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Nomor DANA minimal 10 digit'))); return; }
    if(sel==-1){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Pilih nominal dulu'))); return; }
    int need=nom[sel]['koin'];
    if(widget.coin < need){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Koin tidak cukup'))); return; }

    String pesan = "Halo Admin TAP DANA CUAN%0A%0AMau tarik saldo:%0A- Nominal: Rp ${nom[sel]['rp']}%0A- Koin: ${nom[sel]['koin']}%0A- No DANA: ${_phoneCtrl.text}%0A- Sisa Koin: ${widget.coin - need}%0A%0AMohon diproses ya min 🙏";
    final url = Uri.parse("https://wa.me/$adminWA?text=$pesan");

    if(await canLaunchUrl(url)){
      await launchUrl(url, mode: LaunchMode.externalApplication);
      // setelah buka WA, potong koin
      if(mounted) Navigator.pop(context, need);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Gagal buka WhatsApp')));
    }
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Color(0xFFF5F7FB),
      appBar:AppBar(backgroundColor:Color(0xFF118EEA), foregroundColor:Colors.white, title:Text('Tukar ke DANA',style:TextStyle(fontWeight:FontWeight.bold))),
      body:SingleChildScrollView(child:Column(children:[
        Container(width:double.infinity, color:Color(0xFF118EEA), padding:EdgeInsets.fromLTRB(16,0,16,20), child:Container(padding:EdgeInsets.all(16), decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)), child:Row(children:[
          Container(width:50,height:50,decoration:BoxDecoration(color:Color(0xFF118EEA),borderRadius:BorderRadius.circular(12)), child:Center(child:Text('DANA',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)))),
          SizedBox(width:12),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ Text('Saldo Kamu',style:TextStyle(color:Colors.grey,fontSize:12)), Text('Rp ${widget.rp}',style:TextStyle(fontWeight:FontWeight.bold,fontSize:20)), Text('${widget.coin} Koin',style:TextStyle(color:Colors.green,fontSize:12,fontWeight:FontWeight.bold)) ])),
          Icon(Icons.verified_user, color:Colors.green)
        ]))),
        Padding(padding:EdgeInsets.all(16), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Container(padding:EdgeInsets.all(12), decoration:BoxDecoration(color:Color(6289680440809),borderRadius:BorderRadius.circular(12)), child:Row(children:[ Icon(Icons.lock, color:Colors.green, size:18), SizedBox(width:8), Expanded(child:Text('AMAN: Penarikan via WA Admin, saldo DANA kakak tidak terhubung ke aplikasi',style:TextStyle(fontSize:11,color:Colors.green[800]))) ])),
          SizedBox(height:14),
          Text('Nomor DANA Kamu',style:TextStyle(fontWeight:FontWeight.bold)),
          SizedBox(height:6),
          TextField(controller:_phoneCtrl, keyboardType:TextInputType.phone, decoration:InputDecoration(hintText:'08xxxxxxxxxx', prefixIcon:Icon(Icons.phone_android), filled:true, fillColor:Colors.white, border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))),
          SizedBox(height:16),
          Text('Pilih Nominal',style:TextStyle(fontWeight:FontWeight.bold)),
          SizedBox(height:10),
          GridView.builder(shrinkWrap:true, physics:NeverScrollableScrollPhysics(), itemCount:nom.length, gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:2.1, crossAxisSpacing:10, mainAxisSpacing:10), itemBuilder:(c,i){
            bool can = widget.coin >= nom[i]['koin']; bool s = sel==i;
            return GestureDetector(onTap: can?(){setState(()=> sel=i);}:null, child:Container(decoration:BoxDecoration(color: s? Color(0xFFE3F2FD): Colors.white, borderRadius:BorderRadius.circular(14), border:Border.all(color: s? Color(0xFF118EEA): Colors.grey[200]!, width: s?2:1)), child:Stack(children:[
              if(nom[i]['pop']) Positioned(top:0,right:0, child:Container(padding:EdgeInsets.symmetric(horizontal:8,vertical:2), decoration:BoxDecoration(color:Colors.orange,borderRadius:BorderRadius.only(topRight:Radius.circular(14),bottomLeft:Radius.circular(10))), child:Text('POPULER',style:TextStyle(color:Colors.white,fontSize:8,fontWeight:FontWeight.bold)))),
              Padding(padding:EdgeInsets.all(12), child:Column(crossAxisAlignment:CrossAxisAlignment.start, mainAxisAlignment:MainAxisAlignment.center, children:[
                Row(children:[Text('Rp ${nom[i]['rp']}',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16,color: can? Colors.black: Colors.grey)), Spacer(), if(s) Icon(Icons.check_circle,color:Color(0xFF118EEA),size:20)]),
                Text('${nom[i]['koin']} Koin',style:TextStyle(fontSize:12,color:Colors.grey)),
              ]))
            ]))));
          }),
          SizedBox(height:20),
          SizedBox(width:double.infinity, child:ElevatedButton.icon(icon:Icon(Icons.chat, color:Colors.white), label:Text('TARIK VIA WHATSAPP',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)), style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF25D366), padding:EdgeInsets.symmetric(vertical:16), shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))), onPressed:_tarikWA)),
          SizedBox(height:10),
          Center(child:Text('Admin akan TF manual 1-5 menit setelah chat WA',style:TextStyle(fontSize:11,color:Colors.grey))),
        ]))
      ])),
    );
  }
}
