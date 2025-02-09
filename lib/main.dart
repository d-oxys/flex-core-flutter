import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'splash_screen.dart';
import 'login_model.dart';
import 'permission_page.dart';
import './workout/workout_list_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/permission': (context) => PermissionPage(),
        '/workout': (context) {
          final loginModel = LoginModel();
          return WorkoutListContainer(loginModel: loginModel);
        },
        '/splash': (context) => SplashScreen(
              loginModel: LoginModel(),
              nextRoute: '/home',
            ),
      },
    );
  }
}
