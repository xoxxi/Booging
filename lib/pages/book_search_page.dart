import 'package:flutter/material.dart';
import 'package:booging2/models/book.dart';
import 'package:booging2/services/book_service.dart';
import 'package:booging2/pages/book_detail_page.dart'; // 검색 결과 클릭 시 상세 페이지로

class BookSearchPage extends StatefulWidget{
  const BookSearchPage({super.key});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final BookService _bookService = BookService();
  Future<List<Book>>? _resultsFuture; // 검색 결과를 담을 Future

  // 1. 검색 실행 함수
  void _search() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        // 2. BookService를 호출해 _resultsFuture를 업데이트
        _resultsFuture = _bookService.fetchBooks(query: _searchController.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('책 검색하기'),
      ),
      body: Column(
        children: [
          // 3. 검색창
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '책 제목, 저자 등으로 검색',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search, // 4. 아이콘 클릭 시 검색
                ),
              ),
              onSubmitted: (value) => _search(), // 5. 엔터(확인) 시 검색
            ),
          ),

          // 6. 검색 결과 영역
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _resultsFuture, // _resultsFuture를 감시
              builder: (context, snapshot) {
                // 7. 검색 전 (아직 _resultsFuture가 null일 때)
                if (_resultsFuture == null) {
                  return const Center(child: Text('검색어를 입력하고 검색 버튼을 누르세요.'));
                }
                // 8. 로딩 중
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 9. 에러 발생
                if (snapshot.hasError) {
                  return const Center(child: Text('검색 중 오류가 발생했습니다.'));
                }
                // 10. 검색 결과 없음
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('검색 결과가 없습니다.'));
                }

                // 11. 검색 성공!
                final books = snapshot.data!;
                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ListTile(
                      leading: Image.network(book.coverUrl, width: 40, fit: BoxFit.cover),
                      title: Text(book.title),
                      onTap: () {
                        // TODO: "내 서재에 추가" 버튼이 있는 페이지로 이동
                        // 지금은 상세 페이지로 바로 이동
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => BookDetailPage(book: book),
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}