import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rumahsakit/screen_page/page_detailrs.dart';

import '../model/model_rs.dart';

class PageRumahSakit extends StatefulWidget {
  final String kabupatenId;

  const PageRumahSakit({Key? key, required this.kabupatenId}) : super(key: key);

  @override
  State<PageRumahSakit> createState() => _PageRumahSakitState();
}

class _PageRumahSakitState extends State<PageRumahSakit> {
  bool isLoading = false;
  List<Datum> listRumahSakit = [];
  List<Datum> filteredRumahSakit = [];

  @override
  void initState() {
    super.initState();
    fetchRumahSakitData();
  }

  Future<void> fetchRumahSakitData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.1.15/Rumah%20Sakit/getRumahSakit.php?id_kabupaten=${widget.kabupatenId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ModelRs modelRs = ModelRs.fromJson(data);
          listRumahSakit = modelRs.data.where((datum) => datum.kabupatenId == widget.kabupatenId).toList();
          filteredRumahSakit = List.from(listRumahSakit);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void searchRumahSakit(String query) {
    setState(() {
      filteredRumahSakit = listRumahSakit.where((rumahSakit) {
        return rumahSakit.namaRs.toLowerCase().contains(query.toLowerCase()) ||
            rumahSakit.id.toLowerCase() == query.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('List Rumah Sakit'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: searchRumahSakit,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                hintText: 'Search Rumah Sakit',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRumahSakit.length,
              itemBuilder: (context, index) {
                final rumahSakit = filteredRumahSakit[index];
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: Image.network('http://192.168.1.15/Rumah%20Sakit/gambar/${rumahSakit.gambar}', width: 100, height: 80,),
                      title: Text(
                        rumahSakit.namaRs,
                        style: TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alamat: ${rumahSakit.alamat ?? 'N/A'}'),
                          Text('Deskripsi: ${rumahSakit.deskripsi ?? 'N/A'}'),
                          Text('No Telp: ${rumahSakit.noTelp ?? 'N/A'}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageDetailRS(rumahSakit: rumahSakit
                              // idRs: rumahSakit.id,
                              // namaRs: rumahSakit.namaRumahSakit,
                            ),
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
