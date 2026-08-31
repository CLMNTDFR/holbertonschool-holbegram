import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../auth/methods/user_storage.dart';

// create / delete posts in Firestore (image goes to Cloudinary first).
class PostStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String caption,
    String uid,
    String username,
    String profImage,
    Uint8List image,
  ) async {
    try {
      Map<String, String> photoData =
          await StorageMethods().uploadImageToCloudinary(
        true,
        'posts',
        image,
      );
      String postUrl = photoData['url'] ?? '';
      String publicId = photoData['publicId'] ?? '';
      String postId = const Uuid().v1();

      await _firestore.collection('posts').doc(postId).set({
        'caption': caption,
        'uid': uid,
        'username': username,
        'likes': [],
        'postId': postId,
        'publicId': publicId,
        'datePublished': DateTime.now(),
        'postUrl': postUrl,
        'profImage': profImage,
      });

      await _firestore.collection('users').doc(uid).update({
        'posts': FieldValue.arrayUnion([postId]),
      });

      return 'Ok';
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> deletePost(String postId, String publicId) async {
    await _firestore.collection('posts').doc(postId).delete();
    // Cloudinary destroy needs the API secret, so we only drop the Firestore doc
    if (publicId.isEmpty) {
      return;
    }
  }
}
