class UserModel{
  String id;
  String username;
  final String email;
  String dp;

  // TODO:
  // conact
  // icon/profile

  UserModel({
    this.id,
    this.username,
    this.email,
    this.dp
  });

  Map<String, dynamic> asMap(){
    return {
      "id": id,
      "username": username,
      "email": email,
      "dp": dp
    };
  }

  UserModel fromMap(Map<String, dynamic> obj){
    return UserModel(
      id: obj['id'],
      username: obj['username'],
      email: obj['email'],
      dp: obj['dp'],
    );
  }
}