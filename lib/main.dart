import 'package:billin/page/landing_page.dart';
import 'package:billin/split_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:billin/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ytkkkcduwoeksfckyxbi.supabase.co',
    publishableKey: 'sb_publishable_kqD4gvu7gUftjBYNGYUyvw_rVx9_Ldc',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen(
    (data) {
      print('AUTH EVENT: ${data.event}');
      print('ACCESS TOKEN: ${data.session?.accessToken}');
    },
    onError: (error, stackTrace) {
      print('AUTH ERROR: $error');
    },
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
