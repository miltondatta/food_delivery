import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class LuickApp extends StatelessWidget {
  const LuickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luick',
      debugShowCheckedModeBanner: false,
      theme: buildLuickTheme(),
      routerConfig: appRouter,
    );
  }
}
