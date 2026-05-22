import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/drama.dart';

class DramaApiService {
  DramaApiService({http.Client? client, this.token}) : _client = client ?? http.Client();

  final http.Client _client;
  final String? token;
  final String _root = ApiConfig.apiRoot;

  Map<String, String> _headers() {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      h['Authorization'] = 'Token $token';
    }
    return h;
  }

  Map<String, String> _query({
    String? search,
    String? category,
  }) {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      params['category'] = category;
    }
    return params;
  }

  List<Drama> _parseList(dynamic body) {
    final results = body is Map<String, dynamic>
        ? body['results'] as List<dynamic>? ?? []
        : body as List<dynamic>;
    return results
        .map((item) => Drama.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final response = await _client.get(
      Uri.parse('$_root/categories/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toList();
  }

  Future<List<Drama>> fetchDramas({
    String? search,
    String? category,
  }) async {
    final uri = Uri.parse('$_root/dramas/').replace(
      queryParameters: _query(search: search, category: category),
    );
    final response = await _client.get(uri, headers: _headers());
    _ensureSuccess(response);
    return _parseList(jsonDecode(response.body));
  }

  Future<List<Drama>> fetchPopular() async {
    final response = await _client.get(
      Uri.parse('$_root/dramas/popular/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    return _parseList(jsonDecode(response.body));
  }

  Future<List<Drama>> fetchRecentlyAdded() async {
    final response = await _client.get(
      Uri.parse('$_root/dramas/recently-added/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    return _parseList(jsonDecode(response.body));
  }

  Future<List<Drama>> fetchFavorites() async {
    final response = await _client.get(
      Uri.parse('$_root/dramas/favorites/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    return _parseList(jsonDecode(response.body));
  }

  Future<List<Drama>> fetchMyList() async {
    final response = await _client.get(
      Uri.parse('$_root/dramas/my-list/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    return _parseList(jsonDecode(response.body));
  }

  Future<Drama> fetchDramaDetail(String id) async {
    final response = await _client.get(
      Uri.parse('$_root/dramas/$id/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    return Drama.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Drama>> fetchYouMayAlsoLike(String id) async {
    final response = await _client.get(
      Uri.parse('$_root/dramas/$id/you-may-also-like/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    return _parseList(jsonDecode(response.body));
  }

  Future<bool> toggleFavorite(String dramaId) async {
    final response = await _client.post(
      Uri.parse('$_root/dramas/$dramaId/favorite/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['is_favorite'] as bool? ?? false;
  }

  Future<bool> toggleMyList(String dramaId) async {
    final response = await _client.post(
      Uri.parse('$_root/dramas/$dramaId/mylist/'),
      headers: _headers(),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['is_in_my_list'] as bool? ?? false;
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }
  }
}
