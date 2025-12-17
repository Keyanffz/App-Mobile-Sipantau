import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CarAddScreen extends StatefulWidget {
  const CarAddScreen({super.key});

  @override
  State<CarAddScreen> createState() => _CarAddScreenState();
}

class _CarAddScreenState extends State<CarAddScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  // Controllers Text
  final _namaController = TextEditingController();
  final _platController = TextEditingController();
  final _tahunController = TextEditingController();
  final _pajakController = TextEditingController();
  final _warnaController = TextEditingController();
  final _odoController = TextEditingController(); // BARU: Odometer
  final _rangkaController = TextEditingController();
  final _mesinController = TextEditingController();

  // Controllers Pilihan (Dropdown)
  String? _selectedTransmisi; // BARU: Transmisi
  String? _selectedBbm; // BARU: Bahan Bakar

  // Opsi Dropdown
  final List<String> _transmisiOptions = ['Manual', 'Matic'];
  final List<String> _bbmOptions = ['Bensin', 'Diesel'];

  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  // --- FUNGSI PILIH FOTO ---
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

  // --- FUNGSI BUKA KALENDER ---
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5CB85C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _pajakController.text =
            DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
      });
    }
  }

  // --- FUNGSI UPLOAD ---
  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return null;
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

  // --- FUNGSI SIMPAN ---
  Future<void> _saveCar() async {
    // Validasi Input Dasar
    if (_namaController.text.isEmpty ||
        _platController.text.isEmpty ||
        _pajakController.text.isEmpty ||
        _odoController.text.isEmpty ||
        _selectedTransmisi == null ||
        _selectedBbm == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Semua data wajib dilengkapi!"),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl;
      if (_imageBytes != null) {
        photoUrl = await _uploadImage();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('cars')
          .add({
        'merk': _namaController.text,
        'plat': _platController.text,
        'tahun': _tahunController.text,
        'pajak_date': _pajakController.text,
        'warna': _warnaController.text,
        'odo': _odoController.text, // SIMPAN ODOMETER
        'transmisi': _selectedTransmisi, // SIMPAN TRANSMISI
        'bbm': _selectedBbm, // SIMPAN BBM
        'rangka': _rangkaController.text,
        'mesin': _mesinController.text,
        'photo_url': photoUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Kendaraan berhasil ditambahkan!"),
            backgroundColor: Colors.green));
        Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5CB85C)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Tambah Kendaraan",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. NAMA
            _buildInput("Nama Kendaraan", _namaController,
                "Kendaraan harus sesuai dengan yang ada di STNK!"),

            // 2. PLAT
            _buildInput("Plat Nomor", _platController,
                "Plat nomor harus sudah terdaftar di SAMSAT"),

            // 3. TAHUN
            _buildInput("Tahun Pembuatan", _tahunController,
                "Tahun pembuatan sesuai BPKB",
                isNumber: true),

            // 4. PAJAK
            _buildInput("Pajak Kendaraan", _pajakController,
                "Tanggal jatuh tempo pajak sesuai STNK",
                isReadOnly: true, onTap: _pickDate, icon: Icons.calendar_today),

            // 5. WARNA
            _buildInput("Warna Kendaraan", _warnaController,
                "Harus sesuai dengan STNK"),

            // 6. TRANSMISI (DROPDOWN)
            _buildDropdown(
                "Jenis Transmisi",
                _selectedTransmisi,
                _transmisiOptions,
                (val) => setState(() => _selectedTransmisi = val),
                "Pilih Manual atau Matic sesuai fisik kendaraan"),

            // 7. BAHAN BAKAR (DROPDOWN)
            _buildDropdown(
                "Jenis Bahan Bakar",
                _selectedBbm,
                _bbmOptions,
                (val) => setState(() => _selectedBbm = val),
                "Pastikan jenis bahan bakar sesuai rekomendasi pabrikan"),

            // 8. ODOMETER
            _buildInput("Odometer Saat Ini", _odoController,
                "Masukkan angka KM terakhir yang tertera di dashboard",
                isNumber: true,
                suffixText: "KM" // Tambahan teks "KM" di dalam kotak
                ),

            // 9. UPLOAD FOTO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Upload Foto Kendaraan",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                _buildTooltipIcon(
                    "Foto harus jelas dan sesuai kondisi fisik terkini")
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt_outlined, color: Colors.black),
                    const SizedBox(width: 10),
                    Text(
                        _imageBytes != null
                            ? "Foto Terpilih (Ganti)"
                            : "Pilih Foto",
                        style: const TextStyle(color: Colors.black)),
                    const Spacer(),
                    if (_imageBytes != null)
                      const Icon(Icons.check_circle, color: Colors.green)
                  ],
                ),
              ),
            ),
            if (_imageBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.memory(_imageBytes!,
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),

            const SizedBox(height: 16),

            // 10. RANGKA
            _buildInput(
                "Nomor Rangka", _rangkaController, "Harus sesuai dengan STNK!"),

            // 11. MESIN
            _buildInput("Nomor Mesin", _mesinController,
                "Cek fisik nomor mesin dan sesuaikan dengan STNK!"),

            const SizedBox(height: 30),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5CB85C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Tambah",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: INPUT TEXT ---
  Widget _buildInput(
      String label, TextEditingController controller, String tooltipMessage,
      {bool isNumber = false,
      bool isReadOnly = false,
      VoidCallback? onTap,
      IconData? icon,
      String? suffixText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            readOnly: isReadOnly,
            onTap: onTap,
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
              // Jika ada suffixText (KM), tampilkan teks. Jika tidak, tampilkan Tooltip
              suffixIcon: suffixText != null
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(suffixText,
                          style: const TextStyle(fontWeight: FontWeight.bold)))
                  : _buildTooltipIcon(tooltipMessage),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: DROPDOWN (Manual/Matic & Bensin/Diesel) ---
  Widget _buildDropdown(
      String label,
      String? currentValue,
      List<String> options,
      Function(String?) onChanged,
      String tooltipMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: currentValue,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              suffixIcon: _buildTooltipIcon(tooltipMessage),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: ICON TOOLTIP ---
  Widget _buildTooltipIcon(String message) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      decoration: BoxDecoration(
          color: const Color(0xFFFFECEC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200)),
      textStyle: const TextStyle(color: Colors.red, fontSize: 12),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.error_outline, color: Colors.grey, size: 22),
    );
  }
}
