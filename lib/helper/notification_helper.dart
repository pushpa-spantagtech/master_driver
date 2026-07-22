import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:ride_sharing_user_app/features/chat/controllers/chat_controller.dart';
import 'package:ride_sharing_user_app/features/chat/screens/message_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/html/screens/policy_viewer_screen.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/level_congratulations_dialog_widget.dart';
import 'package:ride_sharing_user_app/features/review/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/payment_received_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/review_this_customer_screen.dart';
import 'package:ride_sharing_user_app/features/ride/screens/ride_request_list_screen.dart';

class NotificationHelper {
  static bool _isHandlingNotification = false;
  static String? _lastHandledRideId;
  static DateTime? _lastHandledAt;
  static Future<void> handleNotificationNavigation(
    RemoteMessage message,
  ) async {
    final String action = message.data['action']?.toString() ?? '';

    final String rideId = message.data['ride_request_id']?.toString() ?? '';

    final DateTime now = DateTime.now();

    final bool recentlyHandled = _lastHandledRideId == rideId &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!).inSeconds < 3;

    if (_isHandlingNotification || recentlyHandled) {
      return;
    }

    _isHandlingNotification = true;
    _lastHandledRideId = rideId;
    _lastHandledAt = now;

    try {
      // Allow GetX/controllers and the first app route to initialize.
      await Future.delayed(const Duration(milliseconds: 700));

      if (action == 'new_ride_request_notification') {
        await _openRideRequestFromData(message.data);
        return;
      }

      await notificationToRoute(message);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isHandlingNotification = false;
    }
  }

  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    AndroidInitializationSettings androidInitialize =
        const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _handleLocalNotificationPayload(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: myBackgroundMessageReceiver,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('onMessage: ${message.data}');

      if (!(Get.find<SplashController>().config!.maintenanceMode != null &&
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
          Get.find<SplashController>().haveOngoingRides()) {
        if (Get.find<SplashController>().pusherConnectionStatus == null ||
            Get.find<SplashController>().pusherConnectionStatus ==
                'Disconnected') {
          if (message.data['action'] == "new_ride_request_notification") {
            final RideController rideController = Get.find<RideController>();

            final AudioPlayer audio = AudioPlayer();
            await audio.play(AssetSource('notification.wav'));

            final bool isOnRideRequestScreen =
                Get.currentRoute.contains('RideRequestScreen');

            if (isOnRideRequestScreen) {
              // The screen is already visible, so refresh it in place.
              await rideController.getPendingRideRequestList(1);
            } else {
              // Open immediately. RideRequestScreen performs the single fetch.
              Get.to(() => const RideRequestScreen());
            }
          } else if (message.data['action'] == "new_message_arrived") {
            Get.find<ChatController>().getConversation(message.data['type'], 1);
          } else if (message.data['action'] == "ride_completed") {
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id'])
                .then((value) {
              if (value.statusCode == 200) {
                Get.find<RideController>()
                    .getFinalFare(message.data['ride_request_id'])
                    .then((value) {
                  if (value.statusCode == 200) {
                    Get.find<RiderMapController>()
                        .setRideCurrentState(RideState.initial);
                    Get.to(() => const PaymentReceivedScreen());
                  }
                });
              }
            });
          } else if (message.data['action'] == "ride_accepted") {
            ///Bid Ride Accepted in this case....
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id'])
                .then((value) {
              if (value.statusCode == 200) {
                Get.find<RiderMapController>()
                    .setRideCurrentState(RideState.accepted);
                Get.find<RideController>().updateRoute(false, notify: true);
                Get.to(() => const MapScreen());
              }
            });
          } else if (message.data['action'] == "coupon_removed" ||
              message.data['action'] == "coupon_applied") {
            Get.find<RideController>()
                .getFinalFare(message.data['ride_request_id']);
          } else if (message.data['action'] == "payment_successful" &&
              message.data['type'] == "ride_request") {
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id'])
                .then((value) {
              if (value.statusCode == 200) {
                if (Get.find<SplashController>().config!.reviewStatus!) {
                  Get.offAll(() => ReviewThisCustomerScreen(
                      tripId: message.data['ride_request_id']));
                } else {
                  Get.offAll(() => const DashboardScreen());
                }
              }
            });
          } else if (message.data['action'] == "payment_successful" &&
              message.data['type'] == "parcel") {
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id'])
                .then((value) {
              if (value.statusCode == 200) {
                Get.find<RideController>().getOngoingParcelList();
                Get.back();
              }
            });
          } else if (message.data['action'] == "ride_cancelled" ||
              message.data['action'] == "ride_started") {
            Get.find<RideController>()
                .getPendingRideRequestList(1)
                .then((value) {
              if (value.statusCode == 200) {
                Get.find<RiderMapController>()
                    .setRideCurrentState(RideState.initial);
                Get.offAll(() => const DashboardScreen());
              }
            });
          } else if (message.data['action'] == "vehicle_approved") {
            Get.find<ProfileController>().getProfileInfo().then((value) {
              if (value.statusCode == 200) {
                Get.find<RiderMapController>()
                    .setRideCurrentState(RideState.initial);
                Get.offAll(() => const DashboardScreen());
              }
            });
          } else if (message.data['action'] == "bid_rejected") {
            Get.offAll(() => const DashboardScreen());
          } else if (message.data['action'] == 'identity_image_approved' ||
              message.data['action'] == 'identity_image_rejected') {
            Get.find<ProfileController>().getProfileInfo();
          } else if (message.data['action'] == 'level_completed') {
            Get.find<ProfileController>().getProfileLevelInfo();
            showDialog(
              context: Get.context!,
              barrierDismissible: false,
              builder: (_) => LevelCongratulationsDialogWidget(
                levelName: message.data['next_level'],
                rewardType: message.data['reward_type'],
                reward: message.data['reward_amount'],
              ),
            );
          } else if (message.data['action'] == "withdraw_rejected" ||
              message.data['action'] == "withdraw_approved") {
            Get.find<ProfileController>().getProfileInfo();
            Get.find<WalletController>().getWithdrawPendingList(1);
          } else if (message.data['action'] == "withdraw_settled") {
            Get.find<ProfileController>().getProfileInfo();
            Get.find<WalletController>().getWithdrawSettledList(1);
          } else if (message.data['action'] == "cash_collected") {
            Get.find<ProfileController>().getProfileInfo();
            Get.find<WalletController>().getPayableHistoryList(1);
          }
        } else {
          if (message.data['action'] == "ride_accepted") {
            ///Bid Ride Accepted in this case....
            Get.find<RideController>()
                .getRideDetails(message.data['ride_request_id'])
                .then((value) {
              if (value.statusCode == 200) {
                Get.find<RiderMapController>()
                    .setRideCurrentState(RideState.accepted);
                Get.find<RideController>().updateRoute(false, notify: true);
                Get.to(() => const MapScreen());
              }
            });
          } else if (message.data['action'] == "vehicle_approved") {
            Get.find<ProfileController>().getProfileInfo().then((value) {
              if (value.statusCode == 200) {
                Get.find<RiderMapController>()
                    .setRideCurrentState(RideState.initial);
                Get.offAll(() => const DashboardScreen());
              }
            });
          } else if (message.data['action'] == "bid_rejected") {
            Get.offAll(() => const DashboardScreen());
          } else if (message.data['action'] == 'identity_image_approved' ||
              message.data['action'] == 'identity_image_rejected') {
            Get.find<ProfileController>().getProfileInfo();
          } else if (message.data['action'] == 'level_completed') {
            Get.find<ProfileController>().getProfileLevelInfo();
            showDialog(
              context: Get.context!,
              barrierDismissible: false,
              builder: (_) => LevelCongratulationsDialogWidget(
                levelName: message.data['next_level'],
                rewardType: message.data['reward_type'],
                reward: message.data['reward_amount'],
              ),
            );
          } else if (message.data['action'] == "withdraw_rejected" ||
              message.data['action'] == "withdraw_approved") {
            Get.find<ProfileController>().getProfileInfo();
            Get.find<WalletController>().getWithdrawPendingList(1);
          } else if (message.data['action'] == "withdraw_settled") {
            Get.find<ProfileController>().getProfileInfo();
            Get.find<WalletController>().getWithdrawSettledList(1);
          } else if (message.data['action'] == "cash_collected") {
            Get.find<ProfileController>().getProfileInfo();
            Get.find<WalletController>().getPayableHistoryList(1);
          }
        }

        if (!(message.data['action'] == "ride_cancelled" ||
            message.data['action'] == "ride_started" ||
            message.data['type'] == 'maintenance_mode_on' ||
            message.data['type'] == 'maintenance_mode_off')) {
          NotificationHelper.showNotification(
              message, flutterLocalNotificationsPlugin, true);
        }
      }

      if (message.data['type'] == 'maintenance_mode_on' ||
          message.data['type'] == 'maintenance_mode_off') {
        Get.find<SplashController>().getConfigData(reload: false);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      customPrint('onOpenApp: ${message.data}');
      await notificationToRoute(message);
    });
  }

  static Future<void> handleInitialNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    // Wait until GetMaterialApp, bindings, and the splash route are mounted.
    await Future.delayed(const Duration(milliseconds: 1400));

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      customPrint('initialNotification: ${initialMessage.data}');
      await handleNotificationNavigation(initialMessage);
      return;
    }

    final NotificationAppLaunchDetails? launchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      await _handleLocalNotificationPayload(
        launchDetails?.notificationResponse?.payload,
      );
    }
  }

  static Future<void> _handleLocalNotificationPayload(
    String? payload,
  ) async {
    if (payload == null || payload.trim().isEmpty) {
      return;
    }

    Map<String, dynamic> data = <String, dynamic>{};

    try {
      final dynamic decoded = jsonDecode(payload);
      if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Compatibility with old notifications that stored only the ride ID.
      data = <String, dynamic>{
        'action': 'new_ride_request_notification',
        'ride_request_id': payload,
        'type': 'ride_request',
      };
    }

    await _openRideRequestFromData(data);
  }

  static Future<void> _openRideRequestFromData(
    Map<String, dynamic> data,
  ) async {
    if (data['action']?.toString() != 'new_ride_request_notification') {
      return;
    }

    // Cold start may need extra time for dependency injection.
    for (int attempt = 0; attempt < 12; attempt++) {
      if (Get.isRegistered<RideController>() &&
          Get.key.currentContext != null) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (!Get.isRegistered<RideController>()) {
      customPrint('RideController is not ready for notification navigation');
      return;
    }

    final RideController rideController = Get.find<RideController>();
    final bool isOnRideRequestScreen =
        Get.currentRoute.contains('RideRequestScreen');

    if (isOnRideRequestScreen) {
      await rideController.getPendingRideRequestList(1);
    } else {
      // Navigate first instead of waiting on the network. The screen fetches
      // the pending list once from initState.
      Get.to(() => const RideRequestScreen());
    }
  }

  static Future<void> showNotification(RemoteMessage message,
      FlutterLocalNotificationsPlugin fln, bool data) async {
    final bool isRideRequest =
        message.data['action'] == 'new_ride_request_notification';

    final String customerName =
        message.data['customer_name']?.toString().trim() ?? '';

    final String pickupAddress =
        message.data['pickup_address']?.toString().trim() ?? '';

    final String destinationAddress =
        message.data['destination_address']?.toString().trim() ?? '';

    final String estimatedFare =
        message.data['estimated_fare']?.toString().trim() ?? '';

    final String estimatedDistance =
        message.data['estimated_distance']?.toString().trim() ?? '';

    final String title = isRideRequest
        ? '🚖 New Ride Request'
        : message.data['title']?.toString() ?? 'Seven Taxi';

    final String body = isRideRequest
        ? (pickupAddress.isNotEmpty
            ? 'Pickup: $pickupAddress'
            : 'Pickup location available')
        : message.data['body']?.toString() ??
            message.data['description']?.toString() ??
            '';
    String? orderID =
        message.data['ride_request_id'] ?? message.data['order_id'];
    String? image = (message.data['image'] != null &&
            message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http')
            ? message.data['image']
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
        : null;

    try {
      await showBigPictureNotificationHiddenLargeIcon(
          title, body, orderID, image, fln);
    } catch (e) {
      await showBigPictureNotificationHiddenLargeIcon(
          title, body, orderID, null, fln);
      customPrint('Failed to show notification: ${e.toString()}');
    }
  }

  static Future<void> showTextNotification(
      String title,
      String body,
      String orderID,
      String action,
      FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hexaride',
      'hexaride',
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: action);
  }

  static Future<void> showBigTextNotification(
      String title,
      String body,
      String orderID,
      String action,
      FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hexaride',
      'hexaride',
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: action);
  }

  // static Future<void> ongoingRideRequestProgress(int count, int i, String? body) async {
  //
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'hexaride', 'hexaride',
  //       channelDescription: 'progress channel description',
  //       channelShowBadge: true,
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       onlyAlertOnce: true,
  //       showProgress: true,
  //       ongoing: true,
  //       color: const Color(0xFF00A08D),
  //       maxProgress: count,
  //       progress: i);
  //   var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  //   flutterLocalNotificationsPlugin.show(0, 'Your ride is ongoing',
  //       body??'Enjoy your ride', platformChannelSpecifics,
  //       payload: 'item x');
  // }
  //

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
    String title,
    String body,
    String? orderID,
    String? image,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    String? largeIconPath;
    String? bigPicturePath;
    BigPictureStyleInformation? bigPictureStyleInformation;
    BigTextStyleInformation? bigTextStyleInformation;

    if (image != null && image.isNotEmpty && !GetPlatform.isWeb) {
      largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
      bigPicturePath = largeIconPath;

      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: body,
        htmlFormatSummaryText: true,
      );
    } else {
      bigTextStyleInformation = BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      );
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hexaride',
      'hexaride',
      priority: Priority.max,
      importance: Importance.max,
      playSound: true,
      largeIcon:
          largeIconPath != null ? FilePathAndroidBitmap(largeIconPath) : null,
      styleInformation: largeIconPath != null
          ? bigPictureStyleInformation
          : bigTextStyleInformation,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final int notificationId = orderID != null && orderID.isNotEmpty
        ? orderID.hashCode & 0x7fffffff
        : DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    await fln.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: orderID ?? '',
    );
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage remoteMessage) async {
  customPrint('onBackground: ${remoteMessage.data}');
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}

