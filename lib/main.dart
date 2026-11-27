import 'package:billin/beranda/beranda_page.dart';
import 'package:billin/developer_setting.dart';
import 'package:billin/hasil_scan/hasil_scan.dart';
import 'package:billin/model/receipt.dart';
import 'package:billin/service/receipt_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:billin/auth/login_screen.dart';

Future<void> main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await ReceiptService.loadSavedBaseUrl();
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
