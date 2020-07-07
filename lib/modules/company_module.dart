import 'package:bobocomp/modals/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModule {
  // Firebase
  final databaseReference = Firestore.instance;

  void createClub(CompanyModel companyModel) async {
    // final DocumentReference ref =
    await databaseReference.collection("Companies").add(companyModel.asMap());
  }
}
