class Akun {
  final int? id;
  final String email;
  final String? username;
  final String? nama;
  final String? nim;
  final String? password;
  final String? profilePicture;
  final int isActive;

  Akun({
    this.id,
    required this.email,
    this.username,
    this.nama,
    this.nim,
    this.password,
    this.profilePicture,
    this.isActive = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'nama': nama,
      'nim': nim,
      'password': password,
      'profile_picture': profilePicture,
      'is_active': isActive,
    };
  }

  factory Akun.fromMap(Map<String, dynamic> map) {
    return Akun(
      id: map['id'] as int?,
      email: map['email'] ?? '',
      username: map['username'],
      nama: map['nama'],
      nim: map['nim'],
      password: map['password'],
      profilePicture: map['profile_picture'],
      isActive: map['is_active'] ?? 0,
    );
  }
}
