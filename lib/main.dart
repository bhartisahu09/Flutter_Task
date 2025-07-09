import 'package:flutter/material.dart';
import 'package:flutter_task/screens/product_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter API Calling',
      home: ProductListScreen(),
    );
  }
}
