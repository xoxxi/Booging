import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:booging2/colors.dart'; // 사용자 정의 색상
//import 'package:booging2/pages/my_home_page.dart'; // 홈 페이지 import
import 'package:booging2/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BookShelfApp());
}

// 앱의 최상위 위젯입니다. 전체적인 테마와 시작 페이지를 설정합니다.
class BookShelfApp extends StatelessWidget {
  const BookShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: backgroundcolor, // colors.dart의 색상 사용
        fontFamily: 'Pretendard', // (폰트가 프로젝트에 추가되었다고 가정)
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: titlecolor, // colors.dart의 색상 사용
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Pretendard',
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginPage(), // 앱의 첫 화면
    );
  }
}