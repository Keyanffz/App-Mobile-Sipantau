import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FuelAddScreen extends StatefulWidget {
  final String carId; // Menerima Car ID
  const FuelAddScreen({super.key, required this.carId});

  @override
  State<FuelAddScreen> createState() => _FuelAddScreenState();
}

class _FuelAddScreenState extends State<FuelAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _literController = TextEditingController();
  final _priceController = TextEditingController();
  final _odoController = TextEditingController();
  final _dateController = TextEditingController();
  
  String? _selectedFuelType;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  final List<String> _fuelOptions = ['Pertalite', 'Pertamax', 'Pertamax Turbo', 'Solar', 'Dexlite'];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd MMM yyyy').format(_selectedDate);
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFuelType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih jenis bahan bakar")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      await FirebaseFirestore.instance.collection('fuel_logs').add({
        'userId': user?.uid,
        'carId': widget.carId, // PENTING: Menyimpan ID Mobil
        'liters': double.tryParse(_literController.text) ?? 0,
        'totalPrice': double.tryParse(_priceController.text) ?? 0,
        'odometer': int.tryParse(_odoController.text) ?? 0,
        'fuelType': _selectedFuelType,
        'date': Timestamp.fromDate(_selectedDate),
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data tersimpan!"), backgroundColor: Color(0xFF5CB85C)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (Bagian widget _buildInput dan build() UI-nya sama persis seperti sebelumnya)
  // Hanya pastikan class Definition di atas sudah pakai "widget.carId"
  
  Widget _buildInput(String label, TextEditingController controller, String hint, {bool isNumber = false, bool isReadOnly = false, VoidCallback? onTap}) {
     return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            onTap: onTap,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Isi BBM", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5CB85C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("Jenis Bahan Bakar", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFuelType,
                    isExpanded: true,
                    hint: const Text("Pilih jenis BBM"),
                    items: _fuelOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _selectedFuelType = val),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInput("Total Biaya (Rp)", _priceController, "Contoh: 50000", isNumber: true),
              _buildInput("Jumlah Liter", _literController, "Contoh: 3.5", isNumber: true),
              _buildInput("Odometer", _odoController, "KM saat ini", isNumber: true),
              _buildInput("Tanggal", _dateController, "", isReadOnly: true, onTap: () async {
                 DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                 if(picked != null) setState(() { _selectedDate = picked; _dateController.text = DateFormat('dd MMM yyyy').format(picked); });
              }),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5CB85C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isLoading ? null : _saveData,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ))
            ],
          ),
        ),
      ),
    );
  }
}