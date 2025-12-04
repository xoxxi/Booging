import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booging2/colors.dart';
import 'package:booging2/pages/my_library_page.dart';
import 'package:booging2/pages/my_friend_page.dart';
import 'package:booging2/pages/group_page.dart';
import 'package:booging2/pages/book_search_page.dart';
import 'package:booging2/pages/login_page.dart';


// 하단 탭을 관리하는 앱의 메인 프레임 위젯
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // 각 탭에 표시될 페이지 위젯 목록
  static const List<Widget> _widgetOptions = <Widget>[
    MyLibraryPage(), // 내 서재 탭
    MyFriendPage(), // 친구 활동 탭
    GroupPage(), // 그룹 읽기
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Firebase에서 로그아웃
    if (mounted) {
      //모든 이전 화면을 지우고 로그인 페이지로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false, // 모든 이전 경로를 제거
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        backgroundColor: titlecolor,
        title: const Text('<<BOOGing>>'),
        actions: [
          //IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body:
      // IndexedStack은 탭 전환 시 각 페이지의 상태를 유지
      IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined), label: '내 서재'),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined), label: '친구 활동'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined), label: '그룹'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context )=> const BookSearchPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}