import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:logger/logger.dart';

class DataExportService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> downloadUserData({bool asCSV = false}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final uid = user.uid;

    // 1. Gather user data from Firestore
    final profileDoc = await _firestore.collection('users').doc(uid).get();
    final sessionsSnap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('sessions')
            .get();

    final dataMap = {
      'profile': profileDoc.data(),
      'sessions': sessionsSnap.docs.map((doc) => doc.data()).toList(),
    };

    // 2. Convert to desired format
    String fileContent;
    String fileName;

    if (asCSV) {
      // Flatten and convert to CSV
      List<List<String>> csvData = [
        ['Field', 'Value'],
      ];
      dataMap.forEach((key, value) {
        if (value is Map) {
          value.forEach((k, v) => csvData.add(['$key.$k', v.toString()]));
        } else if (value is List) {
          for (var i = 0; i < value.length; i++) {
            value[i].forEach(
              (k, v) => csvData.add(['$key[$i].$k', v.toString()]),
            );
          }
        } else {
          csvData.add([key, value.toString()]);
        }
      });

      fileContent = const ListToCsvConverter().convert(csvData);
      fileName = 'user_data.csv';
    } else {
      fileContent = const JsonEncoder.withIndent('  ').convert(dataMap);
      fileName = 'user_data.json';
    }

    // 3. Save to file
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception("Storage permission not granted");
    }

    final dir = await getExternalStorageDirectory();
    final filePath = '${dir!.path}/$fileName';
    final file = File(filePath);

    await file.writeAsString(fileContent);

    final logger = Logger();
    logger.i("✅ File saved at: $filePath");
  }
}
