import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:headlessfluto/headless_fluto.dart';
import 'package:headlessfluto/provider/fluto_logger_provider.dart';
import 'package:headlessfluto/provider/fluto_network_provider.dart';
import 'package:headlessfluto/provider/supabase_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return HeadlessFlutoLoggerProvider();
          },
        ),
        ChangeNotifierProvider(create: (context) {
          return SupabaseProvider();
        }),
        ChangeNotifierProvider(create: (context) {
          return FlutoNetworkProvider();
        }),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
          useMaterial3: true,
        ),
        home: HeadlessFluto(),
      ),
    );
  }
}
