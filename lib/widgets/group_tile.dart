import 'package:flutter/material.dart';
import 'package:booging2/models/group.dart';

class GroupTile extends StatelessWidget {
  final Group group;
  const GroupTile({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 표지 이미지
          Image.network(
            group.currentBookCoverUrl,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 120,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.book_outlined,
                      color: Colors.grey[400], size: 40),
                ),
              );
            },
          ),
          // 그룹 정보
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group.hasNewActivity)
                  const Chip(
                    label: Text('NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.redAccent,
                    labelPadding: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.zero,
                  ),
                if (group.hasNewActivity) const SizedBox(height: 8),
                Text(
                  group.groupName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '📖 ${group.currentBookTitle}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 멤버 아바타 (간단한 버전)
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${group.memberCount}명'),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}