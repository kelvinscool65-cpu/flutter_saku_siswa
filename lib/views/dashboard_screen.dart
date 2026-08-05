import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 1. Fungsi memuat data dari SharedPreferences saat aplikasi dibuka
  Future<void> _muatDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSaldo = prefs.getInt('totalSaldo') ?? 0;
      final String? riwayatString = prefs.getString('riwayatPengeluaran');
      if (riwayatString != null) {
        _riwayatPengeluaran = List<Map<String, dynamic>>.from(json.decode(riwayatString));
      }
    });
  }

  // 2. Fungsi menyimpan data ke SharedPreferences setiap ada perubahan
  Future<void> _simpanDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalSaldo', _totalSaldo);
    await prefs.setString('riwayatPengeluaran', json.encode(_riwayatPengeluaran));
  }

  // 3. Fungsi yang dipanggil dari Modal Bottom Sheet
  void _tambahPengeluaran(String judul, int nominal) {
    setState(() {
      _riwayatPengeluaran.add({
        'judul': judul,
        'nominal': nominal,
      });
      // Opsional: mengurangi total saldo jika ini aplikasi keuangan
      // _totalSaldo -= nominal; 
    });
    // Simpan ke local storage setelah data ditambahkan
    _simpanDataLokal();
  }

  // 4. Modal Bottom Sheet dari kode Anda
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

  // 5. Build Widget Utama (UI Dashboard)
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
      // Tombol untuk memunculkan modal yang Anda buat
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanModalInput,
        child: const Icon(Icons.add),
      ),
    );
  }
}
