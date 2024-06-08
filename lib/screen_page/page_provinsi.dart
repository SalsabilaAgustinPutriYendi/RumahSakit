import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/model_provinsi.dart';
import 'page_kabupaten.dart';

class PageBeranda extends StatefulWidget {
  const PageBeranda({Key? key}) : super(key: key);

  @override
  State<PageBeranda> createState() => _PageBerandaState();
}

class _PageBerandaState extends State<PageBeranda> {
  bool isLoading = false;
  List<Datum> listProvinsi = [];
  List<Datum> filteredProvinsi = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProvinsi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getProvinsi() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse("http://192.168.1.15/Rumah%20Sakit/getProvinsi.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ModelProvinsi modelProvinsi = ModelProvinsi.fromJson(data);
          listProvinsi = modelProvinsi.data;
          filteredProvinsi = List.from(listProvinsi);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      });
    }
  }

  void searchProvinsi(String query) {
    setState(() {
      filteredProvinsi = listProvinsi.where((provinsi) {
        return provinsi.namaProvinsi.toLowerCase().contains(query.toLowerCase()) ||
            provinsi.id.toLowerCase() == query.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('List Provinsi'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: searchProvinsi,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProvinsi.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    child: ListTile(
                      leading: Image.asset('gambar/provinsi.png', width: 65),
                      title: Text(
                        filteredProvinsi[index].namaProvinsi,
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageKabupaten(idProv: filteredProvinsi[index].id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}