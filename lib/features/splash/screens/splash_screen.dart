import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/screens/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/screens/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();
    if (!GetPlatform.isIOS) {
      _checkConnectivity();
    }

    Get.find<SplashController>().initSharedData();
    Get.find<TripController>().getOngoingAndAcceptedCancellationCauseList();
    Get.find<AuthController>().remainingTime();
    _route();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  void _checkConnectivity() {
    bool isFirst = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);
      if (!mounted) return;
      if ((isFirst && !isConnected) || !isFirst && context.mounted) {
        ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ));

        if (isConnected) {
          _route();
        }
      }
      isFirst = false;
    });
  }

  void _route() async {
    bool isSuccess = await Get.find<SplashController>().getConfigData();
    if (isSuccess) {
      if (Get.find<AuthController>().getUserToken().isNotEmpty) {
        PusherHelper.initilizePusher();
      }
      if (Get.find<AuthController>().getZoneId() == '') {
        Get.offAll(() => const AccessLocationScreen());
      } else {
        Get.find<AuthController>().updateToken();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (Get.find<AuthController>().isLoggedIn()) {
            Get.find<ProfileController>().getProfileInfo().then((value) {
              if (value.statusCode == 200) {
                Get.find<LocationController>()
                    .getCurrentLocation()
                    .then((value) {
                  Get.offAll(() => const DashboardScreen());
                });
                PusherHelper()
                    .driverTripRequestSubscribe(value.body['data']['id']);
              }
            });
          } else {
            if (Get.find<SplashController>().config!.maintenanceMode != null &&
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
                    1) {
              Get.offAll(() => const MaintenanceScreen());
            } else {
              Get.offAll(() => const SignInScreen());
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
        toolbarHeight: 14,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Image.asset(Images.splashLogo,
            height: MediaQuery.of(context).size.height * 0.08),
      ),
    );
  }
}
