import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'car_edit_screen.dart';
import '../utils/rul_helper.dart';
import '../utils/notification_helper.dart';

class CarDetailScreen extends StatelessWidget {
  final String docId;
  final Map<String, dynamic>? initialData;

  const CarDetailScreen({
    super.key,
    required this.docId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser; // Ambil user aktif [cite: 256]
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Inisialisasi format tanggal Indonesia [cite: 257]
    initializeDateFormatting('id_ID', null);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('cars')
          .doc(docId)
          .snapshots(), // Pantau data secara real-time [cite: 258]
      builder: (context, snapshot) {
        Map<String, dynamic> data = initialData ?? {};

        if (snapshot.hasData && snapshot.data!.exists) {
          data = snapshot.data!.data() as Map<String, dynamic>; // Ambil data terbaru [cite: 259]
        }

        // --- DATA KENDARAAN ---
        final String namaKendaraan = data['nama_kendaraan'] ?? "-";
        final String plat = data['plat'] ?? "-";
        final String jenisKendaraan = data['jenis_kendaraan'] ?? "motor";
        final String? photoUrl = data['photo_url'];
        final int odoNow = int.tryParse(data['odo']?.toString() ?? "0") ?? 0;

        // --- DATA SERVIS TERAKHIR ---
        final int lastServiceOdo = int.tryParse(data['last_service_odo']?.toString() ?? "0") ?? 0;
        final String serviceType = data['service_type'] ?? "-";
        
        DateTime? lastServiceDate;
        final rawDate = data['last_service_date'];

        // Parsing tanggal servis [cite: 263-265]
        try {
          if (rawDate is Timestamp) {
            lastServiceDate = rawDate.toDate();
          } else if (rawDate is String && rawDate.isNotEmpty) {
            lastServiceDate = DateFormat('dd MMMM yyyy', 'id_ID').parse(rawDate);
          }
        } catch (_) {
          lastServiceDate = null;
        }

        // --- HITUNG LOGIKA PREDIKSI (RUL) ---
        RulResult? rul;
        if (lastServiceDate != null && lastServiceOdo > 0) {
          rul = RulHelper.hitungRul(
            jenisKendaraan: jenisKendaraan,
            odoSekarang: odoNow,
            odoTerakhirServis: lastServiceOdo,
            tanggalTerakhirServis: lastServiceDate,
          ); // Hitung sisa KM dan Hari 

          // Kirim notifikasi jika status tidak aman 
          if (rul.status != "AMAN") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              NotificationHelper.showRulNotification(context, rul!);
            });
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
                // --- KOTAK FOTO KENDARAAN ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    border: Border.all(color: const Color(0xFF5CB85C), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      photoUrl != null
                          ? Image.network(photoUrl, height: 150, fit: BoxFit.contain)
                          : const Icon(Icons.directions_car, size: 80, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(namaKendaraan, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor)),
                      Text(plat, style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withOpacity(0.7))),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- BAGIAN COUNTDOWN SERVIS (PREDIKSI) ---
                if (rul != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: rul.status == "HARUS SERVIS"
                          ? Colors.red
                          : (rul.status == "MENDEKATI SERVIS" ? Colors.orange : const Color(0xFF5CB85C)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("COUNTDOWN SERVIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          "Sisa: ${rul.sisaKm} KM atau ${rul.sisaHari} hari lagi",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          "Status: ${rul.status}",
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // --- DETAIL INFORMASI ---
                _buildDetailRow("Jenis Kendaraan", jenisKendaraan.toUpperCase(), textColor),
                _buildDetailRow("Odometer Sekarang", "$odoNow KM", textColor),
                const Divider(),
                const SizedBox(height: 10),

                // --- INFO SERVIS TERAKHIR ---
                Text("Servis Terakhir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                const SizedBox(height: 16),

                lastServiceDate == null
                    ? const Text("Belum ada data servis")
                    : Column(
                        children: [
                          _buildDetailRow("Tanggal", DateFormat('dd MMMM yyyy', 'id_ID').format(lastServiceDate), textColor),
                          _buildDetailRow("Jenis Servis", serviceType, textColor),
                          _buildDetailRow("Odo Servis", "$lastServiceOdo KM", textColor),
                        ],
                      ),

                const SizedBox(height: 40),

                // --- TOMBOL EDIT ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5CB85C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarEditScreen(docId: docId, currentData: data),
                        ),
                      );
                    },
                    child: const Text("Edit Data Kendaraan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // Widget Helper untuk Baris Detail [cite: 316]
  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
        ],
      ),
    );
  }
}