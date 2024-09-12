import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

class Station {
  final int sirano;
  String sozlesmeno;
  String sayacno;
  String urunsirano;
  String uruntip;
  String yer;
  String soketno;
  String IMEIno;
  String gsmno;

  Station({
    required this.sirano,
    required this.sozlesmeno,
    required this.sayacno,
    required this.urunsirano,
    required this.uruntip,
    required this.yer,
    required this.soketno,
    required this.IMEIno,
    required this.gsmno,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    final cleanedJson = json.map((key, value) {
      final cleanKey = key.replaceAll(RegExp(r'^="|"$'), '').trim();
      final cleanValue = value.replaceAll(RegExp(r'^="|"$'), '').trim();
      return MapEntry(cleanKey, cleanValue);
    });

    return Station(
      sirano: int.tryParse(cleanedJson['SIRA NO'] ?? '0') ?? 0,
      sozlesmeno: cleanedJson['SÖZLEŞME NO'] ?? '',
      sayacno: cleanedJson['Sayaç No'] ?? '',
      urunsirano: cleanedJson['ÜRÜN SIRA NO'] ?? '',
      uruntip: cleanedJson['ÜRÜN TİP'] ?? '',
      yer: cleanedJson['BULUNDUĞU YER'] ?? '',
      soketno: cleanedJson['SOKET NO'] ?? '',
      IMEIno: cleanedJson['IMEI NO'] ?? '',
      gsmno: cleanedJson['GSM NO'] ?? '',
    );
  }
}

class StationWidget extends StatefulWidget {
  @override
  _StationWidgetState createState() => _StationWidgetState();
}

class _StationWidgetState extends State<StationWidget> {
  List<Station> products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jsonString = await rootBundle.loadString('assets/istasyonlar.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      products = jsonResponse.map((data) => Station.fromJson(data)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İstasyon Takip'),
      ),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.sozlesmeno),
                  subtitle: Text(product.sayacno),
                );
              },
            ),
    );
  }
}