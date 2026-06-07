import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'state/app_state.dart';
import 'screens/landing_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/owner_setup_screen.dart';
import 'screens/owner_dashboard.dart';
import 'screens/customer_dashboard.dart';
import 'screens/customer_shop_screen.dart';
import 'screens/order_success_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Supabase.initialize(
    url: 'https://lztofouholixewypgeii.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6dG9mb3Vob2xpeGV3eXBnZWlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI0MjcxNTIsImV4cCI6MjA4ODAwMzE1Mn0.Ur8Lp1ppAPDCfvhrPRR8tdo0BsBUHXvZbvDE16Y3xoA',
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const StockifyApp(),
    ),
  );
}

class StockifyApp extends StatelessWidget {
  const StockifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stockify',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      if (state.isCheckingSession) {
        return const Scaffold(
          backgroundColor: Color(0xFF0A0A0F),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text('📦', style: TextStyle(fontSize: 48)),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Color(0xFF6C63FF)),
              ])),
        );
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildView(state),
      );
    });
  }

  Widget _buildView(AppState state) {
    switch (state.view) {
      case AppView.landing:
        return const LandingScreen();
      case AppView.ownerAuth:
        return const AuthScreen(role: 'owner');
      case AppView.customerAuth:
        return const AuthScreen(role: 'customer');
      case AppView.ownerSetup:
        return const OwnerSetupScreen();
      case AppView.ownerDash:
        return const OwnerDashboard();
      case AppView.customerDashboard:
        return const CustomerDashboard();
      case AppView.customerShop:
        return const CustomerShopScreen();
      case AppView.orderSuccess:
        return const OrderSuccessScreen();
      default:
        return const LandingScreen();
    }
  }
}
