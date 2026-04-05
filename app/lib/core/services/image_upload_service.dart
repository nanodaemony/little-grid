import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'secure_storage.dart';

class ImageUploadService {
  static const _baseUrl = 'http://8.137.39.155:8080/api/app/upload';

  /// 上传单张图片
  static Future<String> uploadImage(dynamic imageFile, String businessType) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('请先登录');
    }

    final uri = Uri.parse('$_baseUrl/image');
    final request = http.MultipartRequest('POST', uri);

    // 添加认证头
    request.headers['Authorization'] = token;

    // 添加文件
    File file;
    if (imageFile is XFile) {
      file = File((imageFile as XFile).path);
    } else {
      file = imageFile as File;
    }
    final fileBytes = await file.readAsBytes();
    final fileName = file.path.split('/').last;
    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(multipartFile);

    // 添加业务类型参数
    request.fields['businessType'] = businessType;

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      if (responseData['code'] == 200 && responseData['data'] != null) {
        return responseData['data']['url'];
      } else {
        throw Exception(responseData['message'] ?? '上传失败');
      }
    } else if (response.statusCode == 401) {
      throw Exception('登录已过期，请重新登录');
    } else {
      final responseBody = await response.stream.bytesToString();
      throw Exception('上传失败: $responseBody');
    }
  }

  /// 上传多张图片
  static Future<List<String>> uploadImages(List<dynamic> imageFiles, String businessType) async {
    final urls = <String>[];
    for (final file in imageFiles) {
      final url = await uploadImage(file, businessType);
      urls.add(url);
    }
    return urls;
  }
}
