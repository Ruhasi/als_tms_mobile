class MobileUserProfile {
  const MobileUserProfile({
    required this.id,
    required this.username,
    required this.mobile,
    required this.email,
    required this.profileImageUrl,
    required this.department,
    required this.companies,
  });

  final int id;
  final String username;
  final String mobile;
  final String email;
  final String profileImageUrl;
  final String department;
  final List<MobileCompany> companies;

  factory MobileUserProfile.fromJson(Map<String, dynamic> json) =>
      MobileUserProfile(
        id: json['id'] as int,
        username: json['username'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        email: json['email'] as String? ?? '',
        profileImageUrl: json['profileImageUrl'] as String? ?? '',
        department: json['department'] as String? ?? '',
        companies: (json['companies'] as List? ?? const [])
            .map((item) => MobileCompany.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class MobileCompany {
  const MobileCompany({required this.id, required this.name});
  final int id;
  final String name;

  factory MobileCompany.fromJson(Map<String, dynamic> json) =>
      MobileCompany(id: json['id'] as int, name: json['name'] as String? ?? '');
}
