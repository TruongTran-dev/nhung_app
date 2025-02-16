import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /// /// *****************Firebase Service*************

  Future uploadImageToStorage({
    required File image,
  }) async {
    String imageUrl = '';

    try {
      String fileName = 'collection_${DateTime.now().millisecondsSinceEpoch}';
      Reference reference = _firebaseStorage.ref().child('images').child('collections').child(fileName);
      UploadTask uploadTask = reference.putFile(File(image.path));
      
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
          debugPrint('processing ${taskSnapshot.bytesTransferred}/${taskSnapshot.totalBytes}');
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress =
                100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            print("Upload is $progress% complete.");
            break;
          case TaskState.paused:
            print("Upload is paused.");
            break;
          case TaskState.canceled:
            print("Upload was canceled");
            break;
          case TaskState.error:
          // Handle unsuccessful uploads
            break;
          case TaskState.success:
            print(taskSnapshot.storage.bucket);
          // Handle successful uploads on complete
          // ...
            break;
        }
      });
      await uploadTask.whenComplete(() => null);
      imageUrl = await reference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      log(e.toString());
    }
  }
}
