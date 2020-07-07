import 'package:bobocomp/modals/company_models/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompanyModule with ChangeNotifier {
  List<CompanyModel> _companies = [];

  set setCompanies(List<CompanyModel> _items) {
    _companies = _items;
    notifyListeners();
  }

  set addCompany(CompanyModel _item) {
    _companies.add(_item);
    notifyListeners();
  }

  List<CompanyModel> get companies => _companies;

  void get fetchCompanies async {
    List<CompanyModel> _items = await fetchAllCompany();
    setCompanies = _items;
  }

  void fetchUserCompanies(String userId) async {
    List<CompanyModel> _items = await _fetchUserCompanies(userId);
    setCompanies = _items;
  }

  // Firebase
  final databaseReference = Firestore.instance;
  CompanyModel _companyModel = CompanyModel();

  // create
  void createCompany(CompanyModel companyModel) async {
    // final DocumentReference ref =
    await databaseReference.collection("companies").add(companyModel.asMap());
  }

  // update
  void updateCompany(CompanyModel companyModel) async {
    // TODO:
  }

  // fetchone
  Future<CompanyModel> fetchOneCompany(String id) async {
    DocumentSnapshot _item =
        await databaseReference.document('companies/$id').get();

    return _companyModel.fromMap(_item.data);
  }

  // fetchall
  Future<List<CompanyModel>> fetchAllCompany() async {
    QuerySnapshot _qSnapshot =
        await databaseReference.collection('companies').getDocuments();
    return _qSnapshot.documents.map((documents) {
      Map<String, dynamic> _map;
      _map = documents.data;
      _map['id'] = _qSnapshot.documents[0].documentID;
      return _companyModel.fromMap(_map);
    }).toList();
  }

  // fetch for user
  Future<List<CompanyModel>> _fetchUserCompanies(userId) async {
    QuerySnapshot _qSnapshot = await databaseReference
        .collection('companies')
        .where('users', arrayContains: userId)
        .getDocuments();
    return _qSnapshot.documents.map((documents) {
      Map<String, dynamic> _map;
      _map = documents.data;
      _map['id'] = _qSnapshot.documents[0].documentID;
      return _companyModel.fromMap(_map);
    }).toList();
  }
}
