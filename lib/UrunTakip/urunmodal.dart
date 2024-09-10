import 'package:flutter/material.dart';

class Product {
  String malzemekod;
  String name;
  int stock;
  String birim;
  String imageUrl;

  Product({
    required this.malzemekod,
    required this.name,
    required this.stock,
    required this.birim,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Convert binary buffer to Base64 if needed
    String base64Image = '';
    if (json['Resim'] != null && json['Resim'] is String) {
      base64Image = json['Resim'];
    }

    return Product(
      malzemekod: json['MalzemeKodu'] ?? '',
      name: json['UrunAdi'] ?? '',
      stock: json['StokMiktari'] ?? 0,
      birim: json['Birim'] ?? '',
      imageUrl: base64Image.isNotEmpty ? base64Image : '', // Use Base64 encoded image
    );
  }
}