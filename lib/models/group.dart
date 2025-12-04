// lib/models/group.dart

import 'package:flutter/material.dart';

class Group {
  final String groupName;
  final String currentBookTitle;
  final String currentBookCoverUrl;
  final String currentBookId; // 현재 읽는 책의 ID
  final int memberCount;
  final bool hasNewActivity;

  const Group({
    required this.groupName,
    required this.currentBookTitle,
    required this.currentBookCoverUrl,
    required this.currentBookId,
    required this.memberCount,
    required this.hasNewActivity,

  });
}