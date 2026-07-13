import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/screens/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/screens/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _splashSnackBarGuardTimer;

  bool _showOfflineScreen = false;
  bool _isChecking = false;
  bool _routeStarted = false;

  @override
  void initState() {
    super.initState();

    Get.find<SplashController>().initSharedData();
    Get.find<AuthController>().remainingTime();

    // Hide API popups only while this splash screen is active.
    _startSplashSnackBarGuard();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearSplashSnackBars();
      _startApplication();
    });
  }

  void _startSplashSnackBarGuard() {
    _splashSnackBarGuardTimer?.cancel();

    _splashSnackBarGuardTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (mounted) {
          _clearSplashSnackBars();
        }
      },
    );
  }

  void _stopSplashSnackBarGuard() {
    _splashSnackBarGuardTimer?.cancel();
    _splashSnackBarGuardTimer = null;
    _clearSplashSnackBars();
  }

  void _clearSplashSnackBars() {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..removeCurrentSnackBar();

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  void _openScreen(Widget screen) {
    // Stop suppression before entering the app.
    // API popups will work normally on all other screens.
    _stopSplashSnackBarGuard();
    Get.offAll(() => screen);
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('seventaxi.in')
          .timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _startApplication() async {
    if (_isChecking || _routeStarted || !mounted) return;

    setState(() {
      _isChecking = true;
    });

    final bool connected = await _hasInternetConnection();

    if (!mounted) return;

    if (!connected) {
      _clearSplashSnackBars();

      setState(() {
        _showOfflineScreen = true;
        _isChecking = false;
      });

      return;
    }

    setState(() {
      _showOfflineScreen = false;
      _isChecking = true;
    });

    await _route();
  }

  Future<void> _route() async {
    if (_routeStarted || !mounted) return;

    _routeStarted = true;

    try {
      // ApiChecker and SplashController can remain in their original form.
      // Any popup produced during this call is hidden only by this screen.
      final bool isSuccess = await Get.find<SplashController>()
          .getConfigData(reload: false)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => false,
          );

      if (!mounted) return;

      if (!isSuccess) {
        _routeStarted = false;
        _clearSplashSnackBars();

        setState(() {
          _showOfflineScreen = true;
          _isChecking = false;
        });

        return;
      }

      // Load cancellation reasons only after internet/config is available.
      // Ride cancellation functionality remains unchanged.
      unawaited(_loadCancellationReasonsSafely());

      final AuthController authController = Get.find<AuthController>();

      if (authController.getUserToken().isNotEmpty) {
        PusherHelper.initilizePusher();
      }

      if (authController.getZoneId() == '') {
        _openScreen(const AccessLocationScreen());
        return;
      }

      authController.updateToken();

      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      if (authController.isLoggedIn()) {
        final profileResponse =
            await Get.find<ProfileController>().getProfileInfo();

        if (!mounted) return;

        if (profileResponse.statusCode == 200) {
          try {
            await Get.find<LocationController>().getCurrentLocation();
          } catch (error) {
            debugPrint('Location error: $error');
          }

          final dynamic data = profileResponse.body?['data'];
          final String? driverId = data is Map ? data['id']?.toString() : null;

          if (driverId != null && driverId.isNotEmpty) {
            PusherHelper().driverTripRequestSubscribe(driverId);
          }

          final rideResponse =
              await Get.find<RideController>().getCurrentRideStatus(
            fromRefresh: true,
          );

          if (!mounted) return;

          // getCurrentRideStatus handles navigation when an active ride exists.
          // Open dashboard only when there is no active ride.
          if (rideResponse.statusCode != 200) {
            _openScreen(const DashboardScreen());
          } else {
            // The ride controller may already have navigated.
            // Stop splash-only popup suppression after startup finishes.
            _stopSplashSnackBarGuard();
          }
        } else {
          _openScreen(const SignInScreen());
        }
      } else {
        final config = Get.find<SplashController>().config;
        final maintenanceMode = config?.maintenanceMode;

        if (maintenanceMode?.maintenanceStatus == 1 &&
            maintenanceMode?.selectedMaintenanceSystem?.driverApp == 1) {
          _openScreen(const MaintenanceScreen());
        } else {
          _openScreen(const SignInScreen());
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Splash route error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _routeStarted = false;
      _clearSplashSnackBars();

      setState(() {
        _showOfflineScreen = true;
        _isChecking = false;
      });
    }
  }

  Future<void> _loadCancellationReasonsSafely() async {
    try {
      await Get.find<TripController>()
          .getOngoingAndAcceptedCancellationCauseList();
    } catch (error) {
      debugPrint('Cancellation reason loading error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _showOfflineScreen
          ? _buildOfflineScreen(context)
          : _buildSplashContent(context),
    );
  }

  Widget _buildSplashContent(BuildContext context) {
    return Center(
      child: Image.asset(
        Images.splashLogo,
        height: MediaQuery.of(context).size.height * 0.08,
      ),
    );
  }

  Widget _buildOfflineScreen(BuildContext context) {
    const Color brandRed = Color(0xFFE71921);
    const Color ink = Color(0xFF121A2C);
    const Color muted = Color(0xFF6F7787);
    const Color softRed = Color(0xFFFFECEE);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 52,
              ),
              child: Center(
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: const BorderSide(
                      color: Color(0xFFF0F1F4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: softRed,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: brandRed,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No internet connection',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ink,
                            fontSize: 22,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Please turn on Wi-Fi or mobile data, then tap the button below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: _isChecking ? null : _startApplication,
                            style: FilledButton.styleFrom(
                              backgroundColor: brandRed,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFFFA6AA),
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: _isChecking
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.3,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh_rounded,
                                    size: 22,
                                  ),
                            label: Text(
                              _isChecking ? 'Checking...' : 'Try again',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _splashSnackBarGuardTimer?.cancel();
    super.dispose();
  }
}
