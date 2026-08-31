import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Explore tab: search field + staggered grid of Cloudinary post images.
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _query = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('datePublished', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final posts = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final url = (data['postUrl'] ?? '').toString();
                    if (url.isEmpty) {
                      return false;
                    }
                    if (_query.isEmpty) {
                      return true;
                    }
                    final username =
                        (data['username'] ?? '').toString().toLowerCase();
                    final caption =
                        (data['caption'] ?? '').toString().toLowerCase();
                    return username.contains(_query) ||
                        caption.contains(_query);
                  }).toList();

                  if (posts.isEmpty) {
                    return const Center(child: Text('No images found'));
                  }

                  // StaggeredGridView layout (package 0.7: StaggeredGrid).
                  // Pattern from the mockup: one full-width tile, then two squares.
                  return SingleChildScrollView(
                    child: StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      children: List.generate(posts.length, (index) {
                        final data =
                            posts[index].data() as Map<String, dynamic>;
                        final url = data['postUrl'] as String;
                        final isWide = index % 3 == 0;
                        return StaggeredGridTile.count(
                          crossAxisCellCount: isWide ? 2 : 1,
                          mainAxisCellCount: 1,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) {
                                return child;
                              }
                              return Container(color: Colors.grey[200]);
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
