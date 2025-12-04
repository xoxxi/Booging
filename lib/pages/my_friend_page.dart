import 'package:flutter/material.dart';
import 'package:booging2/models/friend.dart';
import 'package:booging2/widgets/friend_tile.dart';

// '친구 활동' 탭의 UI를 담당하는 위젯
class MyFriendPage extends StatefulWidget {
  const MyFriendPage({super.key});

  @override
  State<MyFriendPage> createState() => _MyFriendPageState();
}

class _MyFriendPageState extends State<MyFriendPage> {
  String query = '';
  final List<Friend> myfriend = [
    Friend(name: '공서연', comment: '메롱'),
    Friend(name: '김민희', comment: '흐암'),
    Friend(name: '김아성', comment: '아매워'),
    Friend(name: '남지원', comment: '머라고?'),
    Friend(name: '이서정', comment: "얌미"),
    Friend(name: '허주영', comment: '하움'),
  ];

  @override
  Widget build(BuildContext context) {
    // 검색어에 따라 친구 목록을 필터링
    final filtered = myfriend
        .where(
            (friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: '이름 검색…',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // 필터링된 친구 목록을 보여주는 리스트
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (BuildContext context, int index) {
              final friend = filtered[index];
              return FriendTile(
                friend: friend,
                dark: false, // 다크 모드 여부를 전달
              );
            },
          ),
        )
      ],
    );
  }
}