import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MountainHunterApp());

class MountainHunterApp extends StatelessWidget {
  const MountainHunterApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mountain Hunter',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  int coins = 0;
  int level = 1;
  late AnimationController _controller;
  final Random rand = Random();
  List<Ball> balls = [];
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))..repeat();
    _controller.addListener(() => updateBalls());
    loadData();
    spawnBalls();
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      highScore = prefs.getInt('high') ?? 0;
      level = prefs.getInt('level') ?? 1;
    });
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('coins', coins);
    prefs.setInt('high', highScore);
    prefs.setInt('level', level);
  }

  void spawnBalls() {
    balls.clear();
    int count = 3 + (level ~/ 2);
    if (count > 15) count = 15;
    for (int i = 0; i < count; i++) {
      balls.add(Ball(
        x: rand.nextDouble() * 300,
        y: rand.nextDouble() * 500,
        dx: (rand.nextDouble() - 0.5) * (2 + level * 0.2),
        dy: (rand.nextDouble() - 0.5) * (2 + level * 0.2),
        color: Colors.primaries[rand.nextInt(Colors.primaries.length)],
        size: 30 + rand.nextDouble() * 20,
      ));
    }
  }

  void updateBalls() {
    for (var b in balls) {
      b.x += b.dx;
      b.y += b.dy;
      if (b.x < 0 || b.x > 350) b.dx *= -1;
      if (b.y < 0 || b.y > 650) b.dy *= -1;
    }
    setState(() {});
  }

  void tapBall(int index) {
    setState(() {
      coins += 10 * level;
      if (coins > highScore) highScore = coins;
      balls.removeAt(index);
      if (balls.isEmpty) {
        level++;
        if (level > 100) level = 100;
        spawnBalls();
      }
    });
    saveData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF87CEEB), Color(0xFF2E8B57), Color(0xFF8B4513)]),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(top: 10, left: 15, right: 15, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('🪙 $coins', style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('⛰️ Lv $level/100', style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(20)), child: Text('🏆 $highScore', style: const TextStyle(fontWeight: FontWeight.bold))),
              ])),
              ...balls.asMap().entries.map((e) => Positioned(
                left: e.value.x, top: e.value.y + 80,
                child: GestureDetector(
                  onTap: () => tapBall(e.key),
                  child: Container(
                    width: e.value.size, height: e.value.size,
                    decoration: BoxDecoration(color: e.value.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)], border: Border.all(color: Colors.white, width: 2)),
                    child: const Center(child: Text('💰', style: TextStyle(fontSize: 16))),
                  ),
                ),
              )),
              Positioned(bottom: 30, left: 20, right: 20, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15)), child: const Text('Tap bola warna-warni untuk kumpulkan koin gunung! Semakin tinggi level, bola semakin cepat & rapi!', textAlign: TextAlign.center))),
            ],
          ),
        ),
      ),
    );
  }
}

class Ball {
  double x, y, dx, dy, size;
  Color color;
  Ball({required this.x, required this.y, required this.dx, required this.dy, required this.color, required this.size});
}
