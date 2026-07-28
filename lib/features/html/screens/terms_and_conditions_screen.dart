import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  static const List<_TermsSection> _sections = [
    _TermsSection(
      title: '1. Acceptance of Terms',
      description:
          'By creating a SevenTaxi driver account or using the application, you agree to follow these Terms and Conditions and all applicable laws.',
    ),
    _TermsSection(
      title: '2. Driver Eligibility',
      bullets: [
        'You must be at least 18 years old.',
        'You must hold a valid driving licence.',
        'You must provide accurate and current information.',
        'Your vehicle documents and insurance must remain valid.',
      ],
    ),
    _TermsSection(
      title: '3. Account Responsibility',
      bullets: [
        'Keep your password and OTP secure.',
        'Do not share your account with another person.',
        'You are responsible for all activity performed using your account.',
      ],
    ),
    _TermsSection(
      title: '4. Driver Responsibilities',
      bullets: [
        'Arrive at the pickup location on time.',
        'Drive safely and follow all traffic laws.',
        'Treat customers politely and respectfully.',
        'Keep your vehicle clean, safe and roadworthy.',
        'Do not drive under the influence of alcohol or drugs.',
      ],
    ),
    _TermsSection(
      title: '5. Fares and Payments',
      description:
          'Trip fares are calculated through the SevenTaxi platform. Applicable commissions, service charges and taxes may be deducted according to company policy. Drivers must not request unauthorised additional payments from customers.',
    ),
    _TermsSection(
      title: '6. Cancellations',
      description:
          'Drivers should avoid unnecessary cancellations. Repeated cancellations, misuse or failure to complete accepted trips may lead to warnings, temporary suspension or account termination.',
    ),
    _TermsSection(
      title: '7. Prohibited Activities',
      bullets: [
        'Providing false or misleading information.',
        'Fraud or misuse of the application.',
        'Harassment, discrimination or unsafe behaviour.',
        'Using another person’s account or documents.',
      ],
    ),
    _TermsSection(
      title: '8. Suspension or Termination',
      description:
          'SevenTaxi may suspend or terminate an account that violates these terms, creates a safety risk, misuses the platform or breaks applicable law.',
    ),
    _TermsSection(
      title: '9. Privacy',
      description:
          'Your personal information is collected and used according to the SevenTaxi Privacy Policy and applicable data-protection requirements.',
    ),
    _TermsSection(
      title: '10. Limitation of Liability',
      description:
          'SevenTaxi provides a technology platform that connects drivers and customers. SevenTaxi is not responsible for losses caused by circumstances outside its reasonable control.',
    ),
    _TermsSection(
      title: '11. Changes to These Terms',
      description:
          'SevenTaxi may update these Terms and Conditions when required. Continued use of the application means you accept the revised terms.',
    ),
    _TermsSection(
      title: '12. Contact Us',
      description:
          'For questions or support, contact SevenTaxi through the official support details available in the application.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.error;
    final Color textColor = Theme.of(context).textTheme.bodyMedium?.color ??
        const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: const AppBarWidget(
        title: 'Terms & Conditions',
        showBackButton: true,
        regularAppbar: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.82),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SevenTaxi Driver Terms',
                          style: textBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Please read these terms carefully before creating your driver account.',
                          style: textRegular.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'Welcome to SevenTaxi. By creating an account or using our services, you agree to these Terms and Conditions.',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  height: 1.55,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            ..._sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeDefault,
                ),
                child: _TermsSectionCard(
                  section: section,
                  textColor: textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _ContactRow(
                    icon: Icons.language_outlined,
                    label: 'Website',
                    value: 'seventaxi.in',
                    color: primaryColor,
                  ),
                  const Divider(height: 24),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'info@seventaxi.in',
                    color: primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
        ),
      ),
    );
  }
}

class _TermsSectionCard extends StatelessWidget {
  final _TermsSection section;
  final Color textColor;

  const _TermsSectionCard({
    required this.section,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: textColor,
            ),
          ),
          if (section.description != null) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              section.description!,
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                height: 1.55,
                color: textColor.withValues(alpha: 0.82),
              ),
            ),
          ],
          if (section.bullets != null) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ...section.bullets!.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          height: 1.5,
                          color: textColor.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TermsSection {
  final String title;
  final String? description;
  final List<String>? bullets;

  const _TermsSection({
    required this.title,
    this.description,
    this.bullets,
  });
}
