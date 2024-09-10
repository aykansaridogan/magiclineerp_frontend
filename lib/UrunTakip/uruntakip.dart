import 'package:deneme/UrunTakip/urunmodal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List

class ProductTracker extends StatefulWidget {
  @override
  _ProductTrackerState createState() => _ProductTrackerState();
}

class _ProductTrackerState extends State<ProductTracker> {
  List<Product> products = [];
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/products')); // Update IP address as needed
      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        // Decode JSON response
        final List<dynamic> data = json.decode(response.body);

        // Check if data is a List
        if (data is List) {
          setState(() {
            products = data.map((json) => Product.fromJson(json)).toList();
          });
        } else {
          throw Exception('Expected a list of products');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  void _addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/addProduct'), // Update IP address as needed
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'MalzemeKodu': product.malzemekod,
          'UrunAdi': product.name,
          'StokMiktari': product.stock,
          'Birim': product.birim,
          'Resim': product.imageUrl, // Ensure this is a Base64 encoded string if sending
        }),
      );

      if (response.statusCode == 200) {
        _fetchProducts();
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding product: $error');
    }
  }

  void _deleteProduct(String malzemekod) async {
  try {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/deleteProduct/$malzemekod'),
    );

    print('Delete response status: ${response.statusCode}');
    print('Delete response body: ${response.body}');

    if (response.statusCode == 200) {
      _fetchProducts();
    } else {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  } catch (error) {
    print('Error deleting product: $error');
  }
}

void _editProduct(Product product) async {
  try {
    final response = await http.put(
      Uri.parse('http://localhost:3000/updateProduct/${product.malzemekod}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'UrunAdi': product.name,
        'StokMiktari': product.stock,
        'Birim': product.birim,
        'Resim': product.imageUrl,
      }),
    );

    print('Edit response status: ${response.statusCode}');
    print('Edit response body: ${response.body}');

    if (response.statusCode == 200) {
      _fetchProducts();
    } else {
      throw Exception('Failed to edit product: ${response.statusCode}');
    }
  } catch (error) {
    print('Error editing product: $error');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Takip'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: Text('Malzeme Kodu'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  products.sort((a, b) => ascending
                      ? a.malzemekod.compareTo(b.malzemekod)
                      : b.malzemekod.compareTo(a.malzemekod));
                });
              },
            ),
            DataColumn(
              label: Text('Ürün Adı'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  products.sort((a, b) => ascending
                      ? a.name.compareTo(b.name)
                      : b.name.compareTo(a.name));
                });
              },
            ),
            DataColumn(
              label: Text('Stok Miktarı'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  products.sort((a, b) => ascending
                      ? a.stock.compareTo(b.stock)
                      : b.stock.compareTo(a.stock));
                });
              },
            ),
            DataColumn(
              label: Text('Birim'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  products.sort((a, b) => ascending
                      ? a.birim.compareTo(b.birim)
                      : b.birim.compareTo(a.birim));
                });
              },
            ),
            DataColumn(label: Text('Resim')),
            DataColumn(label: Text('İşlemler')), // New column for actions
          ],
          rows: products.map((product) {
            return DataRow(cells: [
              DataCell(Text(product.malzemekod)),
              DataCell(Text(product.name)),
              DataCell(Text(product.stock.toString())),
              DataCell(Text(product.birim)),
              DataCell(
                SizedBox(
                  width: 100,
                  height: 100,
                  child: product.imageUrl.isNotEmpty
                      ? Image.memory(
                          base64Decode(product.imageUrl), // Decode Base64
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        )
                      : Icon(Icons.image_not_supported),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () {
                        _showEditProductModal(context, product);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, product.malzemekod);
                      },
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductModal(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddProductModal(BuildContext context) {
    TextEditingController malzemekoduController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    TextEditingController birimController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yeni Ürün Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: malzemekoduController,
                decoration: InputDecoration(labelText: 'Malzeme Kodu'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Ürün Adı'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stok Miktarı'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: birimController,
                decoration: InputDecoration(labelText: 'Birim'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: 'Resim URL (Base64)'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ekle'),
              onPressed: () {
                Product newProduct = Product(
                  malzemekod: malzemekoduController.text,
                  name: nameController.text,
                  stock: int.tryParse(stockController.text) ?? 0,
                  birim: birimController.text,
                  imageUrl: urlController.text, // Ensure this is Base64 encoded string
                );
                _addProduct(newProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditProductModal(BuildContext context, Product product) {
    TextEditingController malzemekoduController = TextEditingController(text: product.malzemekod);
    TextEditingController nameController = TextEditingController(text: product.name);
    TextEditingController stockController = TextEditingController(text: product.stock.toString());
    TextEditingController birimController = TextEditingController(text: product.birim);
    TextEditingController urlController = TextEditingController(text: product.imageUrl);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ürünü Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: malzemekoduController,
                decoration: InputDecoration(labelText: 'Malzeme Kodu'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Ürün Adı'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stok Miktarı'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: birimController,
                decoration: InputDecoration(labelText: 'Birim'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: 'Resim URL (Base64)'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Güncelle'),
              onPressed: () {
                Product updatedProduct = Product(
                  malzemekod: malzemekoduController.text,
                  name: nameController.text,
                  stock: int.tryParse(stockController.text) ?? 0,
                  birim: birimController.text,
                  imageUrl: urlController.text, // Ensure this is Base64 encoded string
                );
                _editProduct(updatedProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String malzemekod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Silme Onayı'),
          content: Text('Bu ürünü silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                _deleteProduct(malzemekod);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
