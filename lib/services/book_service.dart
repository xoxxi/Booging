// lib/services/book_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:booging2/models/book.dart';

class BookService {

  // (기존) 책 검색 함수
  Future<List<Book>> fetchBooks({String query = 'best seller'}) async {
    final String apiUrl = "https://www.googleapis.com/books/v1/volumes?q=$query";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  // ⬇️ [추가된 부분] 책 ID로 상세 정보 가져오는 함수
  Future<Book?> fetchBookDetails(String bookId) async {
    // Google Books API는 ID로 책을 조회하는 주소를 따로 제공합니다.
    final String apiUrl = "https://www.googleapis.com/books/v1/volumes/$bookId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // API 응답(JSON)을 Book 객체로 변환
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Failed to load book details');
      }
    } catch (e) {
      print("Book detail fetch error: $e");
      return null;
    }
  }
}