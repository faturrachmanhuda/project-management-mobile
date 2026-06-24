import 'package:flutter/foundation.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:math' as math;

import '../file_storage_helper.dart';
import '../uploaded_file_type.dart';

/// ViewModel yang mengelola seluruh lifecycle upload file:
/// - Memilih file dari storage (FilePicker) atau kamera (ImagePicker)
/// - Kompresi gambar sebelum proses (flutter_image_compress)
/// - Simpan ke file lokal → path disimpan in-memory (FileStorageHelper)
/// - Hapus file lokal + reset state
/// - Tidak ada lagi penyimpanan base64 ke SharedPreferences
class UploadFileViewModel extends ChangeNotifier {
  // ─── Status (State) ───────────────────────────────────────────────────────────

  bool _sedangMemuat = false;
  bool _sedangMerekam = false;
  String? _pesanError;
  String? _namaFile;
  String? _tipeFile;
  Uint8List? _bytesTampilan;
  UploadedFileType? _tipeFileUnggahan;

  // Status untuk file yang baru dipilih/direkam tapi belum di-upload (Menunggu Konfirmasi)
  Uint8List? _bytesTertunda;
  String? _namaFileTertunda;
  UploadedFileType? _tipeFileTertunda;
  int? _ukuranFileTertunda;

  int? _ukuranFile;
  String? _localFilePath;

  final _alatRekam = AudioRecorder();

  // ─── Getter (Pengambil Nilai) ───────────────────────────────────────────────

  bool get sedangMemuat => _sedangMemuat;
  bool get sedangMerekam => _sedangMerekam;
  String? get pesanError => _pesanError;
  String? get namaFile => _namaFile;
  String? get tipeFile => _tipeFile;

  /// Bytes untuk ditampilkan langsung di Image.memory() – hanya tersedia untuk gambar
  Uint8List? get bytesTampilan => _bytesTampilan;

  /// Tipe file yang terdeteksi (image, pdf, other)
  UploadedFileType? get tipeFileUnggahan => _tipeFileUnggahan;

  /// True jika ada file yang sudah dipilih / dimuat dari storage
  bool get adaFile => _localFilePath != null && _localFilePath!.isNotEmpty;

  /// True jika ada file yang sedang menunggu konfirmasi upload
  bool get adaFileTertunda => _bytesTertunda != null;
  String? get namaFileTertunda => _namaFileTertunda;
  UploadedFileType? get tipeFileTertunda => _tipeFileTertunda;
  Uint8List? get bytesTertunda => _bytesTertunda;
  
  /// Ukuran file yang sudah di-upload dalam format string (KB/MB)
  String get tampilanUkuranFile => _formatUkuran(_ukuranFile ?? 0);
  
  /// Path file lokal hasil penyimpanan bytes (digunakan untuk upload multipart)
  String? get localFilePath => _localFilePath;
  
  /// Ukuran file pending dalam format string
  String get tampilanUkuranTertunda => _formatUkuran(_ukuranFileTertunda ?? 0);

  // ─── Internal Helper ─────────────────────────────────────────────────────────

  bool _cekBisaUnggah() {
    if (adaFile) {
      _setError('Sudah ada file yang ter-upload. Hapus file lama terlebih dahulu.');
      return false;
    }
    return true;
  }

  // ─── Public Methods ───────────────────────────────────────────────────────────