@pragma('vm:entry-point')
Future<void> myBackgroundMessageReceiver(NotificationResponse response) async {
  customPrint('onBackgroundClicked: ${response.payload}');
}

Future<void> notificationToRoute(RemoteMessage message) async {
  if (message.data['action'] == "new_message_arrived") {
    Get.find<ChatController>().getConversation(message.data['type'], 1);
    Get.to(() => MessageScreen(
        channelId: message.data['type'],
        tripId: message.data['ride_request_id'],
        userName: message.data['user_name']));
  } else if (message.data['action'] == "new_ride_request_notification") {
    final RideController rideController = Get.find<RideController>();

    final bool isOnRideRequestScreen =
        Get.currentRoute.contains('RideRequestScreen');

    if (isOnRideRequestScreen) {
      await rideController.getPendingRideRequestList(1);
    } else {
      // Open the page immediately. It will make one API call after mounting.
      Get.to(() => const RideRequestScreen());
    }
  } else if (message.data['action'] == "ride_accepted") {
    ///Bid Ride Accepted in this case....
    Get.find<RideController>()
        .getRideDetails(message.data['ride_request_id'])
        .then((value) {
      if (value.statusCode == 200) {
        Get.find<RiderMapController>().setRideCurrentState(RideState.accepted);
        Get.find<RideController>().updateRoute(false, notify: true);
        Get.to(() => const MapScreen());
      }
    });
  } else if (message.data['action'] == "payment_successful" &&
      message.data['type'] == "ride_request") {
    Get.offAll(() => const DashboardScreen());
    Get.find<BottomMenuController>().setTabIndex(3);
  } else if (message.data['action'] == "payment_successful" &&
      message.data['type'] == "parcel") {
    Get.offAll(() => const DashboardScreen());
    Get.find<BottomMenuController>().setTabIndex(3);
  } else if (message.data['action'] == "ride_cancelled" ||
      message.data['action'] == "ride_started") {
    Get.find<RideController>().getPendingRideRequestList(1).then((value) {
      if (value.statusCode == 200) {
        Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
        Get.offAll(() => const DashboardScreen());
      }
    });
  } else if (message.data['action'] == "vehicle_approved") {
    Get.find<ProfileController>().getProfileInfo().then((value) {
      if (value.statusCode == 200) {
        Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
        Get.find<ProfileController>().setProfileTypeIndex(2);
        Get.to(() => const ProfileScreen());
      }
    });
  } else if (message.data['action'] == "withdraw_rejected" ||
      message.data['action'] == "withdraw_approved" ||
      message.data['action'] == "cash_collected" ||
      message.data['action'] == "withdraw_reversed") {
    Get.offAll(() => const DashboardScreen());
    Get.find<BottomMenuController>().setTabIndex(3);
  } else if (message.data['action'] == "withdraw_settled") {
    Get.offAll(() => const DashboardScreen());
    Get.find<BottomMenuController>().setTabIndex(3);
    Get.find<WalletController>().setSelectedHistoryIndex(1, true);
  } else if (message.data['action'] == "bid_rejected") {
    Get.offAll(() => const DashboardScreen());
  } else if (message.data['action'] == "review_submit") {
    Get.to(() => const ReviewScreen());
  } else if (message.data['action'] == 'identity_image_approved' ||
      message.data['action'] == 'identity_image_rejected') {
    Get.find<ProfileController>().getProfileInfo().then((value) {
      Get.to(() => ProfileEditScreen(
          profileInfo: Get.find<ProfileController>().profileInfo!));
    });
  } else if (message.data['action'] == 'level_completed') {
    Get.find<ProfileController>().getProfileLevelInfo();
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (_) => LevelCongratulationsDialogWidget(
        levelName: message.data['next_level'],
        rewardType: message.data['reward_type'],
        reward: message.data['reward_amount'],
      ),
    );
  } else if (message.data['action'] == 'privacy_policy_page_updated') {
    Get.find<SplashController>().getConfigData().then((value) {
      Get.to(() => PolicyViewerScreen(
            isPolicy: true,
            image:
                Get.find<SplashController>().config?.privacyPolicy?.image ?? '',
          ));
    });
  } else if (message.data['action'] == 'legal_page_updated') {
    Get.find<SplashController>().getConfigData().then((value) {
      Get.to(() => PolicyViewerScreen(
          isLegal: true,
          image: Get.find<SplashController>().config?.legal?.image ?? ''));
    });
  } else if (message.data['action'] == 'terms_and_condition_page_updated') {
    Get.find<SplashController>().getConfigData().then((value) {
      Get.to(() => PolicyViewerScreen(
          image:
              Get.find<SplashController>().config?.termsAndConditions?.image ??
                  ''));
    });
  }
}
