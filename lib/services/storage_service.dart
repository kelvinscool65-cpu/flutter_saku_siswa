import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// TODO [Dev Logic]: Implementasi Logika SharedPreferences
// ============================================================================

// 1. Simpan Data ke Memory HP
Future<void> simpanDataLokal(int totalSaldo, List<Map<String, dynamic>> riwayat) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('total_saldo', totalSaldo);

  // Encode List Map ke List String JSON
  List<String> dataStringList = riwayat.map((item) => jsonEncode(item)).toList();
  await prefs.setStringList('riwayat', dataStringList);
}

// 2. Muat Data Saat Aplikasi Dibuka
Future<Map<String, dynamic>> muatDataLokal() async {
  final prefs = await SharedPreferences.getInstance();
  int saldo = prefs.getInt('total_saldo') ?? 0;
  
  List<String>? dataStringList = prefs.getStringList('riwayat');
  List<Map<String, dynamic>> riwayat = [];

  if (dataStringList != null) {
    riwayat = dataStringList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  return {
    'saldo': saldo,
    'riwayat': riwayat,
  };
}

// ============================================================================
// TODO [Dev UI]: Implementasi Tampilan Aplikasi
// ============================================================================

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
    _inisialisasiData();
  }

  // Fungsi untuk memanggil logika muat data saat aplikasi pertama kali dibuka
  Future<void> _inisialisasiData() async {
    final data = await muatDataLokal();
    setState(() {
      _totalSaldo = data['saldo'];
      _riwayatPengeluaran = data['riwayat'];
    });
  }

  // Fungsi penambah pengeluaran yang terhubung dengan UI dan Logika Storage
  void _tambahPengeluaran(String judul, int nominal) {
    setState(() {
      _riwayatPengeluaran.add({
        'judul': judul,
        'nominal': nominal,
      });
      // Jika ingin agar pengeluaran mengurangi total saldo:
      // _totalSaldo -= nominal; 
    });
    
    // Panggil fungsi simpan data setiap kali ada pengeluaran baru
    simpanDataLokal(_totalSaldo, _riwayatPengeluaran);
  }

  // TODO [Dev UI]: Implementasikan Modal Bottom Sheet
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
          top: 20, left: 20, right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: judulController,
              decoration: const InputDecoration(labelText: 'Keterangan Pengeluaran'),
            ),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                final judul = judulController.text;
                final nominal = int.tryParse(nominalController.text) ?? 0;
                
                // Panggil fungsi penambah pengeluaran
                _tambahPengeluaran(judul, nominal);
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Saldo: Rp $_totalSaldo',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _riwayatPengeluaran.isEmpty
                ? const Center(child: Text('Belum ada riwayat pengeluaran.'))
                : ListView.builder(
                    itemCount: _riwayatPengeluaran.length,
                    itemBuilder: (context, index) {
                      final item = _riwayatPengeluaran[index];
                      return ListTile(
                        leading: const Icon(Icons.money_off, color: Colors.red),
                        title: Text(item['judul']),
                        subtitle: Text('Rp ${item['nominal']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanModalInput,
        child: const Icon(Icons.add),
      ),
    );
  }
}
