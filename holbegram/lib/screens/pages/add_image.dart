import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../home.dart';
import 'methods/post_storage.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  Uint8List? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  static const Color _red = Color.fromARGB(218, 226, 37, 24);

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    setState(() {
      _image = bytes;
    });
  }

  void _chooseSource() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image_outlined, color: _red),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: _red),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pick(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _post() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String result = await PostStorage().uploadPost(
      _captionController.text,
      user.uid,
      user.username,
      user.photoUrl,
      _image!,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result == 'Ok' ? 'Post published' : result)),
    );

    if (result == 'Ok') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Image',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _post,
            child: const Text(
              'Post',
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 28,
                color: _red,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Add Image',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Choose an image from your gallery or take a one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _chooseSource,
                    child: Container(
                      width: 280,
                      height: 280,
                      color: const Color(0xFFE0E0E0),
                      child: _image != null
                          ? Image.memory(
                              _image!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Image.asset(
                                'assets/images/add_image.png',
                                width: 90,
                                height: 90,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.add_to_photos_outlined,
                                    size: 80,
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
