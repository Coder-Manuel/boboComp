import 'package:bobocomp/authentication.dart';
import 'package:bobocomp/modals/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserModule extends ChangeNotifier {
  BaseAuth auth = Auth();
  UserModel _userModel = new UserModel();
  // Firebase
  final databaseReference = Firestore.instance;
  UserModel user;

  UserModel get getUser => user;

  set setUser(UserModel _user) {
    user = _user;
    notifyListeners();
  }

  Future<UserModel> currentUser() async {
    FirebaseUser _user;
    try {
      _user = await auth.getCurrentUser();
    } catch (e) {
      _user = null;
    }
    if (_user != null) {
      QuerySnapshot _usersSnapshot = await databaseReference
          .collection("users")
          .where('id', isEqualTo: _user.uid)
          .getDocuments();
      Map<String, dynamic> _userDoc = _usersSnapshot.documents.first.data;
      setUser = _userModel.fromMap(_userDoc);
      return _userModel.fromMap(_userDoc);
    } else {
      return null;
    }
  }

  Future<String> createUser(
      {String userId, String email, String password}) async {
    UserModel _userModel = UserModel(id: userId, email: email);
    await databaseReference
        .collection("users")
        .document(userId)
        .setData(_userModel.asMap());
    return userId;
  }

  void updateUser(UserModel _obj) async {
    await databaseReference
        .collection("users")
        .document(_obj.id)
        .updateData(_obj.asMap());
    await currentUser();
  }
}
