import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_app/view/main_shell.dart';
import 'package:smart_app/vm/dashboard_viewmodel.dart';
import 'repositories/dashboard_repository.dart';

void main() {
  runApp(const OwnerApp());
}

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(DashboardRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '점주 관리 앱',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          scaffoldBackgroundColor: const Color(0xffF7F8FA),
        ),
        home: const MainShell(),
      ),
    );
  }
}
