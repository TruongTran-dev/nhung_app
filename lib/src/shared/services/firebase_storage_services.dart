import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads an image file to Firebase Storage and returns the download URL
  ///
  /// [file] - The image file to upload
  /// [storagePath] - The path in Firebase Storage where the image will be stored
  /// Returns the download URL as a String, or throws an exception on failure
  Future<String> uploadImage(File file) async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        throw FirebaseException(
          plugin: 'firebase_storage',
          code: 'firebase-not-initialized',
          message: 'Firebase has not been initialized. Please call Firebase.initializeApp() first.',
        );
      }

      // Check if the file exists
      if (!file.existsSync()) {
        throw FirebaseStorageException(
          message: 'The specified file does not exist at ${file.path}',
          code: 'file-not-found',
        );
      }

      // Check file size
      final fileSize = file.lengthSync();
      print('Uploading file of size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // Optional: You could impose size limits here
      // For example:
      // if (fileSize > 5 * 1024 * 1024) { // 5MB
      //   throw FirebaseStorageException(
      //     message: 'File exceeds maximum size of 5MB',
      //     code: 'file-too-large',
      //   );
      // }

      // Generate a unique file name using timestamp
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final fullPath = 'images/$fileName';

      // Create a reference to the storage location
      final ref = _storage.ref().child(fullPath);

      // Upload the file
      final bytes = await file.readAsBytes();
      final uploadTask = ref.putData(bytes);

      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: $progress%');
      });

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Handle specific Firebase Storage errors
      if (e.code == 'unknown' && e.message?.contains('cannot parse response') == true) {
        throw FirebaseStorageException(
          message: 'Failed to upload image due to a parsing error. '
              'Please check your Firebase configuration, authentication status, '
              'and network connectivity.',
          code: 'cannot-parse-response',
        );
      } else if (e.code == 'unauthorized') {
        throw FirebaseStorageException(
          message: 'Unauthorized access to Firebase Storage. '
              'Please check your Firebase Storage rules and authentication.',
          code: 'unauthorized',
        );
      } else if (e.code == 'canceled') {
        throw FirebaseStorageException(
          message: 'Image upload was canceled.',
          code: 'canceled',
        );
      } else if (e.code == 'object-not-found') {
        throw FirebaseStorageException(
          message: 'Storage path does not exist.',
          code: 'object-not-found',
        );
      } else {
        throw FirebaseStorageException(
          message: 'An error occurred while uploading the image: ${e.message}',
          code: e.code,
        );
      }
    } catch (e) {
      // Handle any other unexpected errors
      throw FirebaseStorageException(
        message: 'Unexpected error during image upload: $e',
        code: 'unexpected-error',
      );
    }
  }

  /// Deletes an image from Firebase Storage using the download URL
  Future<void> deleteImage(String downloadUrl) async {
    try {
      // Get reference from download URL
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw FirebaseStorageException(
        message: 'Failed to delete image: ${e.message}',
        code: e.code,
      );
    }
  }
}

/// Custom exception class for Firebase Storage errors
class FirebaseStorageException implements Exception {
  final String message;
  final String code;

  FirebaseStorageException({required this.message, required this.code});

  @override
  String toString() => 'FirebaseStorageException(code: $code, message: $message)';
}
