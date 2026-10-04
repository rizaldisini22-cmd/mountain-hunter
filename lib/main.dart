import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: TarikDanaOnly(coins: 4732),
));

class TarikDanaOnly extends StatefulWidget {
  final int coins;
  const TarikDanaOnly({super.key, required this.coins});
  @override
  State<TarikDanaOnly> createState() => _TarikOnly();
}

class _TarikOnly extends State<TarikDanaOnly> {
  late int cur;
  String noDana = "";
  @override
  void initState() {
    super.initState();
    cur = widget.coins;
  }

  final List<Map<String, dynamic>> list = [
    {"rp": 50, "emas": 2950, "limit": "10 Kali/Hari"},
    {"rp": 100, "emas": 5900, "limit": "15 Kali/Hari"},
    {"rp": 300, "emas": 17700, "limit": "15 Kali/Hari"},
    {"rp": 1000, "emas": 59000, "limit": "5 Kali/Hari"},
    {"rp": 5000, "emas": 295000, "limit": "5 Kali/Hari"},
    {"rp": 10000, "emas": 590000, "limit": "1 Kali/Hari"},
    {"rp": 30000, "emas": 1770000, "limit": "1 Kali/Hari"},
  ];

  void tarik(Map item) {
    if (cur < item["emas"]) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Emas kurang! Butuh ${item["emas"]}")));
      return;
    }
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("TUKAR SALDO DANA"),
        content: TextField(
          decoration: const InputDecoration(labelText: "No. DANA", hintText: "08xxxxxxxxxx", border: OutlineInputBorder()),
          onChanged: (v) => noDana = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("BATAL")),
          ElevatedButton(
            onPressed: () {
              if (noDana.length < 10) return;
              setState(() => cur -= item["emas"] as int);
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SUKSES Rp${item["rp"]} ke $noDana"), backgroundColor: Colors.green));
            },
            child: const Text("TUKAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double rp = cur / 59.0;
    return Scaffold(
      backgroundColor: const Color(0xFF8B5A2B),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFF3A0), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("≈ Rp${rp.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Text("$cur Emas", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  const Spacer(),
                  const Text("Fruit blast Dana\n🇮🇩", textAlign: TextAlign.center),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.6, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: list.length,
                itemBuilder: (c, i) {
                  var it = list[i];
                  bool bisa = cur >= it["emas"];
                  return InkWell(
                    onTap: bisa ? () => tarik(it) : null,
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFFFFF8B0), borderRadius: BorderRadius.circular(16), border: Border.all(color: bisa ? Colors.green : Colors.grey)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Rp${it["rp"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("${it["emas"]} Emas", style: const TextStyle(fontSize: 10)),
                        const SizedBox(height: 6),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: bisa ? Colors.amber : Colors.grey, borderRadius: BorderRadius.circular(10)), child: Text(it["limit"], style: const TextStyle(fontSize: 9))),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
