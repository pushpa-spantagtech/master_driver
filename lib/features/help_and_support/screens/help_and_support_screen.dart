import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  static const Color _background = Color(0xFFF7F8FA);
  static const Color _card = Colors.white;
  static const Color _text = Color(0xFF1B1D21);
  static const Color _subText = Color(0xFF6F737A);
  static const Color _primary = Color(0xFFE71921);
  static const Color _softPrimary = Color(0xFFFFECEC);
  static const Color _divider = Color(0xFFE8EAED);

  @override
  Widget build(BuildContext context) {
    final config = Get.find<SplashController>().config;
    final String email = config?.businessContactEmail ?? '';
    final String phone = config?.businessContactPhone ?? '';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _background,
        foregroundColor: _text,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'help_and_support'.tr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SupportHero(),
                    const SizedBox(height: 28),
                    const Text(
                      'Contact support',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose how you would like to contact our support team.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: _subText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ContactCard(
                      icon: Icons.mail_outline_rounded,
                      title: 'contact_us_through_email'.tr,
                      value: email,
                      description: 'you_can_send_us_email_through'.tr,
                      note:
                          '${'typically_support_team_send_you_feedback'.tr}${'two_hours'.tr}',
                    ),
                    const SizedBox(height: 14),
                    _ContactCard(
                      icon: Icons.phone_outlined,
                      title: 'contact_us_through_phone'.tr,
                      value: phone,
                      description: 'contact_with_us'.tr,
                      note:
                          '${'talk_with_our'.tr}${'customer_support_executive'.tr}${'at_any_time'.tr}',
                    ),
                  ],
                ),
              ),
            ),
            _BottomActions(email: email, phone: phone),
          ],
        ),
      ),
    );
  }
}

class _SupportHero extends StatelessWidget {
  const _SupportHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: HelpAndSupportScreen._card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Image.asset(
              Images.supportDesk,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'How can we help?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: HelpAndSupportScreen._text,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Our support team is ready to assist you with your questions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: HelpAndSupportScreen._subText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    required this.note,
  });

  final IconData icon;
  final String title;
  final String value;
  final String description;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HelpAndSupportScreen._card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HelpAndSupportScreen._divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: HelpAndSupportScreen._softPrimary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 22,
              color: HelpAndSupportScreen._primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HelpAndSupportScreen._text,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: HelpAndSupportScreen._subText,
                  ),
                ),
                if (value.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: HelpAndSupportScreen._primary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: HelpAndSupportScreen._subText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.email, required this.phone});

  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: HelpAndSupportScreen._card,
        border: Border(
          top: BorderSide(color: HelpAndSupportScreen._divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _launchUrl('sms:$email', true),
              icon: const Icon(Icons.mail_outline_rounded, size: 20),
              label: Text('email'.tr),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                foregroundColor: HelpAndSupportScreen._primary,
                side: const BorderSide(
                  color: HelpAndSupportScreen._primary,
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _launchUrl('tel:$phone', false),
              icon: const Icon(Icons.call_outlined, size: 20),
              label: Text('call'.tr),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: HelpAndSupportScreen._primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final Uri params = Uri(
  scheme: 'mailto',
  path: '',
  query: 'subject=support Feedback&body=',
);

Future<void> _launchUrl(String url, bool isMail) async {
  if (!await launchUrl(Uri.parse(isMail ? params.toString() : url))) {
    throw 'Could not launch $url';
  }
}
