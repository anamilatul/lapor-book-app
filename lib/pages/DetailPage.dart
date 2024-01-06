import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book_app/components/status_dialog.dart';
import 'package:lapor_book_app/components/styles.dart';
import 'package:lapor_book_app/models/akun.dart';
import 'package:lapor_book_app/models/laporan.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/vars.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLiked = false;
  int _likeCount = 0;

  Future launch(String url) async {
    if (url == '') return;
    if (await launchUrl(Uri.parse(url))) {
      throw Exception('Tidak dapat memanggil $url');
    }
  }

  Future<void> _fetchLikeData(Laporan laporan, Akun akun) async {
    try {
      final docSnapshot =
          await _firestore.collection('laporan').doc(laporan.docId).get();

      final likes = docSnapshot.data()?['likes'] ?? 0;
      final likedBy = List<String>.from(docSnapshot.data()?['likedBy'] ?? []);

      setState(() {
        _likeCount = likes;
        _isLiked = likedBy.contains(akun.uid);
      });
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> _likes(Laporan laporan, Akun akun) async {
    try {
      if (!_isLiked) {
        Timestamp timestamp = Timestamp.fromDate(DateTime.now());
        await _firestore.collection('laporan').doc(laporan.docId).update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([akun.uid]),
          'timeLiked': FieldValue.arrayUnion([timestamp]),
        });
      } else {
        // Jika sudah like, hapus user dari daftar likedBy
        Timestamp timestamp = Timestamp.fromDate(DateTime.now());
        await _firestore.collection('laporan').doc(laporan.docId).update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([akun.uid]),
          'timeLiked': FieldValue.arrayUnion([timestamp]),
        });
      }

      // Update tampilan setelah like diubah
      _fetchLikeData(laporan, akun);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Akun akun = arguments['akun'];
    final Laporan laporan = arguments['laporan'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Detail Laporan",
          style: headerStyle(level: 3, dark: false),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                laporan.judul,
                style: headerStyle(level: 2),
              ),
              const SizedBox(
                height: 15,
              ),
              laporan.gambar != ''
                  ? Image.network(
                      laporan.gambar!,
                      height: 200,
                    )
                  : Image.asset(
                      'assets/istock-default.jpg',
                      height: 200,
                    ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: textStatus(
                      laporan.status,
                      laporan.status == 'Posted'
                          ? warnaStatus[0]
                          : laporan.status == 'Process'
                              ? warnaStatus[1]
                              : warnaStatus[2],
                      Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: textStatus(
                      laporan.instansi,
                      Colors.white,
                      Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Jumlah Like : ${_likeCount}"),
                  Container(
                    width: 100,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 215, 180, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        _likes(laporan, akun);
                      },
                      child: _isLiked ? Text("Liked") : Text("Like"),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Nama Pelapor"),
                subtitle: Text(laporan.nama),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text("Tanggal"),
                subtitle:
                    Text(DateFormat('dd/MM/yyyy').format(laporan.tanggal)),
                trailing: IconButton(
                  onPressed: () {
                    launch(laporan.maps);
                  },
                  icon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "Deskripsi",
                style: headerStyle(level: 2),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(laporan.deskripsi ?? ""),
              const SizedBox(
                height: 30,
              ),
              if (akun.role == 'admin')
                Container(
                  width: 250,
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatusDialog(
                            laporan: laporan,
                          );
                        },
                      );
                    },
                    child: const Text("Ubah Status"),
                  ),
                ),
            ],
          ),
        ),
      )),
    );
  }

  Container textStatus(String text, var bgColor, var fgColor) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          width: 1,
          color: primaryColor,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: fgColor,
        ),
      ),
    );
  }
}
