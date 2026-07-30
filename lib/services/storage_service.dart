import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // 1. Simpan Data ke Memory HP
  static Future<void> simpanDataLokal(
      int totalSaldo, List<Map<String, dynamic>> riwayat) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_saldo', totalSaldo);
    
    // Encode List<Map> jadi List<String> karena SharedPreferences
    // cuma bisa simpan tipe data dasar
    List<String> dataStringList =
        riwayat.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('riwayat', dataStringList);
  }

  // 2. Muat Data Saat Aplikasi Dibuka
  static Future<Map<String, dynamic>> muatDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    int saldo = prefs.getInt('total_saldo') ?? 100000; // default saldo awal 100rb

    List<String>? dataStringList = prefs.getStringList('riwayat');
    List<Map<String, dynamic>> riwayat = [];
    if (dataStringList != null) {
      riwayat = dataStringList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    return {'saldo': saldo, 'riwayat': riwayat};
  }
}