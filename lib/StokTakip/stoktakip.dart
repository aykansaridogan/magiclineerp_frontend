import 'package:flutter/material.dart';


class Stock {
  String name;
  int stock;
  String imageUrl;

  Stock({required this.name, required this.stock, required this.imageUrl});
}
class StockTrack extends StatefulWidget {
  @override
  _StockTrackState createState() => _StockTrackState();
}

class _StockTrackState extends State<StockTrack> {
  final List<Stock> products = [
    Stock(
        name:
            'Electric Vehicle (Ev) Type-2 Ac Charger - Charging Cable - 32 Amp (Up to 7.4kw)',
        stock: 10,
        imageUrl:
            "https://cpimg.tistatic.com/07815221/b/4/Electric-Vehicle-Ev-Type-2-Ac-Charger-Charging-Cable-32-Amp-Up-to-7-4kw-.jpg"),
    Stock(
        name:
            "OEM EV/Electric Car Charging 32A Single Phase Type2 to Type EV Charger Cable 32",
        stock: 5,
        imageUrl:
            "https://m.media-amazon.com/images/I/61bkYRY4m1S._AC_SY200_QL15_.jpg"),
    Stock(
        name:
            'GBT EV Charging Cable',
        stock: 10,
        imageUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSBeqtIaI3IuhtZY-CkfLRgAdgcbgLEhgNscSpqQvkyZtJoyvUOvGgget3Z-aaDF-U0aSw&usqp=CAU"),
    
  ];

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
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductModal();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(Stock product) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            product.imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Stok: ${product.stock}',
                  style: TextStyle(
                    fontSize: 16,
                    color: product.stock > 0 ? Colors.black : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditModal(product);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(product);
            },
          ),
        ],
      ),
    );
  }

  void _showEditModal(Stock product) {
    TextEditingController nameController =
        TextEditingController(text: product.name);
    TextEditingController stockController =
        TextEditingController(text: product.stock.toString());
    TextEditingController urlController =
        TextEditingController(text: product.imageUrl);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ürünü Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                controller: urlController,
                decoration: InputDecoration(labelText: 'Resim URL'),
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
              child: Text('Kaydet'),
              onPressed: () {
                setState(() {
                  product.name = nameController.text;
                  product.stock = int.tryParse(stockController.text) ?? 0;
                  product.imageUrl = urlController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Stock product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ürünü Sil'),
          content: Text('Bu ürünü silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                setState(() {
                  products.remove(product);
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddProductModal() {
    TextEditingController nameController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yeni Stok Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                controller: urlController,
                decoration: InputDecoration(labelText: 'Resim URL'),
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
                setState(() {
                  products.add(
                    Stock(
                      name: nameController.text,
                      stock: int.tryParse(stockController.text) ?? 0,
                      imageUrl: urlController.text,
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
