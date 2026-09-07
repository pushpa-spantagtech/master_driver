import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_view_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/customer_ride_request_card_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class RideRequestScreen extends StatefulWidget {
  final bool fromNotification;
  final String? rideRequestId;
  const RideRequestScreen({
    super.key,
    this.fromNotification = false,
    this.rideRequestId,
  });

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final RideController rideController = Get.find<RideController>();
    rideController.pendingRideRequestModel = null;
    final String rideId = widget.rideRequestId?.trim() ?? '';
    if (widget.fromNotification && rideId.isNotEmpty) {
      rideController.getNotifiedRideRequest(rideId);
    } else {
      rideController.getPendingRideRequestList(1);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'trip_request'.tr,
        regularAppbar: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Get.find<RideController>().getPendingRideRequestList(1);
        },
        child: GetBuilder<RideController>(
          builder: (rideController) {
            final requests = rideController.pendingRideRequestModel?.data ?? [];

            // Keep already-loaded cards visible while refreshing. Show the
            // full-screen loader only when there is no cached request data.
            if (requests.isNotEmpty) {
              return SingleChildScrollView(
                controller: scrollController,
                child: PaginatedListViewWidget(
                  scrollController: scrollController,
                  totalSize: rideController.pendingRideRequestModel?.totalSize,
                  offset: rideController.pendingRideRequestModel?.offset != null
                      ? int.parse(
                          rideController.pendingRideRequestModel!.offset
                              .toString(),
                        )
                      : 1,
                  onPaginate: (int? offset) async {
                    await rideController.getPendingRideRequestList(offset!);
                  },
                  itemView: ListView.builder(
                    itemCount: requests.length,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return CustomerRideRequestCardWidget(
                        rideRequest: requests[index],
                        fromList: true,
                        index: index,
                      );
                    },
                  ),
                ),
              );
            }

            if (rideController.isLoading) {
              return Center(
                child: SpinKitCircle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              );
            }

            return const NoDataWidget();
          },
        ),
      ),
    );
  }
}
