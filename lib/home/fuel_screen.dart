import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'fuel_add_screen.dart';

class FuelScreen extends StatelessWidget {
  final String carId;
  final String carName;

  // Constructor wajib menerima carId
  const FuelScreen({super.key, required this.carId, required this.carName});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        // Menampilkan nama mobil di judul
        title: Column(
          children: [
            Text("Riwayat BBM", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            Text(carName, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5CB85C)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fuel_logs')
            .where('carId', isEqualTo: carId) // FILTER BERDASARKAN ID MOBIL
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5CB85C)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_gas_station_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada data untuk mobil ini", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          double totalCost = 0;
          for (var doc in snapshot.data!.docs) {
            totalCost += (doc['totalPrice'] as num).toDouble();
          }

          return Column(
            children: [
              // Kartu Ringkasan
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5CB85C), Color(0xFF4CAE4C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF5CB85C).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Pengeluaran", style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(currencyFormatter.format(totalCost), style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.show_chart, color: Colors.white, size: 28),
                  ],
                ),
              ),

              // Daftar List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    DateTime date = (data['date'] as Timestamp).toDate();
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF5CB85C).withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.local_gas_station, color: Color(0xFF5CB85C), size: 20),
                        ),
                        title: Text(data['fuelType'] ?? 'Bahan Bakar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        subtitle: Text("${DateFormat('dd MMM yyyy').format(date)} • ${data['liters']} L", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        trailing: Text(currencyFormatter.format(data['totalPrice']), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5CB85C),
        // Kirim carId ke halaman tambah
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FuelAddScreen(carId: carId)));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Catat Baru", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}