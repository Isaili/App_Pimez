import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/purchase_viewmodel.dart';
import 'viewmodels/statistics_viewmodel.dart';
import 'viewmodels/goal_viewmodel.dart';
import 'views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PurchaseViewModel()),
        ChangeNotifierProxyProvider<PurchaseViewModel, StatisticsViewModel>(
          create: (context) => StatisticsViewModel(context.read<PurchaseViewModel>()),
          update: (context, purchaseVM, previous) => 
              previous ?? StatisticsViewModel(purchaseVM),
        ),
        ChangeNotifierProxyProvider<PurchaseViewModel, GoalViewModel>(
          create: (context) => GoalViewModel(context.read<PurchaseViewModel>()),
          update: (context, purchaseVM, previous) => 
              previous ?? GoalViewModel(purchaseVM),
        ),
      ],
      child: MaterialApp(
        title: 'PIMEZ - Acopio de Pimienta',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const HomeView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}