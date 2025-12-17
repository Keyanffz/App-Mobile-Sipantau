import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(_passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password berhasil diganti!"), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e. Pastikan anda baru saja login."), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showChangePasswordDialog(Color textColor, Color dialogColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogColor,
        title: Text("Ganti Password", style: TextStyle(color: textColor)),
        content: TextField(
          controller: _passwordController,
          style: TextStyle(color: textColor),
          decoration: const InputDecoration(hintText: "Password Baru", hintStyle: TextStyle(color: Colors.grey)),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5CB85C)),
            onPressed: () {
              Navigator.pop(context);
              _changePassword();
            }, 
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Login and Security", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Mengelola kata sandi anda, email, serta mengamankan akun anda",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            _buildSecurityButton("Ganti Password", () => _showChangePasswordDialog(textColor, cardColor), cardColor!, textColor),
            const SizedBox(height: 16),
            _buildSecurityButton("Ganti Email", () {}, cardColor, textColor), // Logika ganti email bisa ditambahkan serupa
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityButton(String text, VoidCallback onTap, Color color, Color textColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            Icon(Icons.arrow_forward_ios, size: 16, color: textColor)
          ],
        ),
      ),
    );
  }
}