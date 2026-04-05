// app/lib/tools/bookshelf/services/bookshelf_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/secure_storage.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/tag.dart';

class BookshelfApi {
  static const _baseUrl = 'http://8.137.39.155:8080/api/tools/bookshelf';

  static Future<String> _getToken() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('请先登录');
    }
    return token;
  }

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': token,
    };
  }

  // ========== 分类 API ==========

  static Future<List<Category>> getCategories() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/categories'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('获取分类失败: ${response.body}');
    }
  }

  static Future<Category> createCategory(String name, {int? sort}) async {
    final token = await _getToken();
    final body = <String, dynamic>{'name': name};
    if (sort != null) body['sort'] = sort;

    final response = await http.post(
      Uri.parse('$_baseUrl/categories'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Category.fromJson(data['data']);
    } else {
      throw Exception('创建分类失败: ${response.body}');
    }
  }

  static Future<Category> updateCategory(int id, String name, {int? sort}) async {
    final token = await _getToken();
    final body = <String, dynamic>{'name': name};
    if (sort != null) body['sort'] = sort;

    final response = await http.put(
      Uri.parse('$_baseUrl/categories/$id'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Category.fromJson(data['data']);
    } else {
      throw Exception('更新分类失败: ${response.body}');
    }
  }

  static Future<void> deleteCategory(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/categories/$id'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('删除分类失败: ${response.body}');
    }
  }

  // ========== 条目 API ==========

  static Future<List<Item>> getItems({int? categoryId}) async {
    final token = await _getToken();
    final uri = categoryId != null
        ? Uri.parse('$_baseUrl/items?categoryId=$categoryId')
        : Uri.parse('$_baseUrl/items');

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('获取条目失败: ${response.body}');
    }
  }

  static Future<Item> getItem(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/items/$id'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Item.fromJson(data['data']);
    } else {
      throw Exception('获取条目详情失败: ${response.body}');
    }
  }

  static Future<Item> createItem({
    required int categoryId,
    required String title,
    required String coverUrl,
    String? summary,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? finishDate,
    String? author,
    int? rating,
    String? review,
    String? progress,
    bool? isRecommended,
    List<String>? tags,
  }) async {
    final token = await _getToken();
    final body = {
      'categoryId': categoryId,
      'title': title,
      'coverUrl': coverUrl,
    };
    if (summary != null) body['summary'] = summary;
    if (startDate != null) body['startDate'] = startDate.toIso8601String().substring(0, 10);
    if (endDate != null) body['endDate'] = endDate.toIso8601String().substring(0, 10);
    if (finishDate != null) body['finishDate'] = finishDate.toIso8601String().substring(0, 10);
    if (author != null) body['author'] = author;
    if (rating != null) body['rating'] = rating;
    if (review != null) body['review'] = review;
    if (progress != null) body['progress'] = progress;
    if (isRecommended != null) body['isRecommended'] = isRecommended;
    if (tags != null && tags.isNotEmpty) body['tags'] = tags;

    final response = await http.post(
      Uri.parse('$_baseUrl/items'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Item.fromJson(data['data']);
    } else {
      throw Exception('创建条目失败: ${response.body}');
    }
  }

  static Future<Item> updateItem(
    int id, {
    required int categoryId,
    required String title,
    required String coverUrl,
    String? summary,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? finishDate,
    String? author,
    int? rating,
    String? review,
    String? progress,
    bool? isRecommended,
    List<String>? tags,
  }) async {
    final token = await _getToken();
    final body = {
      'categoryId': categoryId,
      'title': title,
      'coverUrl': coverUrl,
    };
    if (summary != null) body['summary'] = summary;
    if (startDate != null) body['startDate'] = startDate.toIso8601String().substring(0, 10);
    if (endDate != null) body['endDate'] = endDate.toIso8601String().substring(0, 10);
    if (finishDate != null) body['finishDate'] = finishDate.toIso8601String().substring(0, 10);
    if (author != null) body['author'] = author;
    if (rating != null) body['rating'] = rating;
    if (review != null) body['review'] = review;
    if (progress != null) body['progress'] = progress;
    if (isRecommended != null) body['isRecommended'] = isRecommended;
    if (tags != null) body['tags'] = tags;

    final response = await http.put(
      Uri.parse('$_baseUrl/items/$id'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Item.fromJson(data['data']);
    } else {
      throw Exception('更新条目失败: ${response.body}');
    }
  }

  static Future<void> deleteItem(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/items/$id'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('删除条目失败: ${response.body}');
    }
  }

  // ========== 标签 API ==========

  static Future<List<Tag>> getTags() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/tags'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((json) => Tag.fromJson(json)).toList();
    } else {
      throw Exception('获取标签失败: ${response.body}');
    }
  }

  static Future<Tag> createTag(String name) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/tags'),
      headers: _headers(token),
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Tag.fromJson(data['data']);
    } else {
      throw Exception('创建标签失败: ${response.body}');
    }
  }
}
