import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../methods/auth_methods.dart';
import '../providers/user_provider.dart';
import 'home.dart';

// pick a profile picture (gallery or camera) then continue signup.
class AddPicture extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const AddPicture({
    super.key,
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  State<AddPicture> createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  Uint8List? _image;
  final ImagePicker _picker = ImagePicker();

  static const String _sampleUserIcon =
      'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png';

  void selectImageFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    setState(() {
      _image = bytes;
    });
  }

  void selectImageFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    setState(() {
      _image = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    const red = Color.fromARGB(218, 226, 37, 24);

    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Column(
            children: [
              const SizedBox(height: 28),
              const Text(
                'Holbegram',
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 50,
                ),
              ),
              Image(
                image: const AssetImage('assets/images/logo.webp'),
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.username} Welcome to Holbegram.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose an image from your gallery or take a new one.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ClipOval(
                child: _image != null
                    ? Image.memory(
                        _image!,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _sampleUserIcon,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person_outline,
                            size: 140,
                            color: Colors.black,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    color: red,
                    icon: const Icon(Icons.image_outlined),
                    onPressed: selectImageFromGallery,
                  ),
                  const SizedBox(width: 48),
                  IconButton(
                    iconSize: 40,
                    color: red,
                    icon: const Icon(Icons.photo_camera_outlined),
                    onPressed: selectImageFromCamera,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                width: 140,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(red),
                    elevation: WidgetStateProperty.all(0),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    var email = widget.email;
                    var username = widget.username;
                    var password = widget.password;

                    String result = await AuthMethode().signUpUser(
                      email: email,
                      username: username,
                      password: password,
                      file: _image,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result == 'success' ? 'success' : result,
                        ),
                      ),
                    );
                    if (result == 'success') {
                      try {
                        await Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).refreshUser();
                      } catch (_) {}
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
