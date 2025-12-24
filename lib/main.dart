import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/notification_helper.dart'; // [cite: 189]

// Import halaman-halaman penting
import 'login_screen.dart'; // [cite: 189]
import 'main_navigation.dart'; // [cite: 190]

// 1. Variabel Global untuk Mengontrol Tema (Light/Dark Mode)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light); // [cite: 190]

void main() async {
  // Memastikan semua komponen Flutter siap sebelum menjalankan kode lain
  WidgetsFlutterBinding.ensureInitialized(); // [cite: 190]
  
  // Inisialisasi sistem notifikasi
  await NotificationHelper.init(); // [cite: 191]

  // --- SOLUSI ERROR ANDROID ---
  // Kita buat satu variabel untuk menampung konfigurasi Firebase
  const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyBFGKtYHdRsTf_g_J_o9fMboiziQrXx7xs", // [cite: 191]
    authDomain: "test-sipantau.firebaseapp.com",
    projectId: "test-sipantau",
    storageBucket: "test-sipantau.firebasestorage.app",
    messagingSenderId: "313304355828",
    appId: "1:313304355828:web:30efd9dc9ce5a4ba009fa1", // 
    measurementId: "G-80JJR4DSY5",
  );

  // Inisialisasi Firebase menggunakan options di atas agar Android & Web sama-sama lancar
  await Firebase.initializeApp(options: firebaseOptions); // 

  // JALANKAN APLIKASI
  runApp(const SipantauApp()); // 
}

class SipantauApp extends StatelessWidget {
  const SipantauApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan tema (Dark/Light)
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, // [cite: 194]
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'SIPANTAU',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // [cite: 194]

          // --- TEMA TERANG (LIGHT) ---
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF5CB85C), // [cite: 195]
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF5CB85C),
                brightness: Brightness.light),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(), // [cite: 196]
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
          ),

          // --- TEMA GELAP (DARK) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF5CB85C), // [cite: 197]
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF5CB85C),
                brightness: Brightness.dark), // [cite: 198]
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white), // [cite: 199]
            ),
            cardColor: const Color(0xFF1E1E1E),
          ),

          // StreamBuilder untuk cek status login
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(), // [cite: 200]
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()), // [cite: 201]
                );
              }

              if (snapshot.hasData) {
                return const MainNavigation(); // [cite: 202]
              }

              return const LoginScreen(); // [cite: 203]
            },
          ),
        );
      },
    );
  }
}