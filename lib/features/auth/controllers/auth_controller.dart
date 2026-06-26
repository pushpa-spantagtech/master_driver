import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/auth/domain/services/auth_service_interface.dart';
import 'package:ride_sharing_user_app/features/map/controllers/otp_time_count_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/signup_body.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/approve_dialog_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/reset_password_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/verification_screen.dart';
import 'package:ride_sharing_user_app/features/location/screens/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/snackbar_widget.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;

  AuthController({required this.authServiceInterface});

  bool _isLoading = false;
  bool _acceptTerms = false;

  bool get isLoading => _isLoading;

  bool get acceptTerms => _acceptTerms;
  final String _mobileNumber = '';

  String get mobileNumber => _mobileNumber;
  XFile? _pickedProfileFile;

  XFile? get pickedProfileFile => _pickedProfileFile;
  XFile identityImage = XFile('');
  List<XFile> identityImages = [];
  List<MultipartBody> multipartList = [];
  String countryDialCode = '+880';

  void setCountryCode(String code) {
    countryDialCode = code;
    update();
  }

  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController identityNumberController = TextEditingController();

  FocusNode fNameNode = FocusNode();
  FocusNode lNameNode = FocusNode();
  FocusNode phoneNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode addressNode = FocusNode();
  FocusNode identityNumberNode = FocusNode();

  void addImageAndRemoveMultiParseData() {
    multipartList.clear();
    identityImages.clear();
    update();
  }

  void pickImage(bool isBack, bool isProfile) async {
    final ImageSource? source = await Get.bottomSheet<ImageSource>(
      Material(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile == null) return;

    if (isProfile) {
      _pickedProfileFile = pickedFile;
    } else {
      identityImage = pickedFile;
      identityImages.add(identityImage);
      multipartList.add(MultipartBody('identity_images[]', identityImage));
    }

    update();
  }

  void removeImage(int index) {
    identityImages.removeAt(index);
    multipartList.removeAt(index);

    update();
  }

  final List<String> _identityTypeList = [
    'passport',
    'driving_license',
    'nid',
  ];

  List<String> get identityTypeList => _identityTypeList;
  String _identityType = '';

  String get identityType => _identityType;

  void setIdentityType(String setValue) {
    _identityType = setValue;
    update();
  }

  Future<void> login(String countryCode, String phone, String password) async {
    _isLoading = true;
    update();
    Response? response = await authServiceInterface.login(
        phone: countryCode.trim() + phone, password: password);
    if (response!.statusCode == 200) {
      Map map = response.body;
      String token = '';
      token = map['data']['token'];
      setUserToken(token);
      PusherHelper.initilizePusher();
      updateToken().then((value) {
        _navigateLogin(countryCode, phone, password);
      });
      _isLoading = false;
    } else if (response.statusCode == 202) {
      if (response.body['data']['is_phone_verified'] == 0) {
        Get.to(() => VerificationScreen(
          countryCode: countryCode,
          number: phone,
          from: 'login',
        ));
      }
    } else {
      _isLoading = false;
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  bool logging = false;

  Future<void> logOut() async {
    logging = true;
    update();
    Response? response = await authServiceInterface.logOut();
    if (response!.statusCode == 200) {
      Get.find<RideController>().updateRoute(false, notify: true);
      Get.find<ProfileController>().stopLocationRecord();
      logging = false;
      Get.back();
      Get.offAll(() => const SignInScreen());

      PusherHelper().pusherDisconnectPusher();
    } else {
      logging = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> permanentDelete() async {
    logging = true;
    update();
    Response? response = await authServiceInterface.permanentDelete();
    if (response!.statusCode == 200) {
      Get.find<RideController>().updateRoute(false, notify: true);
      Get.find<ProfileController>().stopLocationRecord();
      logging = false;
      Get.back();
      Get.offAll(() => const SignInScreen());
      showCustomSnackBar('successfully_delete_account'.tr, isError: false);
    } else {
      logging = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> register(String code, SignUpBody signUpBody) async {
    _isLoading = true;
    update();
    // ==========================================================
    // AUTH CONTROLLER - REGISTER API DEBUG
    // ==========================================================
    // print('\n==========================================================');
    // print('🚀 AUTH CONTROLLER - REGISTER API DEBUG');
    // print('Class Name        : AuthController');
    // print('Method Name       : register()');
    // print('==========================================================');
    // print('Country Code      : $code');
    // print('Phone Number      : ${signUpBody.phone}');
    // print('First Name        : ${signUpBody.fName}');
    // print('Last Name         : ${signUpBody.lName}');
    // print('Email             : ${signUpBody.email}');
    // print('Address           : ${signUpBody.address}');
    // print('Identity Type     : ${signUpBody.identificationType}');
    // print('Identity Number   : ${signUpBody.identityNumber}');
    // print('Services          : ${signUpBody.services}');
    // print('Device Token      : ${signUpBody.deviceToken}');
    // print('Profile Image     : ${pickedProfileFile?.path}');
    // print('Identity Images   : ${multipartList.length}');
    // print('Request JSON      : ${signUpBody.toJson()}');
    // print('==========================================================\n');

    Response? response = await authServiceInterface.registration(
        signUpBody: signUpBody,
        profileImage: pickedProfileFile,
        identityImage: multipartList);

    // print('Status Code       : ${response?.statusCode}');
    // print('Status Text       : ${response?.statusText}');
    // print('Response Body     : ${response?.body}');
    // print('Response String   : ${response?.bodyString}');

    if (response!.statusCode == 200) {
      // print('✅ Registration successful');
      fNameController.clear();
      lNameController.clear();
      passwordController.clear();
      phoneController.clear();
      confirmPasswordController.clear();
      emailController.clear();
      addressController.clear();
      identityNumberController.clear();
      _pickedProfileFile = null;
      identityImages.clear();
      multipartList.clear();
      _isLoading = false;

      if (Get.find<SplashController>().config?.verification ?? false) {
        Get.to(() => VerificationScreen(
          countryCode: code,
          number: signUpBody.phone?.replaceAll(code, '') ?? '',
          from: 'signup',
        ));
      } else {
        showCustomSnackBar('registration_completed_successfully'.tr,
            isError: false);
        Get.offAll(() => const SignInScreen());
      }
      Get.find<ProfileController>().updateFirstTimeShowBottomSheet(true);
    } else {
      _isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

  _navigateLogin(String code, String phone, String password) {
    if (_isActiveRememberMe) {
      saveUserCredential(code, phone, password);
    } else {
      clearUserCredential();
    }
    Get.find<ProfileController>().getProfileInfo().then((value) {
      if (value.statusCode == 200) {
        if (Get.find<AuthController>().getZoneId() == '') {
          Get.offAll(() => const AccessLocationScreen());
        } else {
          Get.offAll(() => const DashboardScreen());
        }
        PusherHelper().driverTripRequestSubscribe(value.body['data']['id']);
      }
    });
  }

  Future<Response> sendOtp(
      {required String countryCode, required String phone}) async {
    _isLoading = true;
    update();
    Response? response =
    await authServiceInterface.sendOtp(phone: '$countryDialCode$phone');
    if (response!.statusCode == 200) {
      _isLoading = false;
      showCustomSnackBar('otp_sent_successfully'.tr, isError: false);
    } else {
      _isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> otpVerification(String code, String phone, String otp,
      {String password = '', required String from}) async {
    _isLoading = true;
    update();

    String phoneNumber = '$code$phone';

    Response? response =
    await authServiceInterface.verifyOtp(phone: phoneNumber, otp: otp);
    if (response!.statusCode == 200) {
      clearVerificationCode();
      _isLoading = false;
      if (from == 'signup') {
        Get.dialog(
            ApproveDialogWidget(
                icon: Images.waitForVerification,
                description: 'create_account_approve_description'.tr,
                title: 'registration_not_approve_yet'.tr,
                onYesPressed: () {
                  Get.offAll(() => const SignInScreen());
                }),
            barrierDismissible: false);
      } else if (from == 'login') {
        Map map = response.body;
        String token = '';
        token = map['data']['token'];
        setUserToken(token);
        _isLoading = false;
        updateToken().then((value) {
          _navigateLogin(code, phone, password);
        });
      } else {
        Get.to(() => ResetPasswordScreen(phoneNumber: phoneNumber));
      }
    } else {
      _isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<void> forgetPassword(String phone) async {
    _isLoading = true;
    update();
    Response? response = await authServiceInterface.forgetPassword(phone);
    if (response!.statusCode == 200) {
      _isLoading = false;
      snackBarWidget('successfully_sent_otp'.tr, isError: false);
    } else {
      _isLoading = false;
      snackBarWidget('invalid_number'.tr);
    }
    update();
  }

  Future<void> resetPassword(String phone, String password) async {
    _isLoading = true;
    update();
    Response? response =
    await authServiceInterface.resetPassword(phone, password);
    if (response!.statusCode == 200) {
      snackBarWidget('password_change_successfully'.tr, isError: false);
      Get.offAll(() => const SignInScreen());
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> changePassword(String password, String newPassword) async {
    _isLoading = true;
    update();
    Response? response =
    await authServiceInterface.changePassword(password, newPassword);
    if (response!.statusCode == 200) {
      snackBarWidget('password_change_successfully'.tr, isError: false);
      Get.offAll(() => const DashboardScreen());
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  bool updateFcm = false;

  Future<void> updateToken() async {
    updateFcm = true;
    update();
    Response? response = await authServiceInterface.updateToken();
    if (response?.statusCode == 200) {
      updateFcm = false;
    } else {
      updateFcm = false;
      ApiChecker.checkApi(response!);
    }
    update();
  }

  String _verificationCode = '';
  String _otp = '';

  String get otp => _otp;

  String get verificationCode => _verificationCode;

  void updateVerificationCode(String query) {
    _verificationCode = query;
    if (_verificationCode.isNotEmpty) {
      _otp = _verificationCode;
    }
    update();
  }

  void clearVerificationCode() {
    updateVerificationCode('');
    _verificationCode = '';
    update();
  }

  bool _isActiveRememberMe = false;

  bool get isActiveRememberMe => _isActiveRememberMe;

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  void setRememberMe() {
    _isActiveRememberMe = true;
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return authServiceInterface.clearSharedData();
  }

  void saveUserCredential(String code, String number, String password) {
    authServiceInterface.saveUserCredential(code, number, password);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getLoginCountryCode() {
    return authServiceInterface.getLoginCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  bool isNotificationActive() {
    return authServiceInterface.isNotificationActive();
  }

  toggleNotificationSound() {
    authServiceInterface.toggleNotificationSound(!isNotificationActive());
    update();
  }

  Future<bool> clearUserCredential() async {
    return authServiceInterface.clearUserCredentials();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  String getDeviceToken() {
    return authServiceInterface.getDeviceToken();
  }

  Future<void> setUserToken(String token) async {
    authServiceInterface.saveUserToken(token, getZoneId());
  }

  Future<void> updateZoneId(String zoneId) async {
    authServiceInterface.updateZone(zoneId);
  }

  String getZoneId() {
    return authServiceInterface.getZonId();
  }

  void saveRideCreatedTime() {
    authServiceInterface.saveRideCreatedTime(DateTime.now());
  }

  void remainingTime() async {
    String time = await authServiceInterface.remainingTime();
    if (time.isNotEmpty) {
      DateTime oldTime = DateTime.parse(time);
      DateTime newTime = DateTime.now();
      int diff = newTime.difference(oldTime).inSeconds;
      Get.find<OtpTimeCountController>().resumeCountingTime(diff);
    }
  }

  @override
  void onClose() {
    fNameController.dispose();
    lNameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    addressController.dispose();
    identityNumberController.dispose();
    fNameNode.dispose();
    lNameNode.dispose();
    phoneNode.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
    emailNode.dispose();
    addressNode.dispose();
    identityNumberNode.dispose();
    super.onClose();
  }
}
