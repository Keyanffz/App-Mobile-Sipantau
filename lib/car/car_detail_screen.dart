import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'car_edit_screen.dart';

class CarDetailScreen extends StatelessWidget {
  final String docId; // Kita hanya butuh ID, sisanya ambil Realtime dari DB
  // carData dari Home hanya untuk tampilan awal (placeholder) sebelum stream loading
  final Map<String, dynamic>? initialData;

  const CarDetailScreen({
    super.key,
    required this.docId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Pastikan format tanggal siap
    initializeDateFormatting('id_ID', null);

    return StreamBuilder<DocumentSnapshot>(
      // MENDENGARKAN PERUBAHAN KHUSUS PADA MOBIL INI
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('cars')
          .doc(docId)
          .snapshots(),
      builder: (context, snapshot) {
        // Data Mobil (Gabungan antara data live atau data awal)
        Map<String, dynamic> data = initialData ?? {};

        if (snapshot.hasData && snapshot.data!.exists) {
          data = snapshot.data!.data() as Map<String, dynamic>;
        }

        // Ambil value
        String plat = data['plat'] ?? "-";
        String merk = data['merk'] ?? "-";
        String tahun = data['tahun'] ?? "-";
        String odo = data['odo'] ?? "-";
        String pajakStr = data['pajak_date'] ?? "-";
        String transmisi = data['transmisi'] ?? "-";
        String bbm = data['bbm'] ?? "-";
        String rangka = data['rangka'] ?? "-";
        String mesin = data['mesin'] ?? "-";
        String? photoUrl = data['photo_url'];

        // LOGIKA STATUS PAJAK (Merah/Hijau)
        bool isPajakActive = false;
        if (pajakStr != "-" && pajakStr != "Belum diset") {
          try {
            DateTime pajakDate =
                DateFormat('dd MMMM yyyy', 'id_ID').parse(pajakStr);
            DateTime now = DateTime.now();
            DateTime today = DateTime(now.year, now.month, now.day);
            if (!pajakDate.isBefore(today)) {
              isPajakActive = true;
            }
          } catch (e) {
            // Ignore error parsing
          }
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5CB85C)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO MOBIL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      photoUrl != null
                          ? Image.network(photoUrl,
                              height: 150, fit: BoxFit.contain)
                          : const Icon(Icons.directions_car,
                              size: 80, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(plat,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.black)),
                      Text(merk,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                _buildDetailRow("Tahun", tahun, textColor),
                _buildDetailRow("Odometer", odo, textColor),
                _buildDetailRow("Pajak", pajakStr, textColor),
                _buildDetailRow("Jenis transmisi", transmisi, textColor),
                _buildDetailRow("Jenis bahan bakar", bbm, textColor),
                _buildDetailRow("Nomor Rangka", rangka, textColor),
                _buildDetailRow("Nomor Mesin", mesin, textColor),

                // STATUS PAJAK
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pajak dan STNK",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPajakActive
                              ? const Color(0xFF5CB85C)
                              : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(isPajakActive ? "Aktif" : "Non Aktif",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),

                Text("Riwayat Service",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        color: textColor)),
                const SizedBox(height: 16),
                Center(
                    child: Text("Belum ada riwayat service",
                        style: TextStyle(color: Colors.grey[500]))),

                const SizedBox(height: 40),

                // TOMBOL EDIT DATA (SEKARANG BERFUNGSI)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5CB85C),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      // BUKA HALAMAN EDIT
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarEditScreen(
                            docId: docId,
                            currentData: data,
                          ),
                        ),
                      );
                    },
                    child: const Text("Edit Data",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor))),
        ],
      ),
    );
  }
}
