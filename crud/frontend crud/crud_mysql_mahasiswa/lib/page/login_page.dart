import 'dart:convert';

import 'package:crud_mysql_mahasiswa/page/list_page.dart';
import 'package:crud_mysql_mahasiswa/model/admin.dart';
import 'package:crud_mysql_mahasiswa/page/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_mahasiswa.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHiddenPassword = true;

  var _controllerUsername = TextEditingController();
  var _controllerPassword = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  void login() async {
    if (_formKey.currentState.validate()) {
      var response = await http.post(ApiMahasiswa.URL_LOGIN, body: {
        'username': _controllerUsername.text,
        'password': _controllerPassword.text,
      });
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (responseBody['success']) {
          var admin = Admin.fromJson(responseBody['data']);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('admin', response.body);
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              backgroundColor: Colors.white,
              children: [
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 10),
                Center(child: Text('Loading...')),
              ],
            ),
          );

          Future.delayed(
            Duration(milliseconds: 1500),
            () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ListPage(admin: admin)),
              );
            },
          );
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Login Gagal'),
            duration: Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[700],
          ));
        }
      } else {
        throw Exception('Exception Gagal Login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildHeader(context),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  controller: _controllerUsername,
                  validator: (value) =>
                      value.isEmpty ? 'Tidak boleh kosong' : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    labelText: 'Username',
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  controller: _controllerPassword,
                  validator: (value) =>
                      value.isEmpty ? 'Tidak boleh kosong' : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 2, 0, 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    suffixIcon: InkWell(
                      onTap: _togglePasswordView,
                      child: Icon(Icons.visibility)),
                  ),
                  cursorColor: Colors.black,
                  obscureText: isHiddenPassword,
                ),
              ),
              SizedBox(height: 30),
              Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black, Colors.lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () => login(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 150,
                        height: 45,
                        alignment: Alignment.center,
                        child: Text('Log in',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Material()
            ],
          ),
        ),
      ),
    ); 
  }

  void _togglePasswordView() {
    isHiddenPassword = !isHiddenPassword;
    setState(() {});
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      height: 300,
      child: Stack(
        children: [
          ClipPath(
            clipper: _ClipHeader(),
            child: Container(color: Colors.lightBlue),
          ),
          Positioned(
            top: 80,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
                Text(
                  'Log In',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 80,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              ),
              child: Row(
                children: [
                  Text(
                    'Register',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ClipHeader extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path();
    double height = size.height;
    double width = size.width;

    path.lineTo(0, height * 0.8);
    path.quadraticBezierTo(width * 0.35, height, width * 0.6, height * 0.5);
    path.quadraticBezierTo(
        width * 0.7, height * 0.3, width * 0.8, height * 0.4);
    path.quadraticBezierTo(width * 0.9, height * 0.48, width, height * 0.4);
    path.lineTo(width, height * 0.5);
    path.lineTo(width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}
