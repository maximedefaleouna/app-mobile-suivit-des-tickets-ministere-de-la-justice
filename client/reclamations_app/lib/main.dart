import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/auth_state.dart';
import 'services/auth_service.dart';
import 'providers/auth_cubit.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/citizen/dashboard_screen.dart';
import 'screens/technician/technician_dashboard_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(AuthService())..checkAuthentication(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;
  AuthRouterRefreshNotifier? _refreshNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_router != null) {
      return;
    }

    final authCubit = context.read<AuthCubit>();
    _refreshNotifier = AuthRouterRefreshNotifier(authCubit.stream);

    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _refreshNotifier,
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          name: 'admin_dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'citizen_dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/technician/dashboard',
          name: 'technician_dashboard',
          builder: (context, state) => const TechnicianDashboardScreen(),
        ),
      ],
      redirect: (context, state) {
        final authCubit = context.read<AuthCubit>();
        final isLoggedIn = authCubit.isAuthenticated;
        final userRole = authCubit.userRole;

        final isLoggingIn = state.matchedLocation == '/login';
        final isRegistering = state.matchedLocation == '/register';

        if (!isLoggedIn && !isLoggingIn && !isRegistering) {
          return '/login';
        }

        if (isLoggedIn && (isLoggingIn || isRegistering)) {
          switch (userRole) {
            case 'ADMIN':
              return '/admin/dashboard';
            case 'TECHNICIEN':
              return '/technician/dashboard';
            default:
              return '/dashboard';
          }
        }

        return null;
      },
    );
  }

  @override
  void dispose() {
    _refreshNotifier?.dispose();
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router!,
    );
  }
}

class AuthRouterRefreshNotifier extends ChangeNotifier {
  AuthRouterRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
