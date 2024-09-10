import 'dart:convert';
import 'package:deneme/homeappbar.dart';
import 'package:deneme/utils/button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlamak için
import 'package:http/http.dart' as http;

class HomePageScreen extends StatelessWidget {
  final String username;
  List<Map<String, String>> cardInfoList = [
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpctgvrl2drOxNM-h04eFvD32tUhl08GrrLg&s',
        'description': 'Personel',
      },
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0UaRcB77QCaV8itm2Zs_bhJv7ccLKozn-w6ut9KkNig&s',
        'description': 'Ürün',
      },
    
      {
        'imageUrl':
            'data:image/png;base64,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',
        'description': 'Üretim',
      },
      {
        'imageUrl':
            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAA/1BMVEX///8oKCj/AAAlJSUrKyu8vLyKiooAAAAxMTG4uLggICAcHBwiIiIaGhr6+vpNTU3j4+Ps7OzS0tKCgoI1NTVDQ0OysrIODg719fUWFhbv7+/m5uY6Ojqenp4LCwvJycnb29tGRkZubm5bW1v/7++bm5toaGioqKh0dHSPj4+Dg4P/3NxdXV3Nzc3/9PT/v7//SEj/ra3/OTn/1NT/ZGT/5+f/GRn/pKT/gID/cnL/l5f/T0//ycn/JCT/Ly//Pz//jIz/Wlr/Z2f/ubn/eHj/j49jcXHNp6dBTk6khYWtu7vs3NyCeXkQIyMmMTG8nZ28jo7ijIzZmJjO29t2hoa8mgFjAAAVGElEQVR4nO1cCXviSJIFJ+LITEnckkAggQAJA7bLLp/lo1zl3qNnp2d3Z/7/b9mM1H2A8cF2zW6+rw8jdOTLI+JFZIhSSUBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBA4KPQ29IvgLZ+OIbDjln509H17IMRtEcqLf/poJN580AEJbXyZ7ML4EiH4Kcs6S8wgD4oqR6AYQOj+BGIytp4PNaM4CAKEH4df6IGO1FO9w3CBr9apoVXJ8+kxBgDDEJR6g6NTydoqzjuQtl0qg3LsqT52iTQ+l6Aun+CGX6iaD1i51XVRPMw6i3mEjvaqKpdmX1RCS42s4uAkq7acS3AvKN2caKfqGp/NsNR3EZjMoqX+tCdGMhs+Rh60A2oK/mfOtok6Op2ORpesmjE1r5drWPqDPyr25PUKCKjN2onWtB2VSM+gc4/maC+CDsQjavD1Fetec0M/lSOCWcYNKxaaQVfjEg4gLSf9ma2M3aCP4cpS42NeauURsvF0USi68/1ikrUv9Ts5761wjYqnSRDZbkJm+YEbSdrO3f1aB380UwyNJz8mawTpiFFVP9cl9Fq9AKjMLYKvg4flmFoK8HxdtAuYzEouDqcikmG2jo7gD70zjhkaL+fTgGGfZ8hqhcRjJBmGKPjT1KsKoWXBUgwJN7WOdjBAcPsQz6GkCEe7TxtG0O/35Fp77w6ZkgnRWPtQ1+QAzLE6+QgKLqupwelgOGgb+mS5s88t5S+OjOiEUOE4xsoQ/fY85bt+NwBd5wHYijb8SF7rnbN7sJNLvg8Q7s+HndN3/ebiTPb84XJnF0judoihiT2BO1FTSOEGDWzH3F0jYMxJNO4J6umQZkMwVovYVtzDIegEwKxMo5P1I+7TA2BYFET6zpkiMyo19x66GaoES3NAVjmwzBEUXP0xTh0vnTsbWc4GkfWkaqRG21NItdNa/F4hQzlSHS6tYQGMLph//bJgRhSNerbqhw/uaxFg5Nj2IvtP+mEDQxsRbDmaKQwQ4Y1Ozhgmyk9q4Wd0eyiwzAk0WBtaskno27YpCxDJXEeiezM3EheTXvhWgwYol7YE1MZJUEjW8ym6UEYGtGEWuBkG+POzTJsJxjSKKbD6SBiHFIPGJJOeLdGJn3RCOf5sXwYhtFsbJrpNqJIl2YY9rX4nEo4xS2SuphN/jRDY7fPBTD3cxCG0fqQspFcLTBzuxjWwwGYZxiiSvBFwLBQF6Zh1w7MsJFjGHyTZZhYcTHDapZhOfgmYIhfZzg4NEPXSLdxK8OEyY0ZHucYBvPXZ4gqm9JrODjDftrQMIbB0/ZimJul5WCO/0JjKFUy07QWfLGLYSW8upG1NJPgi+w61FtbMDjUOtRC3zzM2FIaerAdDMso9BY6SV9thBImYBiZbLe2FQfSNLE/nKaHYas/TDIkkRPwUssYGXaaITkOH2oUZN+iyw7BEE/Dj3bq2XQSLrGdDL1QtQ3U5DqWl+Fds5pG6SS14f8GQzSxw89LLfGsaPbunqW9SNW2o4iBXbyIovlQl45b0XkpXYrGRvz5QNFTLLGXcXSAokHYyTAZANsO5tINkXInOhjHFuE0LUnlxGgTs913KD4oQ+rE8eG8rrH4kOJxL7GHsJMhKscnDhoOZQajPrUScX7IkE6iuNiawFMAZNxpwnXrGkaHY1g2EtHucK72zN7aTaaMdjJMWCoGfcCsfjqPEcX4OD5RGandSr1e73mhy90s6gfMYtBeKhmsDDOn7Wb4SqIukadBSVnTtCwrtSnqp50PlWvr7MwH7maYCAULEefadqYdfW98KIbl2nLXaa8wLBO1KFEdsknmS9fZ6RGh6fuagzEsG27B18U57zxDNjh5Wd0MpUAy502cLaPYcshBbKluRftChpfL1kphDPsqwzLFo/TlilQJHUZq34JMChetZZJwUdufxC1AtLcCeybpZ7fmxpa9pwKGzMWr/cRUtTqyFk58OyV3KV7mprRdJXFafOeafjuUaty/uLLYhHNIGYwmmJoK5L91RQ/G0OIf9Vyw67eN9BZzazNobvpVp0JiQd/O5EZk09vENlTRLc+Uo1NwJ9fGD2LTi5+PcK3ijSA1NHI0UFIo1PzBGtFSH/PjCLvctZq/zY1QOBjSOHseqaHpkieh+tU1GieCEmS+HkW+EUpVSz/c0BgMWt4XUS/UtNRYaZEDWhYIbYRljUNO7eOzkOvzy4YGU7ojmHmdYD1aN5IZjy1KGK7e3t2F6PQQdVHDKiH+ts+Of4sPAhIbc/Z0rBFMKZbHlXnU1GGcXN19Z0TQ8VZ3+TFIXq9bfwd4jUVi3wLqG7y14yyqjYTXW/qB8at365pTaaey+gj0zaj6Dkz3yfQ2uSlD3c5rdxttDli5x5R94+2QRhU/GLR33dnfvUZq/7XbHZTge+HLBTqxt5/i+qaavp7S/yWx9K0kVrfqkH4Q13ZfTwf/khgGmg+XG4U2YjANfGSUZyuAPshu/P9KaIQ1etjLhwSKqwb5Rdqzt9/DdaYHKLqcvZydfZt9wo2izQpSV/vDeDB0vb2chCV5tFtUcai7fGdWceTxzuD0fVg9Hh0drT7hRgMvSpJRTet51RGYxdHS6dai0kyEi2LPoTrme6hDo+xXlQ7dTzKm90Bs9cAY3rM/Tk4/eLtWx0hKd9mXtUm1SSujonWmTygvNWLGlu8OD9fy4lNK2k6Prhizn4zg0TUfy+u9Lx26rltgEpfd7JZVSmri3pZogUVkWPVAtKJev2mbBNU+Yz3+vDo6eri7gUl69HB7fc7+92XfayVDqxVEb4o0kbdpa4SLTFBwOw3CYUibMp0+meBMZdZ78XKUw+3J65dxf9enZcy1/yCzYFojtVwUoCBaXxdJzc2SSVllzoIqTOq9nlkmFALKyqeEhifPWYKPe5hUiRefusSvb7Wd3Eja7roi42RFN0KYMCldFCu0nLFZ3RwTROW1a9m2LY2gSpg628v63oIZ2Jij59PZ7OKFzdijq4vcKYqS6XepgsujwVyFeh7Pbk+IcZwze7q0XKdeS+lN53bxrJuPmZatsy5Qo6TJoG8y8eNCSe/HU21PjNad/+cF+/MpN4RD1Um/vdLsYdYkavgy26CUxfVF9l+3paWnmqbZW3dcq7l1UQ2mvCgOL5Pd1HQwIqNOr9bbdtm+AFY34Ycv7MPP8IMy8k1Zo4YzRs31yWHDMPyUirwoFqKKNPccx1kfuztHYgCVSVpGyNkqLUMo/iGDenLzDMbzKnL1fFWeP9/AgREdIxsOsh4O0sPDsJPnUN5XmbpSv2NiCHq3+GbFtvrMpbgN6xXPxrprmj1m83weLqwD3xeXvm15io9894+A22ehOOFPjfa9m6oXDFWri5AhcVp2jxTnx9+CjYHM/Ch7hLmN+YfMzczncxYfuYsZbijkXAabeTkoQbNVIvf8drBpGpnyoUqjKov3QB8MBh4hBY7Vpoh+0GEEY3geH0mMIeTeUaWu+YW6HWmjMucwaZaaUsPtoUT4A25x2Zf2t3m6ZLWjkVEWzqSOCkvAWg41Psjw5Mtvt2whgmzzMTtj/vD27pTbU55uQPxlJWYyK7DgYLaOCGXmBcXRAVSBEkz2yPsF1rSN6vUoxG/VKLhNo+BqpUM+PP8ZVmzIfoQq5o7r79//YbHnWbB/gohcMc2ygXmCD1F2fMQHNVGypfPUUrJyuhhNV/XHeWSgqLam1K7xZLpZdEWVgDnbfNTxs2E7evH/BP19dmKbRmW6keq4TLV6BzRGu+9p4CAIxG3zMWLTtxxPn4HJ9Ac1Fq+ModUjhv/WjMOmtV+kq1jsn+WE+YQirwf7P8wl0fzLO2/Cii+8h7v7iy9P/M/7fzHYfYERVuN7tyBiQLC3a01Vp4LiuqCSVUFIXU8LQ6IEoDZnDDZZYZMAL+CQ3qlNbf8O9YIrdP5qECLvdohKs9lswcrL6NJ/7fnRj+alRCQbg7I8bbX7HafdITRKNikdpj/jaP7ycotw18FymZbdgG0Lv5q2ajC1pvPtNq1gKg57LIqWy5N3J63serc+vUmxu+KxRfsPCH6wlxkU22GjaNYxNtwm01hhaLPEfkx+wj/Pzq4e8sqWAzYZmY1BfmSlLodLZrEwvCxmq0grmIoNg6qb1gfSUpaB8L9B+uLs9JqP5Pnd6TfuKixe+pVbVza3rIy7aTHzaawbTb1ldVhUxxie/PzKtd8q8DUFkPwQI4z0DZ61gRJMsGl4kScyoeS9Lx/qxzb7b0Mroy5r0vO//166P/JD39kztG+wpggX6CyXp5mIOee7RxhNHLXOZzT5/WfA7C5Uttd3UZOtJZ/Rcz8EJpiBBFXueKHryzq31LnV1jdQ/Z0TdLged61Sk+eMJP0v//FXw718DPI0JZCkllE2itJdOihkOm1DySKEFggCVQLt++NvMAdWl6tzPxsCTMMopWlqtNMceGPY7u15o4ZlNebTLu8tKjHlQsvMw9LoVYcAEtMB9H2ZGsVh4qTbmfgOfTFlHv2vfzuLcm1Kq+mRuA42BYh5l7o+NcqyOq/LfLJ1Omy2d9sQZn47e/Bn+4qrv8DkLAx4EZYt4rJMRmEMpberNcyT+0pHqzidLosOU2ysLswTwiLs2eXl5RspglhBbJpQAu8kwYdK+/rl5QZaJFUqmIC/KvRuLey7CW88HXAbw1+vcf8w7dKPXDbkOnocFwugblMxlr0mvKhlc7z0WhJrUT1OHzaPMZsf7ELDKz0cvTnR6fsZLDue19P402NDNvfT7tuWOBOkIJF1F4x7H3N7dPf9P/9e4tMTfM3jVUDwLOx45djf1TaWGWMyYHMBlatrE2tLiNGQsXY3Q11vSsse8yOmNTcNY1OCm20xz1sx7IKZtnVF0fs90M3xVx3/Ta5tOmKNkSqF9ltijsODqPnhxzV09OPNxezkZLa645m7m/iqY96j1Zy1hMgXwQv4dNI2wU5jXO9NJmaZ+Evw7r+WIz8AAhNxf7u/39hAwBnMCLuOklNS8iYGvDG25UV/1tN0XF+4fLq112tnVDoPZ+VvUf7j5PqKz9LL+zt/ei1YNxa9k90MtvSJs4BApssLPSnYL5hF3yG9cnnNu2sFPfl1z30HpcVWRmxJeKwXP10fWqzLt43hwtdRvpBSWoOWXlr5Yu8q5QUvGMWr27Oro6/8xAkTbIXRFd9NRNq0rVJE3OEIfrEAkwlMrCm3Vs+B5jr/Cv/9tg8/3SBjkijlLrV6CGkaXseySSFJ2ZnCxK/QTu3+XX4rWCl8mwAAq1GqlYsi3OCGaNIotTyjAr3GjDXuDEqDHkW9/87ZruTM38GQV0Ikilx9u0OTm5omIlnJFpzLJIk8ro3TrzKfJgxnhGu/Td/tttRnI0+3yGcWi/F9f33E14XLjBdMH0kzxn8PEg5H356D7vqxR646YhiPUZ6h4tDEC6xJNJgJWFr2ML2kvhY+G8zNt9U/MPNHNF2gkUS7juLXHZl5lrH/CwPzTrOk3LJbPFxDX1/AZH3YiyBjKGs48RJlqcVUoWHIcYK5DZQLg2vFw8hM5w0vL+5h6+Nn/mQ2iA+XpeA10iLZydFUKV3HHzeqGX+afYtnP5OTiZzgbrRsa4FRNyIkyQi57Wb4WXG51ET1AtPH3HJmPd0/PHD/V9B+SMTOBo6/17ZtGTIJzNqy3IRZdUUP90CUkxPI3t6FJ67Yc26YM9qPpMU8T1hl1jIpTYbnUlDCRvJ10K1uTuwES+Useyo0ibmR05k7NSEFsvWXdEDqIpk5oEzK6dK3oVexXgs2WPacqZB38JvaXuNyynC2VObHxxoTq1lZo3tyznEH4eWPgodAGx+eb37+pT+tbK9MYGEMt85aZpD5pjRbyLEHvHsDQ79ohxjrZVWt8cgl2YGuuZi32SiXa+myQNvxywzGqZTTxd1XZuhuC54S6rj70mCC8LYsTlgvnI1lAobP72M4h5sy9YBlprEhJKVJy6nb0Bi3woRdYuro/QmLKzTYpsjuwjDp8VzwlAtfoLKIn9lmWljaztAGAQlVqJmbBv70IZ6lP/ZnqJhs6pcdP3alPRZFIS1nOXWYPbi8dpsDhjaLedkanDSOTULMzHAwg3BV8BiIiR/Pn27ZKLBIFG1J7boys+uu1M5tvM1W95CejjakZ6zDvt6v9tNttmpUXGUDCgy5zeFUlvPhruWXqGENm+qka4D5obBHYs9z2/B3xdqfmfqX1UwB62wm3/FPQWGaxthWQDU7j02N8hLo7/1g899B6xuQxYBlmVf9igdhPIV6ch7IJ14VyrTn5PaqUE5dhLn04YJveBeX8zW07a7St2NP/CYzmKMPe9KLYBnlrVsqG6aIjalUVbmhk40KzNmiYbh/KNDd0CSmx5+4Jq0EPr+o7GDIJPb2bNMXf+U93Xx/foMsTaBdq9XULd/Na9QAHQfblMwjN+CXKwoz70Erjs4zFgAEFw8sJAOmAS780S7F4wmGLZHaRV55718Jw6FvNht725d9k//UEzhk7q2ZfiyTggBodnZ19nLDJup5cinOgk5n7kyfaqTrwFaglo3xId9T3lYiFeyDPQWi+4orgMe3MdwNm0tlZRqI/dLc0AqrPy7uZ76xebgOh1G5fgo7/Q5i6v5mwN8JNo7TeRpI2YGz4iUJeZyAor+84ES/XszY/88+oy4ti45B/d1ZZZr7WbUYCqfzeHu6ulyd3nBX/7J6uTo6A9J85AYerGSzPwgF6HBeYT6ETirMxRrFmm52CwsvymJ8OXtrym0PKCWXif3X0yPhaowBinn1W6LPR1zPG2anb202luuVId9Klro1RdrOH53jvffWTNQboLeGr793xLd3rlIMs+FU+Dt7iOBKtw5FFhC/wG9C6e3p7sw23O4Q0/MtgHj+2+XsGrTk4/MNrMLvmVPmGt9j5cTCvYvXfvUswP3Pn6d7Bk0Hw+rs6BzWCGSLmL25OEoFBRxMIiFt1Pb836GQtTG8u0U//6c7D4ZrbgSY8HiE+XSXY9jGGPHyfP7qK543mi4tjEF/cdwG+b6Tm59ZhWw5fmoINv25klJYtPnp7xYeHNdPj1tVR8tPtinM4vi/YtZiRsc80GtNfyrWOPxhGkl1/9mGcC8somyr8n+SH6QQNpt/NvsiICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDw/w7/A+eN0n7KouOGAAAAAElFTkSuQmCC',
        'description': 'Arge',
      },
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS2CdXwoDNhXOReLMzxnpGtATc8Sw0vWyuI1Q&s',
        'description': 'Teknik Servis',
      },
      {
        'imageUrl':
            'https://cdn-icons-png.flaticon.com/512/9138/9138046.png',
        'description': 'İstasyonlar',
      },
      {
        'imageUrl':
            'data:image/png;base64,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',
        'description': 'Hesap',
      },
      
      // Diğer kart baloncuklarını da buraya ekleyebilirsiniz
    ];

  HomePageScreen({Key? key, required this.username}) : super(key: key);

  // Tarih formatını parse eden bir fonksiyon
  String? parseDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr); // ISO 8601 formatında tarihi parse ediyoruz
      return DateFormat('d MMMM y', 'tr_TR').format(date);
    } catch (e) {
      print('Invalid date format for $dateStr: $e');
      return null;
    }
  }

  // Backend API'den bu ay doğan kişileri çekmek için bir fonksiyon
  Future<List<Map<String, dynamic>>> fetchPeopleBornThisMonth() async {
    final response = await http.get(Uri.parse('http://localhost:3000/upcoming-birthdays'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      DateTime now = DateTime.now();
      int currentMonth = now.month; // Bu satırı kontrol edin
      int currentYear = now.year;

      // Bu ay doğan kişileri filtreleyelim
      List<Map<String, dynamic>> peopleBornThisMonth = jsonResponse.where((person) {
        try {
          DateTime birthday = DateTime.parse(person['dgtarih']);
          return birthday.month == currentMonth; // Yılı kontrol etmiyoruz
        } catch (e) {
          print('Invalid date format for ${person['name']}: ${person['dgtarih']}');
          return false;
        }
      }).map((person) => {
        'name': person['name'],
        'birthday': person['dgtarih'],
      }).toList();

      return peopleBornThisMonth;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kart baloncuklarının dizilimini oluşturalım
    List<Widget> cardWidgets = cardInfoList.map((cardInfo) {
      return CardBaloncugu(
        imageUrl: cardInfo['imageUrl']!,
        description: cardInfo['description']!,
        username: username,
      );
    }).toList();

    // Kart baloncuklarını sırayla 4'lü gruplara ayıralım
    List<Widget> rows = [];
    for (int i = 0; i < cardWidgets.length; i += 4) {
      List<Widget> rowChildren = [];
      for (int j = i; j < i + 4 && j < cardWidgets.length; j++) {
        rowChildren.add(cardWidgets[j]);
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          HomeAppBar(username: username),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kart baloncukları bölümü
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Oluşturduğumuz sıralı 4'lü grupları ekleyelim
                        ...rows,
                      ],
                    ),
                  ),
                  
                  // Ay Doğanlar bölümünü sağ tarafa ekleyelim
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bu Ay Doğanlar',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: fetchPeopleBornThisMonth(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Veriler yüklenirken hata oluştu: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Text('Bu ay doğan kimse yok.');
                                } else {
                                  final peopleBornThisMonth = snapshot.data!;
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: [
                                        for (var person in peopleBornThisMonth)
                                          Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(person['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                                                // Doğum tarihini istenen formatta gösterelim
                                                Text(parseDate(person['birthday']!) ?? 'Geçersiz tarih formatı'),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
