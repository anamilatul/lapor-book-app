import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book_app/components/styles.dart';
import 'package:lapor_book_app/models/laporan.dart';

class StatusDialog extends StatefulWidget {
  final Laporan laporan;
  const StatusDialog({super.key, required this.laporan});

  @override
  State<StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  late String status;
  final _db = FirebaseFirestore.instance;
  void updatetatus() async {
    try {
      CollectionReference laporanCollection = _db.collection('laporan');
      await laporanCollection
          .doc(widget.laporan.docId)
          .update({'status': status});
      Navigator.pushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      status = widget.laporan.status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: primaryColor,
      content: Container(
        height: 400,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              widget.laporan.judul,
              style: headerStyle(
                level: 3,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            RadioListTile(
              title: const Text('Posted'),
              value: 'Posted',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('Process'),
              value: 'Process',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('Done'),
              value: 'Done',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                updatetatus();
              },
              child: const Text("Ubah Status"),
            ),
          ],
        ),
      ),
    );
  }
}
