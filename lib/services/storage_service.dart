import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload Meditation
  Future<String> uploadMeditation(File file, String fileName) async {
    try {
      Reference ref = _storage.ref().child('meditations/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw "Error uploading meditation: $e";
    }
  }

  // Get Meditation List (URLs)
  Future<List<String>> getMeditationList() async {
    try {
      ListResult result = await _storage.ref().child('meditations').listAll();
      List<String> urls = [];
      for (var ref in result.items) {
        String url = await ref.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw "Error fetching meditation list: $e";
    }
  }

  // Get Download URL for a specific path
  Future<String> getDownloadURL(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      throw "Error getting download URL: $e";
    }
  }
}
