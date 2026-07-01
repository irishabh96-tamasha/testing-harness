/// The user's editable profile, returned by `GET /api/profile`.
class Profile {
  const Profile({
    this.name = '',
    this.avatarUrl = '',
    this.businessName = '',
    this.businessDetails = '',
    this.businessMobile = '',
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        name: (json['name'] as String?) ?? '',
        avatarUrl: (json['avatarUrl'] as String?) ?? '',
        businessName: (json['businessName'] as String?) ?? '',
        businessDetails: (json['businessDetails'] as String?) ?? '',
        businessMobile: (json['businessMobile'] as String?) ?? '',
      );

  final String name;
  final String avatarUrl;
  final String businessName;
  final String businessDetails;
  final String businessMobile;
}
