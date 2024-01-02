import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book_app/components/vars.dart';
import '../models/akun.dart';
import '../models/laporan.dart';
import 'styles.dart';

class ListItem extends StatefulWidget {
  final Laporan laporan;
  final Akun akun;
  final bool isLaporanku;
  ListItem(
      {super.key,
      required this.laporan,
      required this.akun,
      required this.isLaporanku});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  void deleteLaporan() async {
    try {
      await _firestore.collection('laporan').doc(widget.laporan.docId).delete();
      if (widget.laporan.gambar != '') {
        await _storage.refFromURL(widget.laporan.gambar!).delete();
      }
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: {
            'akun': widget.akun,
            'laporan': widget.laporan,
          });
        },
        onLongPress: () {
          if (widget.isLaporanku) {
            showDialog(
                context: context,
                builder: (BuildContext buildContext) {
                  return AlertDialog(
                    title: Text('Hapus ${widget.laporan.judul} ?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(buildContext);
                        },
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteLaporan();
                          Navigator.pop(buildContext);
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  );
                });
          }
        },
        child: Column(
          children: [
            widget.laporan.gambar != ''
                ? Image.network(
                    widget.laporan.gambar!,
                    width: 130,
                    height: 130,
                  )
                : Image.asset(
                    'assets/istock-default.jpg',
                    width: 130,
                    height: 130,
                  ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(width: 2),
                ),
              ),
              child: Text(
                widget.laporan.judul,
                style: headerStyle(level: 4),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.laporan.status == 'Posted'
                          ? warnaStatus[0]
                          : widget.laporan.status == 'Process'
                              ? warnaStatus[1]
                              : warnaStatus[2],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.laporan.status,
                      style: headerStyle(
                        level: 5,
                        dark: false,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 2,
                  color: Colors.black,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(widget.laporan.tanggal),
                      style: headerStyle(
                        level: 5,
                        dark: false,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
