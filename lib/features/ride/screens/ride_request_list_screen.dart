import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/map/widgets/customer_ride_request_card_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_view_widget.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RideController rideController = Get.find<RideController>();

      // Fetch only once after the screen is mounted. Notification navigation
      // no longer waits for this API before opening the screen.
      if (!rideController.isLoading) {
        rideController.getPendingRideRequestList(1);
      }
    });
  }

  final ScrollController scrollController = ScrollController();

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
