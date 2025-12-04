class Book {
  final String id;
  final String title;
  final String coverUrl;
  final List<String> authors;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.authors,
    required this.description
  });


  // API 응답(JSON)을 Book 객체로 변환
  factory Book.fromJson(Map<String, dynamic> json){
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    final List<dynamic> authorsList = volumeInfo['authors'] ?? ['저자 미상'];

    return Book(
        id: json['id'] ?? 'Unknown ID',
        title: volumeInfo['title'] ?? '제목 없음',
        // 표지가 없는 책도 있어서 기본 이미지를 지정
        coverUrl: imageLinks['thumbnail'] ?? 'https://via.placeholder.com/150',
        authors: authorsList.map((e) => e.toString()).toList(),
        description: volumeInfo['description'] ?? '설명 없음',
    );
  }

}