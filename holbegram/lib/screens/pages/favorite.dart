import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Saved posts for the signed-in user (bookmark on the Feed).
class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 32,
            color: Colors.black,
          ),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('Please log in first'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasError) {
                  return Center(child: Text('Error ${userSnapshot.error}'));
                }
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final saved = List<dynamic>.from(userData['saved'] ?? []);

                if (saved.isEmpty) {
                  return const Center(child: Text('No saved posts yet'));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .snapshots(),
                  builder: (context, postSnapshot) {
                    if (postSnapshot.hasError) {
                      return Center(
                        child: Text('Error ${postSnapshot.error}'),
                      );
                    }
                    if (!postSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final byId = <String, QueryDocumentSnapshot>{};
                    for (final doc in postSnapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final id = (data['postId'] ?? doc.id).toString();
                      byId[id] = doc;
                    }

                    final posts = <QueryDocumentSnapshot>[];
                    for (final id in saved.reversed) {
                      final doc = byId[id.toString()];
                      if (doc != null) {
                        posts.add(doc);
                      }
                    }

                    if (posts.isEmpty) {
                      return const Center(child: Text('No saved posts yet'));
                    }

                    return ListView.separated(
                      itemCount: posts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final data =
                            posts[index].data() as Map<String, dynamic>;
                        final url = (data['postUrl'] ?? '').toString();
                        if (url.isEmpty) {
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                          );
                        }
                        return Image.network(
                          url,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }
                            return Container(
                              height: 240,
                              color: Colors.grey[200],
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
