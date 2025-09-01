import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/search_page.dart';


class MainPage extends StatefulWidget {
  final VoidCallback onLogout;
  const MainPage({super.key, required this.onLogout});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    SearchPage(),
    ProfilePage(),
    HistoryPage(),
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        // title: const Text('App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _pages[_index],

      // 👉 ใช้ CurvedNavigationBar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent, // สีพื้นหลังด้านบน (ต้องโปร่งใส)
        color: Colors.black,            // สีของแถบ navigation
        buttonBackgroundColor: Colors.black, // สีปุ่มวงกลมตรงกลาง
        animationDuration: const Duration(milliseconds: 300),
        index: _index,
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.search, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.access_time_filled, size: 30, color: Colors.white)
    

        ],
        onTap: (i) {
          setState(() => _index = i);
        },
      ),
    );
  }
}
