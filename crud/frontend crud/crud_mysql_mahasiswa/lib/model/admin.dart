class Admin {
  int id;
  String username;
  String password;

  Admin({this.id, this.password, this.username});

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        id: int.parse(json['id'].toString()),
        username: json['username'],
        password: json['password'],
      );
}
