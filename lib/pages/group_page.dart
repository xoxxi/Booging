// lib/pages/group_page.dart

import 'package:flutter/material.dart';
import 'package:booging2/models/group.dart';
import 'package:booging2/widgets/group_tile.dart';
import 'package:booging2/pages/group_detail_page.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final List<Group> mygroup = [
    const Group(
      groupName: 'SF 소설 탐험대 🚀',
      currentBookTitle: '듄 (Dune)',
      currentBookCoverUrl: 'https://books.google.com/books/content?id=z56eDwAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api',
      currentBookId: 'z56eDwAAQBAJ',
      memberCount: 5,
      hasNewActivity: true,
    ),
    const Group(
      groupName: '주말 독서 모임 📚',
      currentBookTitle: '파친코 1',
      currentBookCoverUrl: 'https://books.google.com/books/content?id=N8lJEAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api',
      currentBookId: 'N8lJEAAAQBAJ',
      memberCount: 8,
      hasNewActivity: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "내 그룹",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.add_circle_outline))
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mygroup.length,
        itemBuilder: (BuildContext context, int index) {
          final g = mygroup[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailPage(group: g),
                ),
              );
            },
            child: GroupTile(group: g),
          );
        },
      ),
    );
  }
}