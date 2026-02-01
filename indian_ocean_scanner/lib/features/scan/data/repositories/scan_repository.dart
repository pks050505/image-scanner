import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/dish_entity.dart';

class ScanRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadImage(File imageFile) async {
    final String requestId = const Uuid().v4();
    final String fileName = 'menu_$requestId.jpg';
    final ref = _storage.ref().child('menu_scans/$fileName');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'requestId': requestId,
        'uploadTime': DateTime.now().toIso8601String(),
      },
    );

    await ref.putFile(imageFile, metadata);
    return requestId;
  }

  Stream<Map<String, dynamic>?> listenToScanResults(String requestId) {
    return _firestore.collection('scanResults').doc(requestId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data['status'] == 'completed') {
          final dishes =
              (data['dishes'] as List<dynamic>?)
                  ?.map((e) => DishEntity.fromMap(e as Map<String, dynamic>))
                  .toList() ??
              [];
          return {'status': 'completed', 'dishes': dishes};
        }
      }
      return {'status': 'processing'};
    });
  }
}
