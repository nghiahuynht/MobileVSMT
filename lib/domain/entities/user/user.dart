class UserModel {
  final String uid;
  final String? email;
  final String? name;
  final String? photoUrl;

  UserModel({
    required this.uid,
    this.email,
    this.name,
    this.photoUrl,
  });
}
