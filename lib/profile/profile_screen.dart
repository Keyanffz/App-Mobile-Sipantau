import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // PENTING: Untuk mengatasi error 'User' & 'FirebaseAuth'
import 'package:google_fonts/google_fonts.dart'; // PENTING: Untuk mengatasi error 'GoogleFonts'

// Import file dari luar folder profile (Naik satu level pakai ../)
import '../login_screen.dart';
import '../main.dart';

// Import file yang ada di dalam folder yang sama
import 'edit_profile_screen.dart';
import 'history_login_screen.dart';
import 'security_screen.dart';
import 'about_app_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan StreamBuilder agar saat nama diedit, halaman Profile otomatis terupdate
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          final User? user = snapshot.data;

          // Ambil data user (Nama, Email, Foto)
          final String displayName = user?.displayName ?? "Pengguna Sipantau";
          final String email = user?.email ?? "Belum ada email";
          final String? photoUrl = user?.photoURL;

          // Logika Tema Gelap/Terang
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final cardColor = Theme.of(context).cardColor;
          final textColor = isDarkMode ? Colors.white : Colors.black;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Judul Halaman
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("PROFILE",
                            style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF5CB85C)))),
                    const SizedBox(height: 20),

                    // Foto Profil Lingkaran
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF5CB85C), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Nama & Email
                    Text(displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    Text(email, style: const TextStyle(color: Colors.grey)),

                    const SizedBox(height: 30),

                    // Menu Navigasi
                    _buildMenuTile(
                        context,
                        "Edit Profile",
                        Icons.person_outline,
                        cardColor,
                        textColor,
                        const EditProfileScreen()),
                    _buildMenuTile(context, "History Login", Icons.history,
                        cardColor, textColor, const HistoryLoginScreen()),
                    _buildMenuTile(
                        context,
                        "Login and Security",
                        Icons.security,
                        cardColor,
                        textColor,
                        const SecurityScreen()),
                    _buildMenuTile(
                        context,
                        "Tentang Aplikasi",
                        Icons.info_outline,
                        cardColor,
                        textColor,
                        const AboutAppScreen()),

                    // Tombol Saklar Dark Mode
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12)),
                      child: SwitchListTile(
                        title: Text("Dark Mode",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, color: textColor)),
                        secondary:
                            Icon(Icons.dark_mode_outlined, color: textColor),
                        activeThumbColor: const Color(0xFF5CB85C),
                        value: themeNotifier.value == ThemeMode.dark,
                        onChanged: (bool value) {
                          themeNotifier.value =
                              value ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tombol Log Out
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (route) => false);
                          }
                        },
                        child: const Text("Log Out",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  // Widget Helper untuk membuat tombol menu
  Widget _buildMenuTile(BuildContext context, String title, IconData icon,
      Color bgColor, Color txtColor, Widget destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: txtColor),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.w600, color: txtColor)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination));
        },
      ),
    );
  }
}
