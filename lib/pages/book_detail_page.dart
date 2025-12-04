import 'package:flutter/material.dart';
import 'package:booging2/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// 1. [추가] Firebase Auth 임포트 (사용자 ID를 가져오기 위해)
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;
  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final TextEditingController _newMemoController = TextEditingController();

  // 2. [변경] 컬렉션을 'late'가 아닌 'nullable' (null일 수 있음)로 변경
  CollectionReference? _memosCollection;

  @override
  void initState() {
    super.initState();

    // 3. [변경] 현재 사용자 ID를 가져옴
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 4. [변경] 사용자 ID가 있으면 컬렉션 경로를 'users/{userId}/...'로 설정
      _memosCollection = FirebaseFirestore.instance
          .collection('users')      // 👈 'users' 컬렉션
          .doc(user.uid)            // 👈 현재 로그인한 사용자 ID
          .collection('bookMemos')
          .doc(widget.book.id)
          .collection('memos');
    }
    // 사용자 ID가 없으면(로그아웃 상태) _memosCollection은 null로 유지됩니다.
  }

  @override
  void dispose() {
    _newMemoController.dispose();
    super.dispose();
  }

  // [추가] 에러 스낵바 함수
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _addNewMemo() async {
    // 5. [추가] 컬렉션이 null(로그아웃 상태)이면 저장 안 함
    if (_memosCollection == null) {
      _showErrorSnackBar("로그인이 필요합니다.");
      return;
    }

    final String memoText = _newMemoController.text.trim();
    if (memoText.isEmpty) {
      return;
    }

    try {
      // 6. [변경] _memosCollection! (null이 아님을 확신)
      await _memosCollection!.add({
        'text': memoText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _newMemoController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      print("Failed to add memo: $e");
      _showErrorSnackBar('메모 추가에 실패했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ( ... 기존 책 정보 UI ... )
                  Center(
                    child: Column(
                      children: [
                        Hero( tag: book.id, /* ... */ child: Card(child: Image.network(book.coverUrl, height: 250, fit: BoxFit.cover,),),),
                        const SizedBox(height: 24),
                        Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(book.authors.join(', '), style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),
                  ),

                  const Divider(height: 48, thickness: 1),
                  const Text('책 소개', /* ... */ ),
                  const SizedBox(height: 8),
                  Text(book.description, /* ... */ ),
                  const Divider(height: 48, thickness: 1),

                  const Text(
                    '내 메모',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 7. [변경] _memosCollection을 확인
                  _buildMemoList(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          // 8. [변경] 입력창도 로그인 상태에 따라 달라짐
          _buildMemoInput(),
        ],
      ),
    );
  }

  Widget _buildMemoList() {
    // 9. [변경] 컬렉션이 null이면 '로그인 필요' 메시지 표시
    if (_memosCollection == null) {
      return const Center(
        child: Text('메모를 보려면 로그인이 필요합니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      // 10. [변경] _memosCollection! (null이 아님을 확신)
      stream: _memosCollection!.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('메모를 불러오는 중 오류가 발생했습니다.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('아직 저장된 메모가 없습니다.', style: TextStyle(color: Colors.grey)),
          );
        }

        final memos = snapshot.data!.docs;
        return ListView.builder(
          itemCount: memos.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final memoDoc = memos[index];
            final memoData = memoDoc.data() as Map<String, dynamic>;
            final memoText = memoData['text'];
            final timestamp = memoData['createdAt'] as Timestamp?;

            return _buildMemoTile(memoText, timestamp);
          },
        );
      },
    );
  }

  // 11. [변경 없음] _buildMemoTile (메모 내용, 시간 표시)
  Widget _buildMemoTile(String memoText, Timestamp? timestamp) {
    String formattedTime = '시간 정보 없음';
    if (timestamp != null) {
      formattedTime = DateFormat('yyyy년 MM월 dd일 a hh:mm').format(timestamp.toDate());
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(memoText, style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formattedTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 12. [변경] '새 메모' 입력창
  Widget _buildMemoInput() {
    // 13. [추가] 로그인 상태 확인
    final bool isLoggedIn = _memosCollection != null;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newMemoController,
                decoration: InputDecoration(
                  // 14. [변경] 로그인 상태에 따라 힌트 텍스트 변경
                  hintText: isLoggedIn ? '새 메모 추가...' : '로그인이 필요합니다.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                enabled: isLoggedIn, // 👈 로그인 안 했으면 비활성화
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, color: isLoggedIn ? Colors.brown : Colors.grey),
              iconSize: 40,
              onPressed: isLoggedIn ? _addNewMemo : null, // 👈 로그인 안 했으면 비활성화
            ),
          ],
        ),
      ),
    );
  }
}