import 'package:flutter/material.dart';

class ProductModal{
  final String id;
  final String name;
  final double price;
  final String image;

  ProductModal({
    this.id = '1',
    @required this.name,
    @required this.price,
    this.image,
  });

  get map => _map();

  Map<String, dynamic> _map(){
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image
    };
  }
}