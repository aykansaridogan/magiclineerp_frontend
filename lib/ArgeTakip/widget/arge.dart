import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArgeTrack extends StatefulWidget {
  @override
  _ArgeTrackState createState() => _ArgeTrackState();
}

class _ArgeTrackState extends State<ArgeTrack> {
  List<Product> products = [
    Product(name: 'Ürün 1'),
    Product(name: 'Ürün 2'),
    Product(name: 'Ürün 3'),
  ];
  List<FaultyProduct> faultyProducts = [];

  void _editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller =
            TextEditingController(text: product.name);
        return AlertDialog(
          title: Text('Ürünü Düzenle'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Ürün Adı'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  product.name = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _reportFaultyProduct(Product product) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata Bildir - ${product.name}'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Hata Açıklaması'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  faultyProducts.add(FaultyProduct(
                    name: product.name,
                    description: controller.text,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: Text('Bildir'),
            ),
          ],
        );
      },
    );
  }

  void _fixFaultyProduct(FaultyProduct faultyProduct) {
    setState(() {
      faultyProducts.remove(faultyProduct);
    });
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'aykso63@gmail.com',
      query: _generateEmailQuery(),
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      _showEmailErrorDialog();
    }
  }

  String _generateEmailQuery() {
    String subject = 'Ürün Durumu Raporu';
    String body = _generateEmailBody();
    return 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
  }

  String _generateEmailBody() {
    String body =
        '<h2>Ürün Durumu Raporu:</h2><table border="1" cellpadding="5" cellspacing="0"><tr><th>Ürün Adı</th><th>Test Edildi</th><th>Yapılandırıldı</th></tr>';

    for (var product in products.where((p) => p.selected)) {
      body +=
          '<tr><td>${product.name}</td><td>${product.isChecked ? "Evet" : "Hayır"}</td><td>${product.isConfigured ? "Evet" : "Hayır"}</td></tr>';
    }

    body += '</table>';

    if (faultyProducts.isNotEmpty) {
      body +=
          '<h3>Hatalı Ürünler:</h3><table border="1" cellpadding="5" cellspacing="0"><tr><th>Ürün Adı</th><th>Hata Açıklaması</th></tr>';
      for (var faultyProduct in faultyProducts) {
        body +=
            '<tr><td>${faultyProduct.name}</td><td>${faultyProduct.description}</td></tr>';
      }
      body += '</table>';
    }

    return body;
  }

  void _showEmailErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text('E-posta gönderilirken bir hata oluştu.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ArgeTrack'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    onCheckedChanged: (isChecked) {
                      setState(() {
                        products[index].isChecked = isChecked;
                      });
                    },
                    onConfiguredChanged: (isConfigured) {
                      setState(() {
                        products[index].isConfigured = isConfigured;
                      });
                    },
                    onSelectedChanged: (isSelected) {
                      setState(() {
                        products[index].selected = isSelected;
                      });
                    },
                    onFaultyReported: () {
                      _reportFaultyProduct(products[index]);
                    },
                    onEdit: () {
                      _editProduct(products[index]);
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _sendEmail,
                  child: Text('Gönder'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Hatalı Üretimler'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: faultyProducts.map((faultyProduct) {
                              return ListTile(
                                title: Text(
                                    '${faultyProduct.name} - ${faultyProduct.description}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () {
                                    _fixFaultyProduct(faultyProduct);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Kapat'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Hatalı Üretim'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  String name;
  bool isChecked;
  bool isConfigured;
  bool selected; // Yeni özellik

  Product({
    required this.name,
    this.isChecked = false,
    this.isConfigured = false,
    this.selected = false, // Varsayılan olarak false
  });
}

class FaultyProduct {
  final String name;
  final String description;

  FaultyProduct({
    required this.name,
    required this.description,
  });
}

class ProductCard extends StatelessWidget {
  final Product product;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<bool> onConfiguredChanged;
  final ValueChanged<bool> onSelectedChanged; // Yeni callback
  final VoidCallback onFaultyReported;
  final VoidCallback onEdit;

  ProductCard({
    required this.product,
    required this.onCheckedChanged,
    required this.onConfiguredChanged,
    required this.onSelectedChanged, // Yeni callback
    required this.onFaultyReported,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: product.selected,
                  onChanged: (value) {
                    onSelectedChanged(value ?? false);
                  },
                ),
                Expanded(
                  child: Text(
                    product.name,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: product.isChecked,
                  onChanged: (value) {
                    onCheckedChanged(value ?? false);
                  },
                ),
                Text('Test Edildi'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: product.isConfigured,
                  onChanged: (value) {
                    onConfiguredChanged(value ?? false);
                  },
                ),
                Text('Yapılandırıldı'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onFaultyReported,
                  child: Text('Hatalı'),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
