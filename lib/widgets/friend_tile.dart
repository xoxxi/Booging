import 'package:flutter/material.dart';
import 'package:booging2/models/friend.dart'; // Friend 모델 import

// 친구 목록의 한 칸(타일)을 그리는 위젯입니다.
class FriendTile extends StatelessWidget {
  final Friend friend;
  final bool dark;

  const FriendTile({
    super.key,
    required this.friend,
    this.dark = false, // 기본값은 false(라이트 모드)
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF2E2E2E) : Colors.white;
    final fg = dark ? Colors.white70 : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!dark)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: dark ? Colors.grey[700] : Colors.brown[50],
          foregroundColor: dark ? Colors.white70 : Colors.brown,
          child: const Icon(Icons.person_outline),
        ),
        title: Text(
          friend.name,
          style: TextStyle(color: fg, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          friend.comment,
          style: TextStyle(color: fg.withOpacity(0.8)),
        ),
      ),
    );
  }
}