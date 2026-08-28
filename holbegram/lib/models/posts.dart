import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String caption;
  String uid;
  String username;
  List likes;
  String postId;
  DateTime datePublished;
  String postUrl;
  String profImage;

  Post({
    required this.caption,
    required this.uid,
    required this.username,
    required this.likes,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
  });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      caption: snapshot['caption'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      likes: snapshot['likes'],
      postId: snapshot['postId'],
      datePublished: snapshot['datePublished'],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caption': caption,
      'uid': uid,
      'username': username,
      'likes': likes,
      'postId': postId,
      'datePublished': datePublished,
      'postUrl': postUrl,
      'profImage': profImage,
    };
  }
}
