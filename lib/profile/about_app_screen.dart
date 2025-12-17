import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Tentang Aplikasi",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.directions_car_filled_outlined,
                      size: 80, color: Color(0xFF5CB85C)),
                  Text(
                    'SIPANTAU',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF5CB85C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Sipantau adalah aplikasi mobile yang dirancang untuk membantu perusahaan dalam memantau dan mengelola kendaraan operasional secara efisien.\n\n"
              "Dengan Sipantau, Anda dapat mencatat dan melacak berbagai informasi penting seperti:",
              textAlign: TextAlign.justify,
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                "Riwayat pengeluaran service kendaraan", textColor),
            _buildBulletPoint(
                "Konsumsi dan biaya bahan bakar (BBM)", textColor),
            _buildBulletPoint("Laporan kerusakan dan perbaikan", textColor),
            _buildBulletPoint(
                "Rekap laporan lengkap setiap kendaraan", textColor),
            const SizedBox(height: 20),
            Text(
              "Aplikasi ini memberikan kemudahan dalam pengawasan armada kendaraan, membantu pengambilan keputusan berbasis data, serta meningkatkan efisiensi dan transparansi dalam manajemen kendaraan perusahaan.",
              textAlign: TextAlign.justify,
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 30),
            Text("Kontak & Informasi:", style: TextStyle(color: textColor)),
            Text("support@sipantau.id",
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("© 2025 PT. sipantau Teknologi",
                style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ",
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
