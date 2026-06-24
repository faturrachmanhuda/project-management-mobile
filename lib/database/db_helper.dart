import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';
import '../models/activity_model.dart';
import '../models/modelbikinproyek.dart';
import '../models/job.dart';
import '../models/akun_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('promanage.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = join(await getDatabasesPath(), filePath);
    return await openDatabase(
      path,
      version: 10,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 9) {
      // Nama tabel lama yang benar adalah versi Bahasa Indonesia.
      // Jika tidak di-drop, data lama bisa bertahan dan bercampur dengan skema baru.
      await db.execute('DROP TABLE IF EXISTS catatan');
      await db.execute('DROP TABLE IF EXISTS proyek');
      await db.execute('DROP TABLE IF EXISTS pekerjaan');
      await db.execute('DROP TABLE IF EXISTS kegiatan');
      await _createDB(db, newVersion);
    }
    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS akun(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE,
          username TEXT,
          nama TEXT,
          nim TEXT,
          password TEXT,
          profile_picture TEXT,
          is_active INTEGER DEFAULT 0
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS catatan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS proyek(
        id TEXT PRIMARY KEY,
        nama TEXT,
        deskripsi TEXT,
        lokasi TEXT,
        tanggal TEXT,
        pengawas TEXT,
        kemajuan REAL,
        pelaksana TEXT,
        jumlah_anggota INTEGER,
        status TEXT,
        tersinkron INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pekerjaan(
        id TEXT PRIMARY KEY,
        id_proyek TEXT,
        judul TEXT,
        deskripsi TEXT,
        lokasi TEXT,
        status TEXT,
        tanggal_mulai TEXT,
        tenggat_waktu TEXT,
        pelaksana TEXT,
        pengawas TEXT,
        tersinkron INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS kegiatan(
        id TEXT PRIMARY KEY,
        id_proyek TEXT,
        id_pekerjaan TEXT,
        judul_proyek TEXT,
        judul_pekerjaan TEXT,
        judul TEXT,
        deskripsi TEXT,
        tanggal TEXT,
        status TEXT,
        evaluasi TEXT,
        rencana_tindak_lanjut TEXT,
        url_dokumen TEXT,
        path_file_lokal TEXT,
        nama_file TEXT,
        tersinkron INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS akun(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        username TEXT,
        nama TEXT,
        nim TEXT,
        password TEXT,
        profile_picture TEXT,
        is_active INTEGER DEFAULT 0
      )
    ''');
  }

  // === CRUD AKUN ===
  Future<int> insertAkun(Akun akun) async {
    final db = await instance.database;
    return await db.insert('akun', akun.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Akun>> getAllAkun() async {
    final db = await instance.database;
    final result = await db.query('akun');
    return result.map((e) => Akun.fromMap(e)).toList();
  }

  Future<Akun?> getAkunByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query('akun', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) {
      return Akun.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteAkun(int id) async {
    final db = await instance.database;
    return await db.delete('akun', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateAkun(Akun akun) async {
    final db = await instance.database;
    return await db.update('akun', akun.toMap(), where: 'id = ?', whereArgs: [akun.id]);
  }

  Future<void> setAkunActive(String email) async {
    final db = await instance.database;
    await db.update('akun', {'is_active': 0}); // Nonaktifkan semua
    await db.update('akun', {'is_active': 1}, where: 'email = ?', whereArgs: [email]);
  }

  Future<void> deleteAllAkun() async {
    final db = await instance.database;
    await db.delete('akun');
  }

  // === CRUD CATATAN ===
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('catatan', {
      'judul': note.title,
    });
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('catatan');
    return result.map((e) => Note(
      id: e['id'] as int?,
      title: e['judul']?.toString() ?? '',
    )).toList();
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }

  // === CRUD PROYEK ===
  Future<void> saveProjects(List<Proyek> projects) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var project in projects) {
      batch.insert('proyek', {
        'id': project.id,
        'nama': project.nama,
        'deskripsi': project.deskripsi,
        'lokasi': project.lokasi,
        'tanggal': project.tanggal,
        'pengawas': project.pengawas,
        'kemajuan': project.isTertutup ? 100.0 : 0.0,
        'pelaksana': project.tim,
        'jumlah_anggota': 0,
        'status': project.status,
        'tersinkron': project.isTersinkron ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Proyek>> getAllProjects() async {
    final db = await instance.database;
    final result = await db.query('proyek');
    return result.map((e) {
      final tanggalStr = e['tanggal']?.toString() ?? '';
      String mulai = tanggalStr;
      String selesai = '';
      if (tanggalStr.contains(' - ')) {
        final parts = tanggalStr.split(' - ');
        mulai = parts[0];
        selesai = parts.length > 1 ? parts[1] : '';
      }
      return Proyek(
        id: e['id']?.toString() ?? '',
        nama: e['nama']?.toString() ?? '',
        deskripsi: e['deskripsi']?.toString() ?? '',
        lokasi: e['lokasi']?.toString() ?? '',
        tanggalMulai: mulai,
        tanggalSelesai: selesai,
        tim: e['pelaksana']?.toString() ?? '',
        pengawas: e['pengawas']?.toString() ?? '',
        status: e['status']?.toString() ?? 'Aktif',
        isTertutup: (e['kemajuan'] as num? ?? 0) >= 100,
        isTersinkron: e['tersinkron'] == 1,
      );
    }).toList();
  }

  // === CRUD PEKERJAAN ===
  Future<void> saveJobItems(List<ItemPekerjaan> jobs) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var job in jobs) {
      batch.insert('pekerjaan', {
        'id': job.id,
        'id_proyek': job.idProyek,
        'judul': job.nama,
        'deskripsi': job.deskripsi,
        'lokasi': job.lokasi,
        'status': 'Aktif',
        'tanggal_mulai': job.tanggalMulai,
        'tenggat_waktu': job.tanggalSelesai,
        'pelaksana': job.pelaksana,
        'pengawas': job.pengawas,
        'tersinkron': job.isTersinkron ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Pekerjaan>> getJobsByProjectId(String projectId) async {
    final db = await instance.database;
    final result = await db.query('pekerjaan', where: 'id_proyek = ?', whereArgs: [projectId]);
    return result.map((j) => Pekerjaan(
      id: j['id']?.toString() ?? '',
      idProyek: j['id_proyek']?.toString() ?? '',
      nama: j['judul']?.toString() ?? '',
      deskripsi: j['deskripsi']?.toString() ?? '',
      lokasi: j['lokasi']?.toString() ?? '',
      tanggalMulai: j['tanggal_mulai']?.toString() ?? '',
      tanggalSelesai: j['tenggat_waktu']?.toString() ?? '',
      pelaksana: j['pelaksana']?.toString() ?? '',
      pengawas: j['pengawas']?.toString() ?? '',
      isTersinkron: j['tersinkron'] == 1,
    )).toList();
  }

  Future<void> saveJobModels(List<Pekerjaan> jobs) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var job in jobs) {
      batch.insert('pekerjaan', {
        'id': job.id,
        'id_proyek': job.idProyek,
        'judul': job.nama,
        'deskripsi': job.deskripsi,
        'lokasi': job.lokasi,
        'status': 'Aktif',
        'tanggal_mulai': job.tanggalMulai,
        'tenggat_waktu': job.tanggalSelesai,
        'pelaksana': job.pelaksana,
        'pengawas': job.pengawas,
        'tersinkron': job.isTersinkron ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteJobModel(String jobId) async {
    final db = await instance.database;
    await db.delete('pekerjaan', where: 'id = ?', whereArgs: [jobId]);
  }

  // === CRUD KEGIATAN ===
  Future<void> saveActivities(List<Kegiatan> activities) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var activity in activities) {
      batch.insert('kegiatan', {
        'id': activity.id,
        'id_proyek': activity.projectId,
        'id_pekerjaan': activity.jobId,
        'judul_proyek': activity.projectTitle,
        'judul_pekerjaan': activity.jobTitle,
        'judul': activity.title,
        'deskripsi': activity.desc,
        'tanggal': activity.date,
        'status': activity.status,
        'evaluasi': activity.evaluation,
        'rencana_tindak_lanjut': activity.followUpPlan,
        'url_dokumen': activity.documentUrl,
        'path_file_lokal': activity.localFilePath,
        'nama_file': activity.fileName,
        'tersinkron': activity.isSynced ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Kegiatan>> getAllActivities() async {
    final db = await instance.database;
    final result = await db.query('kegiatan');
    return result.map((e) => Kegiatan(
      id: e['id']?.toString() ?? '',
      projectId: e['id_proyek']?.toString() ?? '',
      jobId: e['id_pekerjaan']?.toString() ?? '',
      projectTitle: e['judul_proyek']?.toString() ?? '',
      jobTitle: e['judul_pekerjaan']?.toString() ?? '',
      title: e['judul']?.toString() ?? '',
      desc: e['deskripsi']?.toString() ?? '',
      date: e['tanggal']?.toString() ?? '',
      status: e['status']?.toString() ?? '',
      evaluation: e['evaluasi']?.toString() ?? '',
      followUpPlan: e['rencana_tindak_lanjut']?.toString() ?? '',
      documentUrl: e['url_dokumen']?.toString() ?? '',
      localFilePath: e['path_file_lokal']?.toString() ?? '',
      fileName: e['nama_file']?.toString() ?? '',
      isSynced: e['tersinkron'] == 1,
    )).toList();
  }

  Future<List<Kegiatan>> getActivitiesByJobTitle(String jobTitle, {String? projectId}) async {
    final db = await instance.database;
    if (projectId != null && projectId.isNotEmpty) {
      final result = await db.query(
        'kegiatan', 
        where: 'judul_pekerjaan = ? AND id_proyek = ?', 
        whereArgs: [jobTitle, projectId]
      );
      return result.map((e) => Kegiatan(
        id: e['id']?.toString() ?? '',
        projectId: e['id_proyek']?.toString() ?? '',
        jobId: e['id_pekerjaan']?.toString() ?? '',
        projectTitle: e['judul_proyek']?.toString() ?? '',
        jobTitle: e['judul_pekerjaan']?.toString() ?? '',
        title: e['judul']?.toString() ?? '',
        desc: e['deskripsi']?.toString() ?? '',
        date: e['tanggal']?.toString() ?? '',
        status: e['status']?.toString() ?? '',
        evaluation: e['evaluasi']?.toString() ?? '',
        followUpPlan: e['rencana_tindak_lanjut']?.toString() ?? '',
        documentUrl: e['url_dokumen']?.toString() ?? '',
        localFilePath: e['path_file_lokal']?.toString() ?? '',
        fileName: e['nama_file']?.toString() ?? '',
        isSynced: e['tersinkron'] == 1,
      )).toList();
    } else {
      final result = await db.query('kegiatan', where: 'judul_pekerjaan = ?', whereArgs: [jobTitle]);
      return result.map((e) => Kegiatan(
        id: e['id']?.toString() ?? '',
        projectId: e['id_proyek']?.toString() ?? '',
        jobId: e['id_pekerjaan']?.toString() ?? '',
        projectTitle: e['judul_proyek']?.toString() ?? '',
        jobTitle: e['judul_pekerjaan']?.toString() ?? '',
        title: e['judul']?.toString() ?? '',
        desc: e['deskripsi']?.toString() ?? '',
        date: e['tanggal']?.toString() ?? '',
        status: e['status']?.toString() ?? '',
        evaluation: e['evaluasi']?.toString() ?? '',
        followUpPlan: e['rencana_tindak_lanjut']?.toString() ?? '',
        documentUrl: e['url_dokumen']?.toString() ?? '',
        localFilePath: e['path_file_lokal']?.toString() ?? '',
        fileName: e['nama_file']?.toString() ?? '',
        isSynced: e['tersinkron'] == 1,
      )).toList();
    }
  }

  Future<List<Kegiatan>> getActivitiesByProjectId(String projectId) async {
    final db = await instance.database;
    final result = await db.query('kegiatan', where: 'id_proyek = ?', whereArgs: [projectId]);
    return result.map((e) => Kegiatan(
      id: e['id']?.toString() ?? '',
      projectId: e['id_proyek']?.toString() ?? '',
      jobId: e['id_pekerjaan']?.toString() ?? '',
      projectTitle: e['judul_proyek']?.toString() ?? '',
      jobTitle: e['judul_pekerjaan']?.toString() ?? '',
      title: e['judul']?.toString() ?? '',
      desc: e['deskripsi']?.toString() ?? '',
      date: e['tanggal']?.toString() ?? '',
      status: e['status']?.toString() ?? '',
      evaluation: e['evaluasi']?.toString() ?? '',
      followUpPlan: e['rencana_tindak_lanjut']?.toString() ?? '',
      documentUrl: e['url_dokumen']?.toString() ?? '',
      localFilePath: e['path_file_lokal']?.toString() ?? '',
      fileName: e['nama_file']?.toString() ?? '',
      isSynced: e['tersinkron'] == 1,
    )).toList();
  }

  Future<void> deleteActivityModel(String activityId) async {
    final db = await instance.database;
    await db.delete('kegiatan', where: 'id = ?', whereArgs: [activityId]);
  }

  // === FULL PROJECT CRUD (Proyek + ItemPekerjaan + ItemKegiatan) ===
  Future<void> saveFullProject(Proyek project) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Bersihkan data lama untuk proyek yang sama agar child record yang
      // sudah dihapus pada server tidak ikut tersisa di lokal.
      await txn.delete('proyek', where: 'id = ?', whereArgs: [project.id]);
      await txn.delete('pekerjaan', where: 'id_proyek = ?', whereArgs: [project.id]);
      await txn.delete('kegiatan', where: 'id_proyek = ?', whereArgs: [project.id]);

      await txn.insert(
        'proyek',
        {
          'id': project.id,
          'nama': project.nama,
          'deskripsi': project.deskripsi,
          'lokasi': project.lokasi,
          'tanggal': project.tanggal,
          'pengawas': project.pengawas,
          'kemajuan': project.isTertutup ? 100.0 : 0.0,
          'pelaksana': project.tim,
          'jumlah_anggota': 0,
          'status': project.status,
          'tersinkron': project.isTersinkron ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (var job in project.daftarPekerjaan) {
        await txn.insert(
          'pekerjaan',
          {
            'id': job.id,
            'id_proyek': project.id,
            'judul': job.nama,
            'deskripsi': job.deskripsi,
            'lokasi': job.lokasi,
            'status': 'Aktif',
            'tanggal_mulai': job.tanggalMulai,
            'tenggat_waktu': job.tanggalSelesai,
            'pelaksana': job.pelaksana,
            'pengawas': job.pengawas,
            'tersinkron': job.isTersinkron ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (var activity in project.daftarKegiatan) {
        await txn.insert(
          'kegiatan',
          {
            'id': activity.id,
            'id_proyek': project.id,
            'id_pekerjaan': activity.idPekerjaan,
            'judul_proyek': project.nama,
            'judul_pekerjaan': activity.pekerjaan,
            'judul': activity.namaKegiatan,
            'deskripsi': activity.pelaksana,
            'tanggal': activity.waktuPelaksanaan,
            'status': activity.selesai ? 'done' : 'pending',
            'evaluasi': activity.evaluasi,
            'rencana_tindak_lanjut': activity.rencanaTambahan,
            'url_dokumen': activity.urlDokumen,
            'path_file_lokal': activity.pathFileLokal,
            'nama_file': activity.namaFile,
            'tersinkron': activity.isTersinkron ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Proyek>> getFullProjects() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> projectMaps = await db.query('proyek');
    List<Proyek> projects = [];
    
    for (var pMap in projectMaps) {
      final projectId = pMap['id'].toString();
      
      final List<Map<String, dynamic>> jobMaps = await db.query(
        'pekerjaan',
        where: 'id_proyek = ?',
        whereArgs: [projectId],
      );
      
      final List<Map<String, dynamic>> activityMaps = await db.query(
        'kegiatan',
        where: 'id_proyek = ?',
        whereArgs: [projectId],
      );
      
      final List<ItemPekerjaan> jobs = jobMaps.map((j) => ItemPekerjaan(
        id: j['id']?.toString() ?? '',
        idProyek: j['id_proyek']?.toString() ?? '',
        judulProyek: pMap['nama']?.toString() ?? '',
        nama: j['judul']?.toString() ?? '',
        deskripsi: j['deskripsi']?.toString() ?? '',
        lokasi: j['lokasi']?.toString() ?? '',
        tanggalMulai: j['tanggal_mulai']?.toString() ?? '',
        tanggalSelesai: j['tenggat_waktu']?.toString() ?? '',
        pelaksana: j['pelaksana']?.toString() ?? '',
        pengawas: j['pengawas']?.toString() ?? '',
        isTersinkron: j['tersinkron'] == 1,
      )).toList();
      
      final List<ItemKegiatan> activities = activityMaps.map((a) => ItemKegiatan(
        id: a['id']?.toString() ?? '',
        idProyek: a['id_proyek']?.toString() ?? '',
        idPekerjaan: a['id_pekerjaan']?.toString() ?? '',
        judulProyek: a['judul_proyek']?.toString() ?? '',
        pekerjaan: a['judul_pekerjaan']?.toString() ?? '',
        namaKegiatan: a['judul']?.toString() ?? '',
        pelaksana: a['deskripsi']?.toString() ?? '',
        waktuPelaksanaan: a['tanggal']?.toString() ?? '',
        selesai: a['status'] == 'selesai' || a['status'] == 'done',
        evaluasi: a['evaluasi']?.toString() ?? '',
        rencanaTambahan: a['rencana_tindak_lanjut']?.toString() ?? '',
        urlDokumen: a['url_dokumen']?.toString() ?? '',
        pathFileLokal: a['path_file_lokal']?.toString() ?? '',
        namaFile: a['nama_file']?.toString() ?? '',
        isTersinkron: a['tersinkron'] == 1,
      )).toList();
      
      final tanggalStr = pMap['tanggal']?.toString() ?? '';
      String pMulai = tanggalStr;
      String pSelesai = '';
      if (tanggalStr.contains(' - ')) {
        final parts = tanggalStr.split(' - ');
        pMulai = parts[0];
        pSelesai = parts.length > 1 ? parts[1] : '';
      }
      projects.add(Proyek(
        id: projectId,
        nama: pMap['nama'] ?? '',
        deskripsi: pMap['deskripsi'] ?? '',
        lokasi: pMap['lokasi'] ?? '', 
        tanggalMulai: pMulai,
        tanggalSelesai: pSelesai,
        tim: pMap['pelaksana'] ?? '',
        pengawas: pMap['pengawas'] ?? '',
        status: pMap['status'] ?? 'Aktif',
        isTertutup: (pMap['kemajuan'] ?? 0) >= 100,
        isTersinkron: pMap['tersinkron'] == 1,
        daftarPekerjaan: jobs,
        daftarKegiatan: activities,
      ));
    }
    
    return projects;
  }

  Future<void> deleteFullProject(String projectId) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('proyek', where: 'id = ?', whereArgs: [projectId]);
      await txn.delete('pekerjaan', where: 'id_proyek = ?', whereArgs: [projectId]);
      await txn.delete('kegiatan', where: 'id_proyek = ?', whereArgs: [projectId]);
    });
  }

  Future<List<Pekerjaan>> getJobsByProjectTitle(String title) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> projects = await db.query(
      'proyek',
      where: 'nama = ?',
      whereArgs: [title],
    );
    if (projects.isEmpty) return [];
    return getJobsByProjectId(projects.first['id'].toString());
  }

  Future<void> deleteProjectById(String id) async {
    final db = await instance.database;
    await db.delete('proyek', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('proyek');
    await db.delete('pekerjaan');
    await db.delete('kegiatan');
    await db.delete('catatan');
    await db.delete('akun');
  }

}
