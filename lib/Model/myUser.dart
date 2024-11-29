class MyUser{
  MyUser({required this.uId,required this.name, required this.email,required this.phoneNumber});

  MyUser.fromJson(Map<String, Object?> json)
      : this(
    uId:json['uId'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String,
  );

  final String? uId;
  final String? name;
  final String? email;
  final String? phoneNumber;

  Map<String, Object?> toJson() {
    return {
      "uId":uId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}