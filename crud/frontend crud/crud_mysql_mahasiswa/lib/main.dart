import 'dart:convert';

import 'package:crud_mysql_mahasiswa/model/admin.dart';
import 'package:crud_mysql_mahasiswa/page/list_page.dart';
import 'package:crud_mysql_mahasiswa/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var admin = prefs.getString('admin');
  var responseBody;
  if (admin != null) {
    responseBody = json.decode(admin);
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: admin == null
        ? LoginPage()
        : ListPage(admin: Admin.fromJson(responseBody['data'])),
  ));
}
