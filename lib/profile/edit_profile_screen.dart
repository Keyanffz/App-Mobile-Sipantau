import 'dart:typed_data'; // Untuk membaca data gambar (Bytes)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Database Cloud
import 'package:image_picker/image_picker.dart'; // Buka Galeri
import 'package:firebase_storage/firebase_storage.dart'; // Upload File

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // Controller untuk Form Input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedGender = 'Pria';
  bool _isLoading = false;

  // Variabel untuk menampung gambar sementara (Preview sebelum upload)
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore(); // Load data saat halaman dibuka
  }

  // --- 1. FUNGSI LOAD DATA DARI DATABASE ---
  Future<void> _loadDataFromFirestore() async {
    if (user == null) return;

    try {
      // Ambil dokumen user dari koleksi 'users'
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (mounted) {
        setState(() {
          // Isi form dengan data dari database (jika ada), kalau tidak pakai data Auth/Default
          _nameController.text =
              doc.data()?['nama_lengkap'] ?? user?.displayName ?? "";
          _usernameController.text = doc.data()?['username'] ?? "Fauzi";
          _phoneController.text = doc.data()?['phone'] ?? "089522466667";
          _selectedGender = doc.data()?['gender'] ?? "Pria";
        });
      }
    } catch (e) {
      print("Gagal load data: $e");
    }
  }

  // --- 2. FUNGSI PILIH GAMBAR DARI GALERI ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Buka galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Baca gambar sebagai 'Bytes' (agar jalan di Web & HP)
      final Uint8List bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes; // Tampilkan preview
      });
    }
  }

  // --- 3. FUNGSI UPLOAD KE FIREBASE STORAGE ---
  Future<String?> _uploadImageToStorage() async {
    if (_imageBytes == null) return null; // Kalau gak ada gambar baru, skip

    try {
      // Buat nama file unik pakai ID user
      final String uid = user!.uid;
      final String fileName = 'profile_$uid.jpg';

      // Siapkan lokasi penyimpanan
      final Reference ref =
          FirebaseStorage.instance.ref().child('profile_pictures/$fileName');

      // Metadata agar browser tahu ini gambar
      final SettableMetadata metadata =
          SettableMetadata(contentType: 'image/jpeg');

      // Upload Data
      await ref.putData(_imageBytes!, metadata);

      // Ambil Link Download (URL)
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Gagal upload gambar: $e");
    }
  }

  // --- 4. FUNGSI SIMPAN SEMUA DATA ---
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      // A. Jika ada gambar baru dipilih, Upload dulu!
      String? newPhotoUrl;
      if (_imageBytes != null) {
        newPhotoUrl = await _uploadImageToStorage();
      }

      // B. Update Data User di Firebase Auth (Nama & Foto Dasar)
      if (newPhotoUrl != null) {
        await user?.updatePhotoURL(newPhotoUrl);
      }
      if (_nameController.text.isNotEmpty) {
        await user?.updateDisplayName(_nameController.text);
      }

      // Refresh data user di aplikasi
      await user?.reload();

      // C. SIMPAN KE FIRESTORE DATABASE (PENTING!)
      // Ini yang bikin Username dan Foto terbaca di Home Screen
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'nama_lengkap': _nameController.text,
        'username': _usernameController.text,
        'phone': _phoneController.text,
        'gender': _selectedGender,
        'email': user?.email,

        // Simpan Link Foto ke Database (Pakai foto baru jika ada, atau foto lama)
        'photo_url': newPhotoUrl ?? user?.photoURL,
      }, SetOptions(merge: true)); // merge: true agar data lain tidak hilang

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profil berhasil diperbarui!"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kembali ke menu sebelumnya
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final inputColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100];

    // Logika Preview Foto:
    ImageProvider? finalImage;
    if (_imageBytes != null) {
      finalImage = MemoryImage(_imageBytes!); // Gambar baru dari galeri
    } else if (user?.photoURL != null) {
      finalImage = NetworkImage(user!.photoURL!); // Gambar lama dari internet
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Edit Profile",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage, // KLIK DISINI UNTUK BUKA GALERI
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.grey.shade300, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: finalImage,
                            child: finalImage == null
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.grey)
                                : null,
                          ),
                        ),
                        // Ikon kamera kecil
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF5CB85C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: const Text("Ganti foto profile",
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel("Nama (Untuk Profil)", textColor),
            _buildInput(_nameController, inputColor!, textColor),

            _buildLabel("Username (Sapaan di Home)", textColor),
            _buildInput(_usernameController, inputColor, textColor),

            _buildLabel("Nomor Telepon", textColor),
            _buildInput(_phoneController, inputColor, textColor,
                isNumber: true),

            _buildLabel("Jenis Kelamin", textColor),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: inputColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  dropdownColor: inputColor,
                  isExpanded: true,
                  style: TextStyle(color: textColor),
                  items: ['Pria', 'Wanita'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedGender = newValue),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CB85C),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(text,
          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildInput(
      TextEditingController controller, Color bgColor, Color textColor,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
