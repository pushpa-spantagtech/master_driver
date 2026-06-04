import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer_widget.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_card_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_view_widget.dart';

class TripsWidget extends StatefulWidget {
  final ScrollController scrollController;
  final TripController tripController;

  const TripsWidget(
      {super.key,
      required this.tripController,
      required this.scrollController});

  @override
  State<TripsWidget> createState() => _TripsWidgetState();
}

class _TripsWidgetState extends State<TripsWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<TripController>(builder: (tripController) {
        return SingleChildScrollView(
          controller: widget.scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'your_trip'.tr,
                      style: textSemiBold.copyWith(
                          color: Theme.of(context).textTheme.bodySmall!.color,
                          fontSize: Dimensions.fontSizeExtraLarge),
                    ),
                    const Spacer(),
                    Container(
                      width: Dimensions.dropDownWidth,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            width: 1,
                            color: Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.2)),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                        ),
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          isDense: true,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.45))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.45))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.45))),
                          ),
                          hint: Text(tripController.selectedFilterTypeName.tr,
                              style: textRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color)),
                          items: tripController.selectedFilterType
                              .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item.tr,
                                      style: textRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color))))
                              .toList(),
                          onChanged: (value) {
                            tripController.setFilterTypeName(value!);
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(right: 8),
                          ),
                          iconStyleData: IconStyleData(
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Theme.of(context).hintColor),
                              iconSize: 24),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              widget.tripController.tripModel != null
                  ? widget.tripController.tripModel!.data != null
                      ? widget.tripController.tripModel!.data!.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 70.0,
                                  top: Dimensions.paddingSizeSmall),
                              child: PaginatedListViewWidget(
                                scrollController: widget.scrollController,
                                totalSize:
                                    widget.tripController.tripModel!.totalSize,
                                offset:
                                    (widget.tripController.tripModel != null &&
                                            widget.tripController.tripModel!
                                                    .offset !=
                                                null)
                                        ? int.parse(widget
                                            .tripController.tripModel!.offset
                                            .toString())
                                        : 1,
                                onPaginate: (int? offset) async {
                                  if (kDebugMode) {
                                    print('==========offset========>$offset');
                                  }
                                  await widget.tripController.getTripList(
                                      offset!,
                                      '',
                                      '',
                                      'ride_request',
                                      tripController.selectedFilterTypeName);
                                },
                                itemView: ListView.builder(
                                  itemCount: widget
                                      .tripController.tripModel!.data!.length,
                                  padding: const EdgeInsets.all(0),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return TripCard(
                                        tripModel: widget.tripController
                                            .tripModel!.data![index]);
                                  },
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: Get.height / 5),
                              child: const NoDataWidget(title: 'no_trip_found'),
                            )
                      : SizedBox(
                          height: Get.height,
                          child: const NotificationShimmerWidget())
                  : SizedBox(
                      height: Get.height,
                      child: const NotificationShimmerWidget()),
            ],
          ),
        );
      }),
    );
  }
}
