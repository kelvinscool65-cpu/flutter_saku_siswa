import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SakuSiswaApp());
}

class SakuSiswaApp extends StatelessWidget {
  const SakuSiswaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SakuSiswa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalSaldo = 0;
  List<Map<String, dynamic>> _riwayatPengeluaran = [];

  @override
  void initState() {
    super.initState();
    _muatDataLokal();
  }

  // 🔹 LOAD DATA
  Future<void> _muatDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSaldo = prefs.getInt('total_saldo') ?? 0;

      List<String>? dataStringList = prefs.getStringList('riwayat');
      if (dataStringList != null) {
        _riwayatPengeluaran = dataStringList
            .map((item) => jsonDecode(item) as Map<String, dynamic>)
            .toList();
      }
    });
  }

  // 🔹 SAVE DATA
  Future<void> _simpanDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_saldo', _totalSaldo);

    List<String> dataStringList =
        _riwayatPengeluaran.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('riwayat', dataStringList);
  }

  // 🔹 TAMBAH PENGELUARAN
  void _tambahPengeluaran(String judul, int nominal) {
    if (nominal <= 0 || judul.isEmpty) return;

    setState(() {
      _totalSaldo -= nominal;
      _riwayatPengeluaran.insert(0, {
        'judul': judul,
        'nominal': nominal,
        'tanggal': DateTime.now().toString().substring(0, 10),
      });
    });

    _simpanDataLokal();
  }

  // 🔹 MODAL INPUT
  void _tampilkanModalInput() {
    final judulController = TextEditingController();
    final nominalController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tambah Pengeluaran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: judulController,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final judul = judulController.text;
                  final nominal =
                      int.tryParse(nominalController.text) ?? 0;

                  _tambahPengeluaran(judul, nominal);
                  Navigator.pop(ctx);
                },
                child: const Text("Simpan"),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SakuSiswa"),
      ),

      // 🔥 UI SUDAH MIRIP CONTOH
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 CARD SALDO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Sisa Uang Saku Saat Ini",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp $_totalSaldo",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      setState(() => _totalSaldo += 50000);
                      _simpanDataLokal();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                    ),
                    child: const Text("Isi Uang Saku (+Rp50.000)"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Riwayat Pengeluaran",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 🔹 LIST
            Expanded(
              child: _riwayatPengeluaran.isEmpty
                  ? const Center(child: Text("Belum ada pengeluaran"))
                  : ListView.builder(
                      itemCount: _riwayatPengeluaran.length,
                      itemBuilder: (context, index) {
                        final item = _riwayatPengeluaran[index];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.money_off, color: Colors.white),
                            ),
                            title: Text(item['judul']),
                            subtitle: Text(item['tanggal']),
                            trailing: Text(
                              "- Rp ${item['nominal']}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // 🔥 TOMBOL TAMBAH (MODAL)
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanModalInput,
        child: const Icon(Icons.add),
      ),
    );
  }
}