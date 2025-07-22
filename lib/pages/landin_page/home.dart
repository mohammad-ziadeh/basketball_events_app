import 'package:fiba_3x3/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'landingPage.dart';
import 'package:fiba_3x3/pages/landin_page/socialMediaBar.dart';
import 'package:fiba_3x3/widgets/custom_drawer.dart';

class Home extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const Home({super.key, required this.onToggleTheme});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final GlobalKey<MainPageState> _mainPageKey = GlobalKey<MainPageState>();

  Future<void> _refreshPage() async {
    await _mainPageKey.currentState?.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(onToggleTheme: widget.onToggleTheme),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MainPage(key: _mainPageKey),
              const SizedBox(height: 20),
              SocialMediaBar(),
            ],
          ),
        ),
      ),
      endDrawer: const CustomDrawer(),
    );
  }
}
