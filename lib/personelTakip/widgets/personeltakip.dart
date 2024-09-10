import 'package:deneme/personelTakip/utils/cvekrani.dart';
import 'package:deneme/personelTakip/utils/giriscikis.dart';
import 'package:deneme/personelTakip/utils/yaklasandogumgunu.dart';
import 'package:deneme/personelTakip/widgets/izin.dart';
import 'package:deneme/personelTakip/widgets/personelbilgi.dart';
import 'package:deneme/personelTakip/widgets/projects.dart';
import 'package:flutter/material.dart';


class PersonelTracker extends StatefulWidget {
  final String username; // Accept the username

  PersonelTracker({required this.username});

  @override
  _PersonelTrackerState createState() => _PersonelTrackerState();
}

class _PersonelTrackerState extends State<PersonelTracker> {
  String _selectedOption = 'Personel Bilgileri';
  

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personel Takip'),
      ),
      body: Row(
        children: [
          _buildSideMenu(),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              child: _buildSelectedOption(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return Container(
      width: 200,
      color: Colors.blueGrey,
      child: ListView(
        children: [
          _buildMenuItem('Personel Bilgileri'),
          _buildMenuItem('İzinler'),
          _buildMenuItem('Giriş Çıkışlar'),
          _buildMenuItem('Proje'),
          _buildMenuItem('CV Havuzu'),
          _buildMenuItem('Yaklaşan Doğum Günleri')
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        _selectOption(title);
      },
    );
  }

  Widget _buildSelectedOption() {
    switch (_selectedOption) {
      case 'Personel Bilgileri':
        return PersonelInfoWidget(username: widget.username,);
      case 'İzinler':
         return Izinler();
      case 'Giriş Çıkışlar':
        return GirisCikis(username: widget.username,);
      case 'Proje':
        return Projects(loggedInUserName: widget.username,);
      case 'CV Havuzu':
        return CVListScreen();
      case 'Yaklaşan Doğum Günleri':
        return UpcomingBirthdays();
      default:
        return Container();
    }
  }

}
