import 'dart:convert';

import 'package:crud_mysql_mahasiswa/api_mahasiswa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isHiddenPassword = true;

  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _controllerUsername = TextEditingController();
  var _controllerPassword = TextEditingController();

  void register() async {
    if (_formKey.currentState.validate()) {
      var response = await http.post(ApiMahasiswa.URL_REGISTER, body: {
        'username': _controllerUsername.text,
        'password': _controllerPassword.text,
      });
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var message = '';
        if (responseBody['success']) {
          message = 'Berhasil Register';
        } else {
          message = 'Gagal Register';
        }
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        throw Exception('Gagal Login');
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
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.person, color: Colors.black),
                  ),
                  cursorColor: Colors.black,
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
                      suffixIcon: InkWell(
                          onTap: _togglePasswordView,
                          child: Icon(Icons.visibility)),
                      prefixIcon: Icon(Icons.lock, color: Colors.black)),
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
                      onTap: () => register(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 150,
                        height: 45,
                        alignment: Alignment.center,
                        child: Text('Register',
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
              Material(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 150,
                        height: 45,
                        alignment: Alignment.center,
                        child: Text('Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
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
                  'Hello,',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
                Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
