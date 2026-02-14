import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class CloudneryUploader {
  static const String cloudName = "dszp0g8fr"; // ✅ Your Cloudinary cloud name
  static const String uploadPreset = "place_images"; // ✅ Your upload preset

  Future<String?> uploadFile(XFile file) async {
    try {
      final mimeTypeData = lookupMimeType(file.path)?.split('/');
      final uploadUrl =
          "https://api.cloudinary.com/v1_1/$cloudName/image/upload"; // ✅ use image/upload

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: mimeTypeData != null
                ? MediaType(mimeTypeData[0], mimeTypeData[1])
                : null,   
          ),
        );

      final response = await request.send();
      final result = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(result.body);
        debugPrint("Upload success: ${data['secure_url']}");
        return data['secure_url'];
      } else {
        debugPrint("Upload failed: ${result.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }
}