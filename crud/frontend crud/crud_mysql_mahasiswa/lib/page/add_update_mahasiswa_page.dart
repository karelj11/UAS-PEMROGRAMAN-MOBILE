import 'dart:convert';
import 'dart:io';

import 'package:crud_mysql_mahasiswa/api_mahasiswa.dart';
import 'package:crud_mysql_mahasiswa/model/mahasiswa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddUpdateMahasiswaPage extends StatefulWidget {
  final String type;
  final Mahasiswa mahasiswa;

  AddUpdateMahasiswaPage({this.type, this.mahasiswa});
  @override
  _AddUpdateMahasiswaPageState createState() => _AddUpdateMahasiswaPageState();
}

class _AddUpdateMahasiswaPageState extends State<AddUpdateMahasiswaPage> {
  var _controllerNim = TextEditingController();
  var _controllerNama = TextEditingController();
  var _controllerJurusan = TextEditingController();
  var _controllerTanggalLahir = TextEditingController();
  var _controllerAlamat = TextEditingController();
  File _foto;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _fotoSebelumUpdate;

  Future getFoto() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _foto = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void editMahasiswa(Mahasiswa mahasiswa) async {
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
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });

    if (_foto != null) {
      await http.post(ApiMahasiswa.URL_DELETE_FOTO, body: {
        'nama': _fotoSebelumUpdate,
      });
      await http.post(ApiMahasiswa.URL_UPLOAD_FOTO, body: {
        'foto': base64Encode(_foto.readAsBytesSync()),
        'nama': mahasiswa.foto,
      });
    }
    var response = await http.post(ApiMahasiswa.URL_EDIT_MAHASISWA,
        body: mahasiswa.toJson());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var message = '';
      if (responseBody['success']) {
        message = 'Berhasil Mengupadate Mahasiswa';
      } else {
        message = 'Gagal Mengupadate Mahasiswa';
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      print('Request Error');
    }
  }

  void addMahasiswa(Mahasiswa mahasiswa) async {
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
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
    var responseNim = await http.post(ApiMahasiswa.URL_CHECK_NIM, body: {
      'nim': mahasiswa.nim,
    });
    var check = jsonDecode(responseNim.body);
    if (check['ada']) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('NIM Sudah Terdaftar'),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[700],
      ));
    } else {
      await http.post(ApiMahasiswa.URL_UPLOAD_FOTO, body: {
        'foto': base64Encode(_foto.readAsBytesSync()),
        'nama': mahasiswa.foto,
      });
      var response = await http.post(ApiMahasiswa.URL_ADD_MAHASISWA,
          body: mahasiswa.toJson());
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var message = '';
        if (responseBody['success']) {
          message = 'Berhasil Menambahkan Mahasiswa';
        } else {
          message = 'Gagal Menambahkan Mahasiswa';
        }
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        print('Request Error');
      }
    }
  }

  @override
  void initState() {
    if (widget.mahasiswa != null) {
      _controllerNim.text = widget.mahasiswa.nim;
      _controllerNama.text = widget.mahasiswa.nama;
      _controllerJurusan.text = widget.mahasiswa.jurusan;
      _controllerTanggalLahir.text = widget.mahasiswa.tanggalLahir;
      _controllerAlamat.text = widget.mahasiswa.alamat;
      _fotoSebelumUpdate = widget.mahasiswa.foto;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text('${widget.type} Mahasiswa'),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black,),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Text('Konfirmasi ${widget.type} Mahasiswa'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Tidak')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, 'ok'),
                                child: Text('Ya')),
                          ],
                        )).then((value) {
                  if (value == 'ok') {
                    var mahasiswa = Mahasiswa(
                      nim: _controllerNim.text,
                      nama: _controllerNama.text,
                      jurusan: _controllerJurusan.text,
                      tanggalLahir: _controllerTanggalLahir.text,
                      alamat: _controllerAlamat.text,
                      foto: _foto != null
                          ? _foto.path.split('/').last
                          : _fotoSebelumUpdate,
                    );
                    if (widget.type == 'Edit') {
                      editMahasiswa(mahasiswa);
                    } else {
                      addMahasiswa(mahasiswa);
                    }
                  }
                });
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerNim,
              enabled: widget.mahasiswa != null ? false : true,
              validator: (value) => value.isEmpty ? 'Tidak boleh kosong' : null,
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
                labelText: 'NIM',
                hintText: '1111',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: Icon(Icons.vpn_key_rounded, color: Colors.black),
              ),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerNama,
              validator: (value) => value.isEmpty ? 'Tidak boleh kosong' : null,
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
                labelText: 'Nama',
                hintText: 'Nama',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: Icon(Icons.person, color: Colors.black),
              ),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerJurusan,
              validator: (value) => value.isEmpty ? 'Tidak boleh kosong' : null,
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
                labelText: 'Jurusan',
                hintText: 'Jurusan',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: Icon(Icons.home_work, color: Colors.black),
              ),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerTanggalLahir,
              validator: (value) => value.isEmpty ? 'Tidak boleh kosong' : null,
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
                labelText: 'Tanggal Lahir',
                hintText: '0000-00-00',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: GestureDetector(
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(DateTime.now().year - 50, 1),
                              lastDate: DateTime(DateTime.now().year, 12))
                          .then((value) {
                        _controllerTanggalLahir.text =
                            value.toIso8601String().substring(0, 10);
                      });
                    },
                    child: Icon(Icons.date_range, color: Colors.black)),
              ),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controllerAlamat,
              validator: (value) => value.isEmpty ? 'Tidak boleh kosong' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                labelText: 'Alamat',
                hintText: 'Alamat',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: Icon(Icons.home, color: Colors.black),
              ),
              maxLines: 3,
              cursorColor: Colors.black,
            ),
            SizedBox(height: 16),
            Text('Foto'),
            SizedBox(height: 16),
            RaisedButton(
              onPressed: () => getFoto(),
              color: Colors.lightBlue,
              textColor: Colors.black,
              child: Text('Pilih Foto'),
            ),
            SizedBox(height: 16),
            Center(
              child: SizedBox(
                child: widget.type == 'Edit'
                    ? _foto != null
                        ? Image.file(
                            _foto,
                            width: 150,
                            height: 150,
                          )
                        : Image.network(
                            '${ApiMahasiswa.URL_FOTO}/${widget.mahasiswa.foto}',
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                          )
                    : _foto == null
                        ? null
                        : Image.file(
                            _foto,
                            width: 150,
                            height: 150,
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
