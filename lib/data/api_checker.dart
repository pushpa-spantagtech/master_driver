import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'error_response.dart';

class ApiChecker {
  static bool _isLoggingOut = false;

  static void checkApi(Response response) {
    final String message = _getErrorMessage(response);
    final String lowerMessage = message.toLowerCase();

    // If same driver account is logged in on another device, backend can return
    // 401/403 or sometimes "Resource not found" / token related message.
    // In that case do not show popup repeatedly. Logout this device directly.
    if (response.statusCode == 401 ||
        lowerMessage.contains('unauthenticated') ||
        lowerMessage.contains('token has expired') ||
        lowerMessage.contains('token is expired') ||
        lowerMessage.contains('invalid token') ||
        lowerMessage.contains('session expired') ||
        lowerMessage.contains('resource not found')) {
      _forceLogout();
      return;
    }

    if (response.statusCode == 403) {
      if (lowerMessage.contains('token') || lowerMessage.contains('session')) {
        _forceLogout();
        return;
      }

      ErrorResponse errorResponse;
      errorResponse = ErrorResponse.fromJson(response.body);
      if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
        showCustomSnackBar(errorResponse.errors![0].message!);
      } else if (message.isNotEmpty) {
        showCustomSnackBar(message);
      }
    } else {
      if (message.isNotEmpty) {
        showCustomSnackBar(message);
      }
    }
  }

  static String _getErrorMessage(Response response) {
    try {
      if (response.body != null && response.body is Map) {
        if (response.body['message'] != null) {
          return response.body['message'].toString();
        }
      }
    } catch (_) {}

    return response.statusText?.toString() ?? '';
  }

  static void _forceLogout() {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      if (Get.isRegistered<SplashController>()) {
        Get.find<SplashController>().removeSharedData();
      }
    } catch (_) {}

    if (Get.currentRoute != '/SignInScreen') {
      Get.offAll(() => const SignInScreen());
    }

    Future.delayed(const Duration(seconds: 2), () {
      _isLoggingOut = false;
    });
  }
}
