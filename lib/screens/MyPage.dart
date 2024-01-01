import 'package:flutter/material.dart';
import 'BooksScreen.dart';
import 'ConceptScreen.dart';

class MyPage extends StatefulWidget {
  @override
  const MyPage({super.key});
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<MyPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BooksScreen(),
    const ConceptScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Concepts',
          ),
        ],
        selectedItemColor: Colors.blue, // Set the color for selected item icon and label
        unselectedItemColor: Colors.black45, // Set the color for unselected item icon and label
        selectedLabelStyle: const TextStyle(color: Colors.blue), // Set the color for selected item label
        unselectedLabelStyle: const TextStyle(color: Colors.black45), // Set the color for unselected item label
      ),
    );
  }
}