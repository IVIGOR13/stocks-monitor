import 'package:flutter/material.dart';
import 'package:volga_1/screens/home.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter',
      home: const HomePage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "Poppins",
        scaffoldBackgroundColor: const Color(0xFF191720),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF191720),
            elevation: 0,
            toolbarHeight: 100,
            //centerTitle: false
        ),
      ),
    );
  }
}