import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  title: 'Fruit blast Dana',
  debugShowCheckedModeBanner: false,
  home: TarikDanaOnly(coins: 4732),
));

// === HALAMAN TARIK DANA - FRUIT BLAST DANA ===
class TarikDanaOnly extends StatefulWidget{
  final int coins; 
  const TarikDanaOnly({super.key, required this.coins});
  @override State<TarikDanaOnly> createState()=> _TarikOnly();
}

class _TarikOnly extends State<TarikDanaOnly>{
  late int cur; 
  String noDana="";
  @override void initState(){super.initState(); cur=widget.coins;}
  double get rpTotal => cur / 59.0;

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Emas kurang! Butuh ${it["emas"]}, kamu $cur")));
      return;
    }
    showDialog(context: context, builder: (c)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("TUKAR SALDO DANA", style: TextStyle(fontWeight: FontWeight.w900, fontSize:16)),
      content