  Future<void> ambilDariPenyimpanan(String activityId) async {
    try {
      if (!_cekBisaUnggah()) return;
      _setLoading(true);
      _hapusPesanError();

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true, // pastikan bytes tersedia di web/mobile
      );

      if (result == null || result.files.isEmpty) {
        _setLoading(false);
        return;
      }

      final file = result.files.single;
      final tipeTerdeteksi = detectUploadedFileType(file.name);

      Uint8List? bytes;

      if (tipeTerdeteksi == UploadedFileType.image) {
        // Kompresi gambar jika file berasal dari path (mobile)
        if (file.path != null) {
          bytes = await _kompresDariPath(file.path!);
        } else if (file.bytes != null) {
          // Web: bytes langsung tersedia, lakukan kompresi in-memory
          bytes = await _kompresDariBytes(file.bytes!);
        }
      } else {
        // Non-gambar: pakai bytes langsung
        bytes = file.bytes;
        if (bytes == null && file.path != null) {
          bytes = await _bacaBytesDariPath(file.path!);
        }
      }

      if (bytes == null || bytes.isEmpty) {
        _setError('Gagal membaca file. Pastikan file tidak kosong.');
        _setLoading(false);
        return;
      }

      // Masukkan ke status pending untuk konfirmasi user
      _bytesTertunda = bytes;
      _namaFileTertunda = file.name;
      _tipeFileTertunda = tipeTerdeteksi;
      _ukuranFileTertunda = bytes.length;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('UploadFileViewModel.ambilDariPenyimpanan error: $e\n$stack');
      _setError('Terjadi kesalahan saat memilih file: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> mulaiMerekam() async {
    try {
      if (!_cekBisaUnggah()) return;
      _hapusPesanError();
      if (await _alatRekam.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final recPath = '${tempDir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _alatRekam.start(const RecordConfig(), path: recPath);
        _sedangMerekam = true;
        notifyListeners();
      } else {
        _setError('Izin mikrofon ditolak.');
      }
    } catch (e) {
      _setError('Gagal memulai rekaman: $e');
    }
  }

  /// Menghentikan perekaman suara dan memproses hasilnya
  Future<void> berhentiMerekam(String activityId) async {
    try {
      final recPath = await _alatRekam.stop();
      _sedangMerekam = false;
      notifyListeners();

      if (recPath != null) {
        _setLoading(true);
        final file = File(recPath);
        final bytes = await file.readAsBytes();
        final fileName = 'Rekaman_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        _bytesTertunda = bytes;
        _namaFileTertunda = fileName;
        _tipeFileTertunda = UploadedFileType.audio;
        _ukuranFileTertunda = bytes.length;
        notifyListeners();
      }
    } catch (e) {
      _setError('Gagal menghentikan rekaman: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> ambilAudio(String activityId) async {
    try {
      if (!_cekBisaUnggah()) return;
      _setLoading(true);
      _hapusPesanError();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        _setLoading(false);
        return;
      }

      final file = result.files.single;
      final tipeTerdeteksi = detectUploadedFileType(file.name);

      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await _bacaBytesDariPath(file.path!);
      }

      if (bytes == null || bytes.isEmpty) {
        _setError('Gagal membaca file audio.');
        _setLoading(false);
        return;
      }

      _bytesTertunda = bytes;
      _namaFileTertunda = file.name;
      _tipeFileTertunda = tipeTerdeteksi;
      _ukuranFileTertunda = bytes.length;
      notifyListeners();
    } catch (e) {
      _setError('Terjadi kesalahan saat memilih audio: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> ambilDariKamera(String activityId) async {
    try {
      if (!_cekBisaUnggah()) return;
      _setLoading(true);
      _hapusPesanError();

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // kompresi awal dari ImagePicker
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) {
        _setLoading(false);
        return;
      }

      final fileName = image.name.isNotEmpty ? image.name : 'foto_kamera.jpg';

      // Kompresi lebih lanjut menggunakan flutter_image_compress
      Uint8List? bytes = await _kompresDariPath(image.path);

      if (bytes == null || bytes.isEmpty) {
        // Fallback: baca tanpa kompresi tambahan
        bytes = await image.readAsBytes();
      }

      _bytesTertunda = bytes;
      _namaFileTertunda = fileName;
      _tipeFileTertunda = UploadedFileType.image;
      _ukuranFileTertunda = bytes.length;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('UploadFileViewModel.ambilDariKamera error: $e\n$stack');
      _setError('Terjadi kesalahan saat mengakses kamera: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> ambilVideoDariKamera(String activityId) async {
    try {
      if (!_cekBisaUnggah()) return;
      _setLoading(true);
      _hapusPesanError();

      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video == null) {
        _setLoading(false);
        return;
      }

      final fileName = video.name.isNotEmpty ? video.name : 'video_kamera.mp4';
      final bytes = await video.readAsBytes();

      _bytesTertunda = bytes;
      _namaFileTertunda = fileName;
      _tipeFileTertunda = UploadedFileType.video;
      _ukuranFileTertunda = bytes.length;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('UploadFileViewModel.ambilVideoDariKamera error: $e\n$stack');
      _setError('Terjadi kesalahan saat mengakses kamera video: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Memuat informasi file yang tersimpan in-memory berdasarkan [activityId].
  /// Mengembalikan true jika data ditemukan.
  Future<bool> muatFileTersimpan(String activityId) async {
    try {
      _setLoading(true);
      _hapusPesanError();
      final data = FileStorageHelper.readFileForActivity(activityId);
      final simpananPath = data['localFilePath'];
      final simpananNama = data['fileName'];
      final simpananTipe = data['fileType'];

      if (simpananPath == null || simpananPath.isEmpty) {
        _resetStatus();
        return false;
      }

      // Verifikasi file masih ada di disk
      final file = File(simpananPath);
      if (!await file.exists()) {
        FileStorageHelper.clearFileForActivity(activityId);
        _resetStatus();
        return false;
      }

      _namaFile = simpananNama;
      _tipeFile = simpananTipe;
      _localFilePath = simpananPath;
      _tipeFileUnggahan = _analisaTipeFile(simpananTipe);

      final fileBytes = await file.readAsBytes();
      _ukuranFile = fileBytes.length;

      // Decode bytes untuk display (hanya gambar)
      if (_tipeFileUnggahan == UploadedFileType.image) {
        _bytesTampilan = fileBytes;
      } else {
        _bytesTampilan = null;
      }

      notifyListeners();
      return true;
    } catch (e, stack) {
      debugPrint('UploadFileViewModel.muatFileTersimpan error: $e\n$stack');
      _setError('Gagal memuat file tersimpan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Menghapus data file dari in-memory store dan file lokal, lalu reset state UI.
  Future<void> hapusFile(String activityId) async {
    try {
      _setLoading(true);
      _hapusPesanError();

      FileStorageHelper.clearFileForActivity(activityId);
      // Hapus file lokal jika ada
      try {
        if (_localFilePath != null) {
          final f = File(_localFilePath!);
          if (await f.exists()) await f.delete();
        }
      } catch (_) {}
      _resetStatus();
    } catch (e, stack) {
      debugPrint('UploadFileViewModel.hapusFile error: $e\n$stack');
      _setError('Gagal menghapus file: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Reset error message
  void clearError() => _hapusPesanError();

  /// Mengonfirmasi upload file yang sedang pending
  Future<void> konfirmasiUnggah(String activityId) async {
    if (_bytesTertunda == null || _namaFileTertunda == null || _tipeFileTertunda == null) return;
    
    try {
      _setLoading(true);
      await _prosesDanSimpan(
        activityId: activityId,
        namaFile: _namaFileTertunda!,
        tipeFile: _tipeFileTertunda!.name,
        bytes: _bytesTertunda!,
        tipeFileEnum: _tipeFileTertunda!,
        ukuranFile: _ukuranFileTertunda ?? _bytesTertunda!.length,
      );
      _bersihkanTertunda();
    } catch (e) {
      _setError('Gagal mengupload file: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Membatalkan file yang sedang pending
  void batalkanTertunda() {
    _bersihkanTertunda();
    notifyListeners();
  }

  void _bersihkanTertunda() {
    _bytesTertunda = null;
    _namaFileTertunda = null;
    _tipeFileTertunda = null;
    _ukuranFileTertunda = null;
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────────

  /// Proses utama: simpan bytes ke file lokal, update state in-memory.
  /// Tidak ada lagi penyimpanan base64 ke SharedPreferences.
  Future<void> _prosesDanSimpan({
    required String activityId,
    required String namaFile,
    required String tipeFile,
    required Uint8List bytes,
    required UploadedFileType tipeFileEnum,
    required int ukuranFile,
  }) async {
    String filePath = '';

    // Simpan bytes sebagai file lokal agar SyncService dapat meng-upload melalui multipart
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final safeName = namaFile.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
      filePath = path.join(appDir.path, '${DateTime.now().millisecondsSinceEpoch}_$safeName');
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      _localFilePath = file.path;
    } catch (e) {
      debugPrint('Gagal tulis file lokal: $e');
      _localFilePath = null;
    }

    // Simpan metadata ke in-memory store (FileStorageHelper)
    if (filePath.isNotEmpty) {
      FileStorageHelper.saveFileForActivity(
        activityId: activityId,
        fileName: namaFile,
        fileType: tipeFile,
        localFilePath: filePath,
      );
    }

    // Update state
    _namaFile = namaFile;
    _tipeFile = tipeFile;
    _tipeFileUnggahan = tipeFileEnum;
    _ukuranFile = ukuranFile;

    // Decode bytes untuk display (hanya untuk gambar)
    if (tipeFileEnum == UploadedFileType.image) {
      _bytesTampilan = bytes;
    } else {
      _bytesTampilan = null;
    }

    notifyListeners();
  }

  /// Kompresi gambar dari path file (mobile)
  Future<Uint8List?> _kompresDariPath(String filePath) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        filePath,
        quality: 75,
        minWidth: 800,
        minHeight: 600,
      );
      return result;
    } catch (e) {
      debugPrint('Kompresi dari path gagal: $e');
      return null;
    }
  }

  /// Kompresi gambar dari bytes (web)
  Future<Uint8List?> _kompresDariBytes(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 75,
        minWidth: 800,
        minHeight: 600,
      );
      return result;
    } catch (e) {
      debugPrint('Kompresi dari bytes gagal: $e');
      return bytes; // fallback ke bytes asli
    }
  }

  /// Baca bytes dari path secara manual
  Future<Uint8List?> _bacaBytesDariPath(String filePath) async {
    try {
      final file = XFile(filePath);
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Baca bytes dari path gagal: $e');
      return null;
    }
  }

  /// Parse string fileType ke enum UploadedFileType
  UploadedFileType _analisaTipeFile(String? type) {
    switch (type) {
      case 'image':
        return UploadedFileType.image;
      case 'pdf':
        return UploadedFileType.pdf;
      case 'audio':
        return UploadedFileType.audio;
      case 'video':
        return UploadedFileType.video;
      default:
        return UploadedFileType.other;
    }
  }

  void _setLoading(bool value) {
    _sedangMemuat = value;
    notifyListeners();
  }

  void _setError(String message) {
    _pesanError = message;
    notifyListeners();
  }

  void _hapusPesanError() {
    _pesanError = null;
  }

  void _resetStatus() {
    _namaFile = null;
    _tipeFile = null;
    _bytesTampilan = null;
    _tipeFileUnggahan = null;
    _ukuranFile = null;
    _localFilePath = null;
    notifyListeners();
  }

  /// Helper untuk memformat ukuran file
  String _formatUkuran(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (math.log(bytes) / math.log(1024)).floor();
    // Pastikan index tidak melebihi batas array suffixes
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}
