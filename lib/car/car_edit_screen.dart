import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CarEditScreen extends StatefulWidget {
  // Kita butuh ID Dokumen untuk tahu mobil mana yang diedit
  final String docId;
  final Map<String, dynamic> currentData;

  const CarEditScreen({
    super.key,
    required this.docId,
    required this.currentData,
  });

  @override
  State<CarEditScreen> createState() => _CarEditScreenState();
}

class _CarEditScreenState extends State<CarEditScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _platController = TextEditingController();
  final _tahunController = TextEditingController();
  final _pajakController = TextEditingController();
  final _warnaController = TextEditingController();
  final _odoController = TextEditingController();
  final _rangkaController = TextEditingController();
  final _mesinController = TextEditingController();

  // Dropdown
  String? _selectedTransmisi;
  String? _selectedBbm;
  final List<String> _transmisiOptions = ['Manual', 'Matic'];
  final List<String> _bbmOptions = ['Bensin', 'Diesel'];

  // Foto
  Uint8List? _imageBytes;
  String? _oldPhotoUrl; // Untuk menyimpan link foto lama

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadInitialData();
  }

  void _loadInitialData() {
    var data = widget.currentData;

    _namaController.text = data['merk'] ?? "";
    _platController.text = data['plat'] ?? "";
    _tahunController.text = data['tahun'] ?? "";
    _pajakController.text = data['pajak_date'] ?? "";
    _warnaController.text = data['warna'] ?? "";
    _odoController.text = data['odo'] ?? "";
    _rangkaController.text = data['rangka'] ?? "";
    _mesinController.text = data['mesin'] ?? "";

    _selectedTransmisi = data['transmisi'];
    _selectedBbm = data['bbm'];

    // Pastikan nilai dropdown valid (ada di dalam list opsi)
    if (!_transmisiOptions.contains(_selectedTransmisi)) {
      _selectedTransmisi = null;
    }
    if (!_bbmOptions.contains(_selectedBbm)) _selectedBbm = null;

    _oldPhotoUrl = data['photo_url'];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: Color(0xFF5CB85C),
                onPrimary: Colors.white,
                onSurface: Colors.black)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _pajakController.text =
            DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) {
      return _oldPhotoUrl; // Kalau gak ganti foto, pakai yang lama
    }
    try {
      final String uid = user!.uid;
      final String fileName =
          'car_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          FirebaseStorage.instance.ref().child('car_photos/$uid/$fileName');
      final SettableMetadata metadata =
          SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(_imageBytes!, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Gagal upload foto: $e");
    }
  }

  // --- FUNGSI UPDATE DATA ---
  Future<void> _updateCar() async {
    if (_namaController.text.isEmpty ||
        _platController.text.isEmpty ||
        _pajakController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Data wajib tidak boleh kosong!"),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Foto Baru (Jika ada)
      String? photoUrl = await _uploadImage();

      // 2. Update Firestore
      // Perhatikan: Kita pakai .update(), bukan .add()
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('cars')
          .doc(widget.docId) // Update dokumen yang spesifik
          .update({
        'merk': _namaController.text,
        'plat': _platController.text,
        'tahun': _tahunController.text,
        'pajak_date': _pajakController.text,
        'warna': _warnaController.text,
        'odo': _odoController.text,
        'transmisi': _selectedTransmisi,
        'bbm': _selectedBbm,
        'rangka': _rangkaController.text,
        'mesin': _mesinController.text,
        'photo_url': photoUrl,
        // created_at tidak perlu diupdate
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Data berhasil diperbarui!"),
            backgroundColor: Colors.green));
        Navigator.pop(context); // Kembali ke Detail
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic Preview Foto: Byte (Baru) > URL (Lama) > Icon (Kosong)
    ImageProvider? finalImage;
    if (_imageBytes != null) {
      finalImage = MemoryImage(_imageBytes!);
    } else if (_oldPhotoUrl != null) {
      finalImage = NetworkImage(_oldPhotoUrl!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Kendaraan",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5CB85C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                      image: finalImage != null
                          ? DecorationImage(
                              image: finalImage, fit: BoxFit.cover)
                          : null,
                    ),
                    child: finalImage == null
                        ? const Icon(Icons.camera_alt,
                            size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: Color(0xFF5CB85C), shape: BoxShape.circle),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.white))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildInput("Nama Kendaraan", _namaController, "Wajib diisi"),
            _buildInput("Plat Nomor", _platController, "Wajib diisi"),
            _buildInput("Tahun Pembuatan", _tahunController, "Sesuai BPKB",
                isNumber: true),
            _buildInput("Pajak Kendaraan", _pajakController, "Sesuai STNK",
                isReadOnly: true, onTap: _pickDate, icon: Icons.calendar_today),
            _buildInput("Warna Kendaraan", _warnaController, "Sesuai STNK"),
            _buildDropdown(
                "Jenis Transmisi",
                _selectedTransmisi,
                _transmisiOptions,
                (val) => setState(() => _selectedTransmisi = val)),
            _buildDropdown("Jenis Bahan Bakar", _selectedBbm, _bbmOptions,
                (val) => setState(() => _selectedBbm = val)),
            _buildInput(
                "Odometer Saat Ini", _odoController, "Update KM terakhir",
                isNumber: true, suffixText: "KM"),
            _buildInput("Nomor Rangka", _rangkaController, "Cek STNK"),
            _buildInput("Nomor Mesin", _mesinController, "Cek STNK"),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5CB85C),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: _isLoading ? null : _updateCar,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
      String label, TextEditingController controller, String tooltip,
      {bool isNumber = false,
      bool isReadOnly = false,
      VoidCallback? onTap,
      IconData? icon,
      String? suffixText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: isReadOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: suffixText != null
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(suffixText,
                      style: const TextStyle(fontWeight: FontWeight.bold)))
              : Tooltip(
                  message: tooltip,
                  triggerMode: TooltipTriggerMode.tap,
                  child: const Icon(Icons.info_outline, color: Colors.grey)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? val, List<String> opts,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField(
        initialValue: val,
        items: opts
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50]),
      ),
    );
  }
}
