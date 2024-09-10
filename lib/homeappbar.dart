import 'dart:convert';
import 'package:deneme/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeAppBar extends StatelessWidget {
  final bool bildirim;
  final String username;

  HomeAppBar({Key? key, required this.username, this.bildirim = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username.isNotEmpty ? "Hoşgeldin $username" : "Hoşgeldin Ziyaretçi",
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const NotificationsPage(),
                      //   ));
                    },
                    icon: Icon(
                      bildirim ? Icons.message : Icons.message_outlined,
                      color: bildirim ? Colors.blue : Colors.black,
                    ),
                  ),
                  if (bildirim)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Çıkış Yap'),
                    ),
                  ];
                },
                icon: const Icon(Icons.person_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}