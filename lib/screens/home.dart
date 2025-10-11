import 'package:flutter/material.dart';

class UpperScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        // color: const Color.fromARGB(66, 255, 255, 255),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    83,
                    0,
                    0,
                    0,
                  ), // Shadow color with opacity
                  spreadRadius: 5, // Expands the shadow
                  blurRadius: 7, // Blurs the shadow
                  offset: Offset(0, 3), // Shifts the shadow down
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset("assets/images/train.jpg", fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FloatingActionButton(child: Icon(Icons.add), onPressed: () {}),
            FloatingActionButton(child: Icon(Icons.list), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [UpperScreen(), BottomScreen()],
      ),
    );
    // throw UnimplementedError();
  }
}
