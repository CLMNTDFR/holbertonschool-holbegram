import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

// Uploads bytes to Cloudinary and returns the public URL.
class StorageMethods {
  // Put your Cloudinary cloud name + unsigned upload preset here
  final String cloudName = 'djjg7yovj';
  final String cloudinaryPreset = 'holbegram-clem';

  String get cloudinaryUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  Future<String> uploadImageToStorage(
    bool isPost,
    String childName,
    Uint8List file,
  ) async {
    final data = await uploadImageToCloudinary(isPost, childName, file);
    return data['url'] ?? '';
  }

  Future<Map<String, String>> uploadImageToCloudinary(
    bool isPost,
    String childName,
    Uint8List file,
  ) async {
    if (cloudName.isEmpty || cloudinaryPreset.isEmpty) {
      throw Exception(
        'Cloudinary is not set. Open lib/screens/auth/methods/user_storage.dart and replace cloudName + cloudinaryPreset.',
      );
    }

    String uniqueId = const Uuid().v1();
    var uri = Uri.parse(cloudinaryUrl);
    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = cloudinaryPreset;

    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      file,
      filename: '$uniqueId.jpg',
    );
    request.files.add(multipartFile);

    var response = await request.send();
    var body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(body);
      return {
        'url': jsonResponse['secure_url'] ?? '',
        'publicId': jsonResponse['public_id'] ?? uniqueId,
      };
    }
    throw Exception(_cloudinaryError(response.statusCode, body));
  }

  String _cloudinaryError(int status, String body) {
    try {
      var json = jsonDecode(body);
      var message = json['error']?['message'] ?? body;
      return 'Cloudinary ($status): $message';
    } catch (_) {
      return 'Cloudinary ($status): $body';
    }
  }
}
