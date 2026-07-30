class Transaksi {
  final String keterangan;
  final int nominal;
  final DateTime tanggal;

  Transaksi({
    required this.keterangan,
    required this.nominal,
    DateTime? tanggal,
  }) : tanggal = tanggal ?? DateTime.now();

  // Ubah objek Transaksi -> Map, supaya bisa di-jsonEncode
  Map<String, dynamic> toMap() {
    return {
      'keterangan': keterangan,
      'nominal': nominal,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  // Ubah Map (hasil jsonDecode) -> objek Transaksi
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      keterangan: map['keterangan'] ?? '',
      nominal: map['nominal'] ?? 0,
      tanggal: DateTime.tryParse(map['tanggal'] ?? '') ?? DateTime.now(),
    );
  }
}