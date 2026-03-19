import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/purchase_viewmodel.dart';
import 'viewmodels/statistics_viewmodel.dart';
import 'viewmodels/goal_viewmodel.dart';
import 'views/home_view.dart';
import 'views/purchase_form_view.dart';
import 'views/purchases_list_view.dart';
import 'views/statistics_view.dart';
import 'views/admin_view.dart';

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
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeView(),
          '/purchase-form': (context) => const PurchaseFormView(),
          '/purchases-list': (context) => const PurchasesListView(),
          '/statistics': (context) => const StatisticsView(),
          '/admin': (context) => const AdminView(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/purchase-form' && settings.arguments != null) {
            return MaterialPageRoute(
              builder: (context) => PurchaseFormView(
                purchase: settings.arguments as Purchase?,
              ),
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}