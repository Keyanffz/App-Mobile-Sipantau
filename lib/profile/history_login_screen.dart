import 'package:flutter/material.dart';

class HistoryLoginScreen extends StatelessWidget {
  const HistoryLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("History Login",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Device
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
                color: cardColor,
              ),
              child: Row(
                children: [
                  Icon(Icons.devices, size: 40, color: Colors.blue[300]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Iphone 7 Plus",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor)),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: textColor, fontSize: 12),
                            children: const [
                              TextSpan(text: "Semarang, Indonesia - "),
                              TextSpan(
                                  text: "Device ini",
                                  style: TextStyle(color: Colors.orange)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("Login pada device lainnya",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor)),
            const SizedBox(height: 12),

            // List Device Lain (Dummy Data)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.blue), // Border biru putus-putus simulasi
                borderRadius: BorderRadius.circular(12),
                color: cardColor,
              ),
              child: Column(
                children: [
                  _buildHistoryItem(
                      "Iphone 7 Plus", "13:50", "10 Maret 2028", textColor),
                  const Divider(),
                  _buildHistoryItem("Iphone 16 Pro Max", "22:46",
                      "10 Januari 2028", textColor),
                  const Divider(),
                  _buildHistoryItem(
                      "Vivo IQOO Z9 5G", "13:13", "5 Desember 2026", textColor),
                  const Divider(),
                  _buildHistoryItem(
                      "Windows", "08:30", "20 Agsutus 2025", textColor),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      String device, String time, String date, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.phone_android, size: 30, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor)),
                Text("Semarang, Indonesia * jam $time",
                    style: TextStyle(fontSize: 12, color: textColor)),
                Text("tanggal $date",
                    style: TextStyle(fontSize: 12, color: textColor)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
