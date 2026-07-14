enum UserRole { student, teacher, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Siswa';
      case UserRole.teacher:
        return 'Guru';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

