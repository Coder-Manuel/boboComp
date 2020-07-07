import 'dart:io';
import 'dart:math';

import 'package:bobocomp/modals/club_modal.dart';
import 'package:bobocomp/modals/product_modal.dart';
import 'package:bobocomp/modals/table_modal.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModule extends ChangeNotifier {
  // Firebase
  final databaseReference = Firestore.instance;

  List<ClubModal> _clubs = [];
  ClubModal _activeClub = ClubModal(name: '');

  Set<Marker> _markers() {
    // _fetchClubs();
    final Set<Marker> lst = {};

    _clubs.forEach((item) {
      lst.add(item.marker);
    });
    return lst;
  }

  void _fetchClubs() {
    try {
      databaseReference.collection('clubs').getDocuments().then((snapshot) {
        setClubs = _convertToClubModal(snapshot.documents);
      });
    } catch (e) {}
  }

  void _fetchClub(String id) {
    databaseReference.document('clubs/$id').get().then((item) {
      setActiveClub = _convertItemToClubModal(item);
    });
  }

  ClubModal _getClub(id) {
    _fetchClub(id);
    return _activeClub;
  }

  get clubs => _getClubs();

  List<ClubModal> _getClubs() {
    _fetchClubs();
    return _clubs;
  }

  get clubsCount => _clubs.length;
  Set<Marker> get markers => _markers();
  get getClub => (id) {
        return _getClub(id);
      };
  get updateTables => ({List<TableModal> tables, String clubId}) {
        return _updateTables(tables: tables, clubId: clubId);
      };
  get updateProducts => ({List<ProductModal> products, String clubId}) {
        return _updateProducts(products: products, clubId: clubId);
      };
  get updateGallery => ({List<String> gallery, String clubId}) {
        return _updateGallery(gallery: gallery, clubId: clubId);
      };

  get convertToClubModal => (List<DocumentSnapshot> data) {
        // _fetchClubs();
        return _convertToClubModal(data);
      };

  // set _setRestaurant(List<ClubModal> lst) {
  //   _restaurant = lst;
  //   notifyListeners();
  // }
  set setClubs(List<ClubModal> items) {
    _clubs = items;
    notifyListeners();
  }

  set setActiveClub(ClubModal item) {
    _activeClub = item;
    notifyListeners();
  }

  set addClub(ClubModal club) {
    _clubs.add(club);
    createClub(club);
    notifyListeners();
  }

  set deleteClub(String id) {
    _deleteClub(id);
    notifyListeners();
  }

  // id is preffered since each restaurant will have a unique id/key
  // set deleteClub(String id)
  void _deleteClub(String id) async {
    DocumentReference r = await databaseReference.document('clubs/$id');
    r.delete();
  }

  void createClub(ClubModal club) async {
    DocumentReference ref =
        await databaseReference.collection("clubs").add(club.map);
  }

  void _updateTables({List<TableModal> tables, String clubId}) {
    List<Map<String, dynamic>> _tableMaps = [];
    tables.forEach((item) {
      _tableMaps.add(item.map);
    });

    databaseReference
        .document('clubs/$clubId')
        .updateData({'tables': _tableMaps});
  }

  void _updateProducts({List<ProductModal> products, String clubId}) {
    List<Map<String, dynamic>> _productMaps = [];
    products.forEach((item) {
      _productMaps.add(item.map);
    });

    databaseReference
        .document('clubs/$clubId')
        .updateData({'products': _productMaps});
  }

  void _updateGallery({List<String> gallery, String clubId}) {
    databaseReference
        .document('clubs/$clubId')
        .updateData({'gallery': gallery});
  }

  Future<String> uploadImage(File image) async {
    String _filePath = image.path;
    String _extension = _filePath.split('/').last.split('.').last;
    String _label = _filePath.split('/').last.split('.')[0];
    String _fileName =
        Random().nextInt(10000).toString() + _label + '.$_extension';
    final StorageReference _storageRef =
        FirebaseStorage.instance.ref().child(_fileName);

    final StorageUploadTask uploadTask = _storageRef.putFile(
      image,
    );
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String _url = (await downloadUrl.ref.getDownloadURL());
    return _url;
  }

  List<ClubModal> _convertToClubModal(List<DocumentSnapshot> data) {
    List<ClubModal> _clubModals = [];
    data.forEach((item) {
      _clubModals.add(_convertItemToClubModal(item));
    });

    return _clubModals;
  }

  ClubModal _convertItemToClubModal(item) {
    List<TableModal> _t = [];
    List<ProductModal> _p = [];
    List<String> _g = [];

    if (item.data['tables'] != null) {
      item.data['tables'].forEach((it) {
        _t.add(TableModal(
            label: it['label'],
            maxNoChairs: it['maxNoChairs'],
            minNoChairs: it['minNoChairs'],
            reserveCostPerChair: it['reserveCostPerChair']));
      });
    }

    if (item.data['products'] != null) {
      item.data['products'].forEach((p) {
        _p.add(ProductModal(
            id: p['id'],
            name: p['name'],
            price: p['price'],
            image: p['image']));
      });
    }

    if (item.data['gallery'] != null) {
      item.data['gallery'].forEach((g) {
        _g.add(g);
      });
    }

    return ClubModal(
      id: item.documentID,
      name: item.data['name'],
      image: item.data['image'],
      gallery: _g,
      position: LatLng(
          item.data['position'].latitude, item.data['position'].longitude),
      locationLabel: item.data['locationLabel'],
      tables: _t,
      products: _p,
    );
  }

  Stream<QuerySnapshot> _searchedClubs;

  set setSearchedClubs(Stream<QuerySnapshot> obj) {
    _searchedClubs = obj;
    notifyListeners();
  }

  Stream<QuerySnapshot> get searchedClubs => _searchedClubs;

  void searchClubs(String keyword) {
    try {
      Stream<QuerySnapshot> _querySnapshot = databaseReference
          .collection('clubs')
          .where('name', isGreaterThanOrEqualTo: keyword)
          .snapshots();
      setSearchedClubs = _querySnapshot;
    } catch (e) {
      setSearchedClubs = null;
    }
  }
}
