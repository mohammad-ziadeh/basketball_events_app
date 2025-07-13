import 'package:fiba_3x3/pages/ball_info/ball.dart';
import 'package:fiba_3x3/pages/news/article_news.dart';
import 'package:fiba_3x3/pages/notifications/notifications_screen.dart';
import 'package:fiba_3x3/pages/teams/team_list_page.dart';
import 'package:fiba_3x3/splashScreen.dart';
import 'package:fiba_3x3/widgets/smoothScroll.dart';
import 'package:flutter/material.dart';
import 'pages/landin_page/home.dart';
import 'pages/profile/profile.dart';
import 'pages/search.dart/search_event.dart';
import 'pages/search.dart/search_player.dart';
import 'pages/rules/rules.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIBA 3X3',
      scrollBehavior: MyCustomScrollBehavior(),
      // ----- {{ Light Theme }} ----- //
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Color.fromARGB(255, 56, 56, 56),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        primaryIconTheme: const IconThemeData(color: Colors.black),
        scaffoldBackgroundColor: Colors.white,

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, 
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // ----- {{ End Light Theme }} ----- //

      // ----- {{ Dark Theme }} ----- //
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.black,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        primaryIconTheme: const IconThemeData(color: Colors.white),
        cardColor: Colors.white,

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, 
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // ----- {{ End Dark Theme }} ----- //
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(onToggleTheme: _toggleTheme),

      routes: {
        '/home': (context) => Home(onToggleTheme: _toggleTheme),
        '/profile': (context) => ProfilePage(onToggleTheme: _toggleTheme),
        '/ball-info':
            (context) => Official3x3BallPage(onToggleTheme: _toggleTheme),
        '/rules': (context) => RulesPage(onToggleTheme: _toggleTheme),
        '/news': (context) => BasketballNewsPage(onToggleTheme: _toggleTheme),
        '/team': (context) => TeamListPage(onToggleTheme: _toggleTheme),
        '/search-event': (context) => SearchEvent(onToggleTheme: _toggleTheme),
        '/notifications': (context) => NotificationsScreen(),
        '/search-player':
            (context) => SearchPlayer(onToggleTheme: _toggleTheme),
      },
    );
  }
}
