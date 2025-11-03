import 'package:flutter/material.dart';
import 'package:mee_yatt_htar/helpers/assets.dart';
import 'package:mee_yatt_htar/helpers/network_discovery.dart';
import 'package:mee_yatt_htar/screens/employees.dart';
import 'package:mee_yatt_htar/screens/sync_screen.dart';

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
  final List<Widget> _screens = [EmployeeListScreen(), SyncScreen()];

  void _handleScreen(int index) {
    setState(() {
      _currentOpenedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    NetworkDiscovery.discoverServer(timeoutSeconds: 3);
  }

  @override
  Widget build(BuildContext context) {
    return AppConstants.isMobile || AppConstants.isDesktop
        ? Scaffold(
            appBar: null,
            body: _screens[_currentOpenedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentOpenedIndex,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.upload),
                  label: "Sync",
                ),
              ],
              selectedItemColor: Colors.black,

              // selectedIconTheme: ,
              onTap: _handleScreen,
            ),
          )
        : Scaffold(appBar: null, body: EmployeeListScreen());
  }
}
