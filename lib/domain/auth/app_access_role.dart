enum AppAccessRole { dispatcher, driver }

extension AppAccessRolesX on List<AppAccessRole> {
  bool get canDispatch => contains(AppAccessRole.dispatcher);
  bool get canDrive => contains(AppAccessRole.driver);
  bool get isDriverOnly => canDrive && !canDispatch;
}

/// Temporary role mapping until the login/profile API returns roles.
List<AppAccessRole> mockRolesForUsername(String username) {
  final value = username.trim().toLowerCase();
  if (value == 'driver' || value.startsWith('driver')) {
    return const [AppAccessRole.driver];
  }
  return const [AppAccessRole.dispatcher, AppAccessRole.driver];
}
