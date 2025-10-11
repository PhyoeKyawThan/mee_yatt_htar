import 'package:flutter/material.dart';
import 'package:mee_yatt_htar/screens/add_employee.dart';
import 'package:mee_yatt_htar/screens/employees.dart';
import 'package:mee_yatt_htar/screens/home.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentOpenedIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    AddEmployeeScreen(),
    EmployeeScreen(),
  ];

  void _handleScreen(int index) {
    setState(() {
      _currentOpenedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: IndexedStack(index: _currentOpenedIndex, children: _screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentOpenedIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add New"),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_people),
            label: "Employees",
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        ],
        selectedItemColor: Colors.red,
        // selectedIconTheme: ,
        onTap: _handleScreen,
      ),
    );
  }
}
