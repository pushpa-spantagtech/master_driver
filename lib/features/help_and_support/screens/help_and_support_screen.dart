import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/help_and_support/controllers/help_and_support_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/type_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HelpAndSupportController>(
          builder: (helpAndSupportController) {
        String data = helpAndSupportController.helpAndSupportIndex == 1
            ? '${Get.find<SplashController>().config!.legal?.shortDescription ?? ''}\n${Get.find<SplashController>().config!.legal?.longDescription ?? ''}'
            : '${Get.find<SplashController>().config!.privacyPolicy?.shortDescription ?? ''}\n${Get.find<SplashController>().config!.privacyPolicy?.longDescription ?? ''}';
        return Stack(
          children: [
            Column(children: [
              AppBarWidget(title: 'help_and_support'.tr, regularAppbar: true),
              const SizedBox(height: 30),
              helpAndSupportController.helpAndSupportIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraLarge),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraLarge),
                              child: Center(
                                  child: SizedBox(
                                      width: 200,
                                      child: Image.asset(Images.supportDesk)))),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeDefault),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeSmall,
                                        bottom:
                                            Dimensions.paddingSizeExtraSmall),
                                    child: Text('contact_us_through_email'.tr,
                                        style: textSemiBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeSmall),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('you_can_send_us_email_through'.tr,
                                          style: textRegular.copyWith(
                                              color:
                                                  Theme.of(context).hintColor)),
                                      Text(
                                        Get.find<SplashController>()
                                                .config!
                                                .businessContactEmail ??
                                            '',
                                        style: textSemiBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  Dimensions.paddingSizeSmall),
                                          child: Text.rich(TextSpan(children: [
                                            TextSpan(
                                                text:
                                                    'typically_support_team_send_you_feedback'
                                                        .tr,
                                                style: textRegular.copyWith(
                                                    color: Theme.of(context)
                                                        .hintColor)),
                                            TextSpan(
                                                text: 'two_hours'.tr,
                                                style: textSemiBold)
                                          ]))),
                                    ],
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeSmall,
                                        bottom:
                                            Dimensions.paddingSizeExtraSmall),
                                    child: Text('contact_us_through_phone'.tr,
                                        style: textSemiBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault))),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.paddingSizeSmall),
                                        child: Text.rich(TextSpan(children: [
                                          TextSpan(
                                              text: 'contact_with_us'.tr,
                                              style: textRegular.copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor)),
                                          TextSpan(
                                              text: Get.find<SplashController>()
                                                      .config!
                                                      .businessContactPhone ??
                                                  '',
                                              style: textSemiBold)
                                        ]))),
                                    Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: 'talk_with_our'.tr,
                                          style: textRegular.copyWith(
                                              color:
                                                  Theme.of(context).hintColor)),
                                      TextSpan(
                                          text: 'customer_support_executive'.tr,
                                          style: textSemiBold),
                                      TextSpan(
                                          text: 'at_any_time'.tr,
                                          style: textRegular.copyWith(
                                              color:
                                                  Theme.of(context).hintColor))
                                    ]))
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Dimensions.paddingSizeOverLarge),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeDefault),
                                      child: ButtonWidget(
                                          buttonText: 'email'.tr,
                                          icon: Icons.email,
                                          transparent: true,
                                          iconColor:
                                              Theme.of(context).primaryColor,
                                          textColor:
                                              Theme.of(context).primaryColor,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          radius: 100,
                                          onPressed: () => _launchUrl(
                                              "sms:${Get.find<SplashController>().config!.businessContactEmail!}",
                                              true)))),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: ButtonWidget(
                                    transparent: true,
                                    buttonText: 'call'.tr,
                                    icon: Icons.call,
                                    iconColor: Theme.of(context).primaryColor,
                                    textColor: Theme.of(context).primaryColor,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    radius: 100,
                                    onPressed: () => _launchUrl(
                                        "tel:${Get.find<SplashController>().config!.businessContactPhone!}",
                                        false)),
                              )),
                            ],
                          )
                        ],
                      ),
                    )
                  : helpAndSupportController.helpAndSupportIndex == 1
                      ? Expanded(
                          child: Container(
                          height: MediaQuery.of(context).size.height,
                          color: Theme.of(context).cardColor,
                          child: SingleChildScrollView(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              physics: const BouncingScrollPhysics(),
                              child: HtmlWidget(data,
                                  key: const Key('privacy_policy'))),
                        ))
                      : Expanded(
                          child: Container(
                              height: MediaQuery.of(context).size.height,
                              color: Theme.of(context).cardColor,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                physics: const BouncingScrollPhysics(),
                                child: HtmlWidget(data,
                                    key: const Key('privacy_policy')),
                              ))),
            ]),
            Positioned(
              top: 90,
              left: 10,
              right: 10,
              child: SizedBox(
                height: Dimensions.headerCardHeight,
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        helpAndSupportController.helpAndSupportTypeList.length,
                    itemBuilder: (context, index) {
                      return TypeButtonWidget(
                          index: index,
                          name: helpAndSupportController
                              .helpAndSupportTypeList[index],
                          selectedIndex:
                              helpAndSupportController.helpAndSupportIndex,
                          cardWidth: Get.width / 2.2,
                          onTap: () => helpAndSupportController
                              .setHelpAndSupportIndex(index));
                    }),
              ),
            ),
          ],
        );
      }),
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
