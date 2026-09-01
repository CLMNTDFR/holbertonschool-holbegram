import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/pages/methods/post_storage.dart';

// live list of posts from firestore.
class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          var data = snapshot.data!.docs;
          if (data.isEmpty) {
            return const Center(child: Text('No posts yet'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var post = data[index];
              var postData = post.data() as Map<String, dynamic>;
              var likes = postData['likes'] ?? [];
              var postId = postData['postId'] ?? post.id;
              var isSaved = user?.saved.contains(postId) ?? false;
              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsetsGeometry.lerp(
                    const EdgeInsets.all(8),
                    const EdgeInsets.all(8),
                    10,
                  ),
                  height: 540,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: (postData['profImage'] != null &&
                                        postData['profImage']
                                            .toString()
                                            .isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          postData['profImage'],
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (postData['profImage'] == null ||
                                      postData['profImage'].toString().isEmpty)
                                  ? const Icon(Icons.person, size: 24)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              postData['username'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () async {
                                await PostStorage().deletePost(
                                  postData['postId'] ?? post.id,
                                  postData['publicId'] ?? '',
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Post Deleted'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Text(postData['caption'] ?? ''),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: (postData['postUrl'] != null &&
                                  postData['postUrl'].toString().isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(postData['postUrl']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.send_outlined),
                              onPressed: () {},
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                              ),
                              onPressed: () async {
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please log in first'),
                                    ),
                                  );
                                  return;
                                }
                                await PostStorage().savePost(user.uid, postId);
                                if (!context.mounted) {
                                  return;
                                }
                                await Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).refreshUser();
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${likes is List ? likes.length : 0} Liked',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
