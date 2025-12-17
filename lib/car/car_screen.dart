import 'package:flutter/material.dart';

class CarScreen extends StatelessWidget {
  const CarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Logika Dark Mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("CAR",
            style: TextStyle(
                color: Color(0xFF5CB85C),
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_filled_outlined,
                size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text("Tidak ada kendaraan yang\nsedang dipilih",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CB85C),
                  foregroundColor: Colors.white),
              child: const Text("Pilih Kendaraan"),
            )
          ],
        ),
      ),
    );
  }
}
