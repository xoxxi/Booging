import 'package:flutter/material.dart';
import 'package:booging2/models/book.dart'; // 1. Book 모델 import
import 'package:booging2/services/book_service.dart'; // 2. BookService import
import 'package:booging2/pages/book_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// '내 서재' 탭의 UI를 담당하는 위젯입니다.
class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['모든 책', '읽는 중', '읽은 책'];

  late Future<List<Book>> _booksFuture;

  String? _userName;

  @override
  void initState() {
    super.initState();
    // BookService 인스턴스를 만들고 fetchBooks()를 호출
    // 이 _booksFuture 변수를 아래 FutureBuilder가 사용합니다.
    _booksFuture = BookService().fetchBooks(query: 'best seller');
    _loadUserName();
  }
  void _loadUserName() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        // 5. [핵심] 회원가입 때 저장한 displayName을 가져옴
        _userName = user.displayName;
      });
    }
  }


  Widget build(BuildContext context) {
    return Column(
      children: [
        // (기존 MyLibraryPage의 build 메서드 내용과 동일)
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              // 7. [핵심] _userName이 있으면 표시, 없으면 '방문자' 표시
              "${_userName ?? '방문자'}님, \n오늘은 어떤 책을 읽으시나요?",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
            elevation: 2, //디자인의 깊이감과 입체감
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5938165%3Fversion%3D20220104',
                        height: 100,
                        width: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(height: 100, width: 70, color: Colors.grey[200], child: const Center(child: Icon(Icons.book_outlined, color: Colors.grey)));
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded( //밑에 Align이랑 Linear 의 성격 때문에 Expanded
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("파친코 1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text("이민진", style: TextStyle(fontSize: 15, color: Colors.grey)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: 0.7, borderRadius: BorderRadius.circular(10)),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('이어서 읽기', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                )
            )
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child:
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                return ChoiceChip(
                  label: Text(_filters[index]),
                  selected: _selectedFilterIndex == index,
                  onSelected: (selected) {
                    setState(() { _selectedFilterIndex = selected ? index : _selectedFilterIndex; });
                  },
                  selectedColor: Colors.brown[100],
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(side: BorderSide(color: Colors.black12)),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
            ),
          ),
        ),
        Expanded(
          child:
            FutureBuilder<List<Book>>(
                future: _booksFuture,
                builder: (context, snapshot) {
                  // [로딩 중] 상태일 때
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // [에러 발생] 상태일 때
                  if (snapshot.hasError) {
                    return Center(child: Text('오류 발생: ${snapshot.error}'));
                  }
                  // [성공] 데이터를 성공적으로 받아왔을 때
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('검색된 책이 없습니다.'));
                  }
                  // snapshot.data에 실제 책 목록(List<Book>)이 들어있음
                  final books = snapshot.data!;
                  
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return GestureDetector(
                        onTap: (){
                          Navigator.push (
                            context,
                            MaterialPageRoute(builder:(BuildContext context) => BookDetailPage(book: book), ),
                          );
                        },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children : [
                          Expanded(child: Card(
                              elevation : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)
                              ),
                              clipBehavior: Clip.antiAlias,
                              child : Image.network(
                                book.coverUrl,
                                fit:BoxFit.cover,
                                width : double.infinity,
                                errorBuilder: (context, error, stackTrace){
                                  return Container(
                                    color:  Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.book_outlined, color: Colors.grey, size: 40)
                                    ),
                                  );
                                },
                              ),
                            )
                          ),
                        ]
                      ),
                      );
                    },
                    
                  );
                }

            )
        )
      ],
    );
  }
}