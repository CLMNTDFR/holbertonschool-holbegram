import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../providers/user_provider.dart';

// home shell: bottom nav + the five main pages.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<UserProvider>(context, listen: false).refreshUser();
      } catch (_) {
        // no firestore profile yet, feed still works
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const BottomNav();
  }
}
