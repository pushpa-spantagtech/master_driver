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

  void _showFilterSheet(BuildContext context, TripController tripController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'filter'.tr,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...tripController.selectedFilterType.map((item) {
                  final bool selected =
                      item == tripController.selectedFilterTypeName;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: selected
                          ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.10)
                          : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          tripController.setFilterTypeName(item);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 21,
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).hintColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.tr,
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

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
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeSmall,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeSmall,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'your_trip'.tr,
                            style: textBold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'trip_history'.tr,
                            style: textRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showFilterSheet(context, tripController),
                        child: Container(
                          height: 42,
                          constraints: const BoxConstraints(minWidth: 112),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  tripController.selectedFilterTypeName.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.expand_more_rounded,
                                size: 20,
                                color: Theme.of(context).hintColor,
                              ),
                            ],
                          ),
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
                    top: Dimensions.paddingSizeExtraSmall),
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
