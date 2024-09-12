import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON encode için
import 'package:intl/intl.dart'; // Intl paketi eklendi
import 'package:email_validator/email_validator.dart'; // E-posta doğrulama için

class PersonDetailsWidget extends StatefulWidget {
  final String personName;

  const PersonDetailsWidget({Key? key, required this.personName}) : super(key: key);

  @override
  _PersonDetailsWidgetState createState() => _PersonDetailsWidgetState();
}

class _PersonDetailsWidgetState extends State<PersonDetailsWidget> {
  late TextEditingController _nameController;
  late TextEditingController _tcKimlikNoController;
  late TextEditingController _unvanController;
  late TextEditingController _sirketHattiController;
  late TextEditingController _kisiselHatController;
  late TextEditingController _epostaController;
  late TextEditingController _adresController;
  late TextEditingController _dogumTarihiController;

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchPersonDetails();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _tcKimlikNoController = TextEditingController();
    _unvanController = TextEditingController();
    _sirketHattiController = TextEditingController();
    _kisiselHatController = TextEditingController();
    _epostaController = TextEditingController();
    _adresController = TextEditingController();
    _dogumTarihiController = TextEditingController();
  }

  Future<void> _fetchPersonDetails() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/getpersondetails/${widget.personName}'));
      if (response.statusCode == 200) {
        final person = jsonDecode(response.body);
        setState(() {
          _nameController.text = person['name'] ?? '';
          _tcKimlikNoController.text = person['tc_no'] ?? '';
          _unvanController.text = person['unvan'] ?? '';
          _sirketHattiController.text = person['sirkethatti'] ?? '';
          _kisiselHatController.text = person['kisiselhat'] ?? '';
          _epostaController.text = person['eposta'] ?? '';
          _adresController.text = person['adres'] ?? '';
          _dogumTarihiController.text = person['dgtarih'] ?? '';
          _isLoading = false;
        });
      } else {
        print('Kişi bilgilerini getirme hatası: ${response.statusCode}');
      }
    } catch (error) {
      print('Kişi bilgilerini getirme hatası: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.personName),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                _buildListTile('İsim Soyisim', _nameController, TextInputType.text),
                _buildListTile('TC Kimlik No', _tcKimlikNoController, TextInputType.number),
                _buildListTile('Ünvan', _unvanController, TextInputType.text),
                _buildListTile('Şirket Hattı', _sirketHattiController, TextInputType.number),
                _buildListTile('Kişisel Hat', _kisiselHatController, TextInputType.number),
                _buildListTile('E-posta', _epostaController, TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && !EmailValidator.validate(value)) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                      return null;
                    }),
                _buildListTile('Adres', _adresController, TextInputType.text),
                _buildListTile('Doğum Tarihi', _dogumTarihiController, TextInputType.datetime,
                    onTap: () => _selectDate(context)),
                SizedBox(height: 20),
                _isEditing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildButton('İptal', () {
                            setState(() {
                              _isEditing = false;
                            });
                          }),
                          SizedBox(width: 10),
                          _buildButton('Kaydet', () {
                            _updatePersonDetails();
                          }),
                        ],
                      )
                    : _buildButton('Güncelle', () {
                        setState(() {
                          _isEditing = true;
                        });
                      }),
              ],
            ),
    );
  }

  Widget _buildListTile(
    String title,
    TextEditingController controller,
    TextInputType inputType, {
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: TextFormField(
        controller: controller,
        keyboardType: inputType,
        onTap: onTap,
        validator: validator,
        enabled: _isEditing,
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Future<void> _updatePersonDetails() async {
    setState(() {
      _isEditing = false;
    });

    try {
      final response = await http.put(
        Uri.parse('http://2a07-159-146-53-63.ngrok-free.app/updatepersondetails'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'tc_no': _tcKimlikNoController.text,
          'unvan': _unvanController.text,
          'sirketHatti': _sirketHattiController.text,
          'kisiselHat': _kisiselHatController.text,
          'eposta': _epostaController.text,
          'adres': _adresController.text,
          'dgtarih': _dogumTarihiController.text,
        }),
      );
      if (response.statusCode == 200) {
        print('Kişi bilgileri başarıyla güncellendi');
      } else {
        print('Kişi bilgilerini güncelleme hatası: ${response.statusCode}');
      }
    } catch (error) {
      print('Kişi bilgilerini güncelleme hatası: $error');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dogumTarihiController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tcKimlikNoController.dispose();
    _unvanController.dispose();
    _sirketHattiController.dispose();
    _kisiselHatController.dispose();
    _epostaController.dispose();
    _adresController.dispose();
    _dogumTarihiController.dispose();
    super.dispose();
  }
}
