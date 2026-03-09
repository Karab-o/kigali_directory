class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> d) => UserModel(
    uid: d['uid'] ?? '',
    email: d['email'] ?? '',
    displayName: d['displayName'] ?? '',
    createdAt: DateTime.tryParse(d['createdAt'] ?? '') ?? DateTime.now(),
  );
}
