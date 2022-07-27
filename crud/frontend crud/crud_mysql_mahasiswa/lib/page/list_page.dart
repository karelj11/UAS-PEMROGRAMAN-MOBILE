import 'dart:convert';
import 'dart:ui';

import 'package:crud_mysql_mahasiswa/api_mahasiswa.dart';
import 'package:crud_mysql_mahasiswa/model/admin.dart';
import 'package:crud_mysql_mahasiswa/model/mahasiswa.dart';
import 'package:crud_mysql_mahasiswa/page/add_update_mahasiswa_page.dart';
import 'package:crud_mysql_mahasiswa/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ListPage extends StatefulWidget {
  final Admin admin;

  ListPage({this.admin});
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Mahasiswa>> getMahasiswa() async {
    List<Mahasiswa> listMahasiswa = [];
    var response = await http.get(ApiMahasiswa.URL_GET_MAHASISWA);
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        List listJson = responseBody['data'];
        listJson.forEach((element) {
          listMahasiswa.add(Mahasiswa.fromJson(element));
        });
      }
    } else {
      print('Request gagal');
    }

    return listMahasiswa;
  }

  void deleteMahasiswa(String nim, String foto) async {
    var response = await http.post(ApiMahasiswa.URL_DELETE_MAHASISWA, body: {
      'nim': nim,
    });
    await http.post(ApiMahasiswa.URL_DELETE_FOTO, body: {
      'nama': foto,
    });
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var message = '';
      if (responseBody['success']) {
        message = 'Berhasil Dihapus';
      } else {
        message = 'Gagal Dihapus';
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 1500),
      ));
    } else {
      print('Request gagal');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[700],
        title: Text(widget.admin.username),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder(
        future: getMahasiswa(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              print('ConnectionState.none');
              return Center(child: Text('ConnectionState.none'));
              break;
            case ConnectionState.active:
              print('ConnectionState.active');
              return Center(child: Text('ConnectionState.active'));
              break;
            case ConnectionState.waiting:
              print('ConnectionState.waiting');
              return Center(child: Text('ConnectionState.waiting'));
              break;
            case ConnectionState.done:
              print('ConnectionState.done');
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  return buildList(snapshot.data);
                } else {
                  return Center(child: Text('Tidak ada data'));
                }
              } else {
                print('snapshot error');
                return Center(child: Text('Error'));
              }
              break;
            default:
              print('Undefine Connection');
              return Center(child: Text('Undefine Connection'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: Icon(Icons.add, color: Colors.black),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddUpdateMahasiswaPage(type: 'Tambah'),
          ),
        ).then((value) => setState(() {})),
      ),
    );
  }

  Widget buildList(List<Mahasiswa> listmahasiswa) {
    return ListView.builder(
      itemCount: listmahasiswa.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        var mahasiswa = listmahasiswa[index];
        return Container(
          margin: EdgeInsets.fromLTRB(
            16,
            index == 0 ? 16 : 10,
            16,
            index == 9 ? 16 : 10,
          ),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  color: Colors.black26,
                ),
              ]),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  '${ApiMahasiswa.URL_FOTO}/${mahasiswa.foto}',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NIM: ${mahasiswa.nim}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.black45,
                      ),
                    ),
                    Text(
                      'Nama: ${mahasiswa.nama}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Jurusan: ${mahasiswa.jurusan}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Material(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.lightGreen[700],
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddUpdateMahasiswaPage(
                            type: 'Edit',
                            mahasiswa: mahasiswa,
                          ),
                        ),
                      ).then((value) => setState(() {})),
                      borderRadius: BorderRadius.circular(5),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Material(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.red[700],
                    child: InkWell(
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                content: Text('Yakin untuk menghapus?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Tidak')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'ok'),
                                      child: Text('Ya')),
                                ],
                              )).then((value) {
                        if (value == 'ok') {
                          deleteMahasiswa(mahasiswa.nim, mahasiswa.foto);
                          getMahasiswa();
                          setState(() {});
                        }
                      }),
                      borderRadius: BorderRadius.circular(5),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.delete_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
