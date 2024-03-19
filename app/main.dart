import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:textmint/home.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'welcome.dart';
import 'summarize.dart';
import 'feedback_page.dart';
import 'forget_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('error:$e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login/Register',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/welcome_page1', // Update initial route to welcome page
      routes: {
        '/welcome_page1': (context) =>
            WelcomePage1(), // Add route for WelcomePage1
        // Add routes for other welcome pages
        // Add routes for other welcome pages if you have more
        '/login_page': (context) => LoginPage(),
        '/home_page': (context) => HomePage(),
        '/register_page': (context) => RegisterPage(),
        '/summarize': (context) => Summarize(),
        '/feedback_page': (context) => FeedbackPage(),
        '/forget_password': (context) => ForgetPassword(),
      },
    );
  }
}
