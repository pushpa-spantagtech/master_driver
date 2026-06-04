import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/responsive_helper.dart';
import 'package:ride_sharing_user_app/helper/di_container.dart' as di;
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/localization/messages.dart';
import 'package:ride_sharing_user_app/theme/dark_theme.dart';
import 'package:ride_sharing_user_app/theme/light_theme.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'features/map/controllers/map_controller.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // dark text for status bar
        statusBarColor: Colors.transparent),
  );

  if (ResponsiveHelper.isMobilePhone) {
    HttpOverrides.global = MyHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //firebase crashlytics
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  //
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  Map<String, Map<String, String>> languages = await di.init();

  await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance
      .subscribeToTopic('driver_maintenance_mode_on');
  await FirebaseMessaging.instance
      .subscribeToTopic('driver_maintenance_mode_off');
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp(languages: languages));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;

  const MyApp({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor:
            Get.isDarkMode ? const Color(0xFF053B35) : const Color(0xFF00A08D),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark));
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
    }

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (configController) {
          return (GetPlatform.isWeb && configController.config == null)
              ? const SizedBox()
              : GetMaterialApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: Get.key,
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch
                    },
                  ),
                  theme: themeController.darkTheme ? darkTheme : lightTheme,
                  locale: localizeController.locale,
                  translations: Messages(languages: languages),
                  fallbackLocale: Locale(AppConstants.languages[0].languageCode,
                      AppConstants.languages[0].countryCode),
                  initialRoute: RouteHelper.getSplashRoute(),
                  getPages: RouteHelper.routes,
                  defaultTransition: Transition.fade,
                  transitionDuration: const Duration(milliseconds: 500),
                  builder: (context, child) {
                    return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: TextScaler.noScaling),
                        child: GetBuilder<RideController>(builder: (config) {
                          return Stack(
                            children: [
                              child!,
                              if (config.notSplashRoute) ...[
                                if (!(Get.find<SplashController>()
                                                .config!
                                                .maintenanceMode !=
                                            null &&
                                        Get.find<SplashController>()
                                                .config!
                                                .maintenanceMode!
                                                .maintenanceStatus ==
                                            1 &&
                                        Get.find<SplashController>()
                                                .config!
                                                .maintenanceMode!
                                                .selectedMaintenanceSystem!
                                                .driverApp ==
                                            1) ||
                                    Get.find<SplashController>()
                                        .haveOngoingRides()) ...[
                                  Positioned(
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                              onTap: () async {
                                                Response res = await Get.find<
                                                        RideController>()
                                                    .getRideDetails(
                                                        Get.find<RideController>()
                                                                .rideId ??
                                                            '1',
                                                        fromHomeScreen: true);
                                                if (res.statusCode == 403) {
                                                  Get.find<RiderMapController>()
                                                      .setRideCurrentState(
                                                          RideState.initial);
                                                }
                                                Get.to(() => const MapScreen());
                                              },
                                              onHorizontalDragEnd:
                                                  (DragEndDetails details) {
                                                _onHorizontalDrag(details);
                                                Get.to(() => const MapScreen());
                                              },
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                      width: Dimensions
                                                          .iconSizeExtraLarge,
                                                      child: Image.asset(
                                                        Images.homeToMapIcon,
                                                      )),
                                                  Positioned(
                                                      top: 0,
                                                      bottom: 0,
                                                      left: 5,
                                                      right: 5,
                                                      child: SizedBox(
                                                          width: 15,
                                                          child: Image.asset(
                                                              Images.map,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .shadow)))
                                                ],
                                              )))),
                                ]
                              ]
                            ],
                          );
                        }));
                  });
        });
      });
    });
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0) return;

    if (details.primaryVelocity!.compareTo(0) == -1) {
      debugPrint('dragged from left');
    } else {
      debugPrint('dragged from right');
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
