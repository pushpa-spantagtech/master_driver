import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/splash/screens/splash_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String home = '/home';

  static getInitialRoute() => initial;
  static getSplashRoute() => splash;
  static getHomeRoute() => home;

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SignUpScreen()),
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: home, page: () => const DashboardScreen()),
  ];
}