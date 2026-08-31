import 'package:flutter/material.dart';
import '../../utils/posts.dart';

// Feed tab: Holbegram header + the posts list.
class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Holbegram',
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 32,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Image(
              image: const AssetImage('assets/images/logo.webp'),
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_outlined, color: Colors.black),
          ),
        ],
      ),
      body: const Posts(),
    );
  }
}
