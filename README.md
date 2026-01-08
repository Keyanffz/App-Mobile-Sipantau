# 🚗 Si-Pantau (Sistem Pantau Kendaraan) 🏍️

**Si-Pantau** adalah aplikasi asisten pintar berbasis Mobile yang dirancang untuk membantu pemilik kendaraan memantau kesehatan mesin, konsumsi bahan bakar, dan riwayat perjalanan secara real-time.

Aplikasi ini tidak hanya mencatat riwayat, tetapi juga memberikan **analisis cerdas** kapan kendaraan Anda harus segera masuk bengkel berdasarkan waktu dan jarak tempuh (odometer).

---

## 🌟 Fitur Utama

### 1. Smart Service Dashboard
Fitur unggulan yang menggunakan logika dual-check untuk menentukan status servis:
* **Dinamis Berdasarkan Tipe:** Membedakan interval servis antara Mobil (6 bulan) dan Motor (2 bulan).
* **Odometer Tracking:** Memberikan peringatan otomatis ganti oli jika pemakaian sudah mencapai ambang batas:
    * **Motor:** 3.000 KM
    * **Mobil:** 10.000 KM
* **Status Alert:** Label visual (Lewat Jadwal/Limit KM) untuk mencegah kerusakan mesin.

### 2. Monitoring Bahan Bakar (Fuel Logs)
Mencatat setiap pengisian bahan bakar untuk memantau efisiensi konsumsi dan pengeluaran biaya bulanan.

### 3. Log Perjalanan (Journey Tracker)
Mencatat jarak yang ditempuh setiap perjalanan untuk sinkronisasi otomatis dengan odometer sistem.

### 4. Cloud Integration
Seluruh data tersimpan aman di **Firebase Firestore** dan terhubung dengan **Firebase Auth** untuk keamanan akun pengguna.

---

## 🚀 Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Database:** [Google Firebase Firestore](https://firebase.google.com/docs/firestore)
* **Authentication:** Firebase Auth
* **UI/Design:** Google Fonts (Poppins), Custom Widgets.

---

## 📸 Tampilan Aplikasi

| Dashboard Service | Info Kendaraan | Log Bahan Bakar |
|---|---|---|
| ![Service](https://via.placeholder.com/200x400?text=Service+UI) | ![Vehicle](https://via.placeholder.com/200x400?text=Vehicle+UI) | ![Fuel](https://via.placeholder.com/200x400?text=Fuel+UI) |

> *Tips: Ganti link gambar di atas dengan screenshot asli aplikasi kamu untuk hasil maksimal!*

---

## 🛠️ Instalasi

1.  **Clone repository ini:**
    ```bash
    git clone [https://github.com/Keyanffz/App-Mobile-Sipantau.git](https://github.com/Keyanffz/App-Mobile-Sipantau.git)
    ```
2.  **Masuk ke direktori:**
    ```bash
    cd App-Mobile-Sipantau
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Konfigurasi Firebase:**
    * Buat project baru di Firebase Console.
    * Download `google-services.json` (Android) dan masukkan ke folder `android/app/`.
5.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---

## 👨‍💻 Kontributor
* **Keyanffz** - Developer Utama & UI Implementation
* **Xeno-code7** - Collaborator

---

## 📄 Lisensi
Project ini dibuat untuk tujuan pembelajaran dan pengembangan portofolio.
