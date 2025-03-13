class MyUser{
  MyUser({required this.uId,required this.name, required this.email,required this.phoneNumber,required this.fcmToken});

  MyUser.fromJson(Map<String, Object?> json)
      : this(
    uId:json['uId'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String,
    fcmToken: json['fcmToken'] as String,
  );

   String? uId;
   String? name;
   String? email;
   String? phoneNumber;
   String? fcmToken;

  Map<String, Object?> toJson() {
    return {
      "uId":uId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'fcmToken' : fcmToken
    };
  }
}