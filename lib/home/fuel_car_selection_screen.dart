import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fuel_screen.dart'; // Import halaman riwayat

class FuelCarSelectionScreen extends StatelessWidget {
  const FuelCarSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih Kendaraan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5CB85C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil daftar mobil user
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('cars')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5CB85C)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("Belum ada kendaraan", style: GoogleFonts.poppins(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var carDoc = snapshot.data!.docs[index];
              var data = carDoc.data() as Map<String, dynamic>;
              
              return GestureDetector(
                onTap: () {
                  // Saat mobil diklik, pindah ke FuelScreen dengan membawa ID Mobil
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FuelScreen(
                        carId: carDoc.id, 
                        carName: "${data['merk']} - ${data['plat']}",
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Foto Mobil (Thumbnail)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: data['photo_url'] != null
                              ? DecorationImage(image: NetworkImage(data['photo_url']), fit: BoxFit.cover)
                              : null,
                        ),
                        child: data['photo_url'] == null 
                            ? Icon(Icons.directions_car, color: Colors.grey[400]) 
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Info Mobil
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['merk'] ?? "Tanpa Merk",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              data['plat'] ?? "No Plat",
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF5CB85C)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}