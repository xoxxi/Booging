// lib/pages/group_detail_page.dart

import 'package:flutter/material.dart';
import 'package:booging2/models/group.dart';
import 'package:booging2/models/book.dart';
import 'package:booging2/services/book_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDetailPage extends StatefulWidget {
  final Group group;
  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final TextEditingController _newMemoController = TextEditingController();
  CollectionReference? _memosCollection;

  // 현재 그룹이 읽는 책 데이터를 담을 Future
  late Future<Book?> _currentBookFuture;

  @override
  void initState() {
    super.initState();

    // BookService로 현재 그룹이 읽는 책 정보를 불러옴
    _currentBookFuture = BookService().fetchBookDetails(widget.group.currentBookId);

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _memosCollection = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.groupName)
          .collection('memos');
    }
  }

  @override
  void dispose() {
    _newMemoController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _addNewMemo() async {
    if (_memosCollection == null) {
      _showErrorSnackBar("로그인이 필요합니다.");
      return;
    }

    final String memoText = _newMemoController.text.trim();
    if (memoText.isEmpty) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar("로그인이 필요합니다.");
      return;
    }

    try {
      await _memosCollection!.add({
        'text': memoText,
        'createdAt': FieldValue.serverTimestamp(),
        'authorName': user.displayName ?? '익명',
        'authorId': user.uid,
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
    final group = widget.group;

    return Scaffold(
      appBar: AppBar(
        title: Text('${group.groupName} - 현재 읽는 책'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FutureBuilder로 책 데이터를 불러와서 UI를 그림
                  FutureBuilder<Book?>(
                    future: _currentBookFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('책 정보를 불러오지 못했습니다: ${snapshot.error}'));
                      } else if (snapshot.hasData && snapshot.data != null) {
                        final book = snapshot.data!;
                        //  BookDetailPage의 책 정보 UI를 그대로 사용
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(book.coverUrl, height: 250, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    book.title,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book.authors.join(', '),
                                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 48, thickness: 1),
                            const Text(
                              '책 소개',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // 6. [수정] Book 모델의 description 표시
                            Text(
                              book.description,
                              style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
                            ),
                          ],
                        );
                      } else {
                        return const Center(child: Text('현재 읽는 책 정보를 찾을 수 없습니다.'));
                      }
                    },
                  ),

                  const Divider(height: 48, thickness: 1),

                  const Text(
                    '그룹 메모',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildMemoList(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          _buildMemoInput(),
        ],
      ),
    );
  }

  // (이하 함수들은 모두 복사해서 붙여넣으세요)

  Widget _buildMemoList() {
    if (_memosCollection == null) {
      return const Center(
        child: Text('그룹 메모를 보려면 로그인이 필요합니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
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
            final authorName = memoData['authorName'] ?? '익명';

            return _buildMemoTile(memoText, timestamp, authorName);
          },
        );
      },
    );
  }

  Widget _buildMemoTile(String memoText, Timestamp? timestamp, String authorName) {
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
            Text(
              authorName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 8),

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

  Widget _buildMemoInput() {
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
                  hintText: isLoggedIn ? '그룹에 새 메모 추가...' : '로그인이 필요합니다.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                enabled: isLoggedIn,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, color: isLoggedIn ? Colors.brown : Colors.grey),
              iconSize: 40,
              onPressed: isLoggedIn ? _addNewMemo : null,
            ),
          ],
        ),
      ),
    );
  }
}