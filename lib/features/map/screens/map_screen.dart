import 'dart:async';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widgets/custom_icon_card_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/driver_header_info_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/expendale_bottom_sheet_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/screens/ride_request_list_screen.dart';
import 'dart:ui' as ui;

class MapScreen extends StatefulWidget {
  final String fromScreen;

  const MapScreen({super.key, this.fromScreen = 'home'});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  GlobalKey<ExpandableBottomSheetState> key =
      GlobalKey<ExpandableBottomSheetState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RideController>().updateRoute(false, notify: true);
    });
    Get.find<RiderMapController>().setSheetHeight(
        Get.find<RiderMapController>().currentRideState == RideState.initial
            ? 300
            : 270,
        false);
    Get.find<RideController>().getPendingRideRequestList(1).then((_) {
      // Add pending trip request markers to map after fetching
      if (Get.find<RideController>().pendingRideRequestModel?.data != null) {
        Get.find<RiderMapController>().addPendingTripRequestMarkers(
            Get.find<RideController>().pendingRideRequestModel!.data!);
      }
    });
    if (Get.find<RideController>().ongoingTrip != null &&
        Get.find<RideController>().ongoingTrip!.isNotEmpty &&
        (Get.find<RideController>().ongoingTrip![0].currentStatus ==
                'ongoing' ||
            Get.find<RideController>().ongoingTrip![0].currentStatus ==
                'accepted' ||
            (Get.find<RideController>().ongoingTrip![0].currentStatus ==
                    'completed' &&
                Get.find<RideController>().ongoingTrip![0].paymentStatus ==
                    'unpaid'))) {
      // Get.find<RideController>()
      //     .getCurrentRideStatus(froDetails: true, isUpdate: false);
      Get.find<RiderMapController>().setMarkersInitialPosition();
    }
    getCurrentLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  StreamSubscription? _locationSubscription;
  Marker? marker;

  Future<Uint8List> getMarker() async {
    ByteData data = await rootBundle.load(Images.carIconTop);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 24,
    );
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!
        .buffer
        .asUint8List();
  }

  void updateMarkerAndCircle(Position? newLocalData, Uint8List imageData) {
    if (Get.find<RiderMapController>().currentRideState == RideState.initial) {
      Get.find<RiderMapController>().markers.removeWhere(
            (m) => m.markerId.value == "driver_marker",
          );

      Get.find<RiderMapController>().update();
      return;
    }
    if (newLocalData == null) return;
    LatLng latlng = LatLng(
      newLocalData.latitude,
      newLocalData.longitude,
    );
    final Marker updatedMarker = Marker(
      markerId: const MarkerId("driver_marker"),
      position: latlng,
      rotation: newLocalData.heading,
      draggable: false,
      zIndexInt: 999,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      icon: BitmapDescriptor.bytes(imageData),
    );
    if (mounted) {
      setState(() {
        marker = updatedMarker;
      });
    }
    Get.find<RiderMapController>().markers.removeWhere(
          (m) => m.markerId.value == "driver_marker",
        );
    Get.find<RiderMapController>().markers.add(updatedMarker);
    Get.find<RiderMapController>().update();
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();

      // Check permissions first using LocationController
      bool hasPermission =
          await Get.find<LocationController>().checkPermission(() {});

      if (!hasPermission) {
        debugPrint("Location permission denied");
        return;
      }

      var location = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
        desiredAccuracy: LocationAccuracy.high,
      );

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      // Wait for map controller to be ready before animating
      await Future.delayed(const Duration(milliseconds: 500));

      if (_mapController != null && mounted) {
        _mapController!
            .moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 16,
        )));
      }

      // Start listening to location updates
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          timeLimit: Duration(seconds: 5),
        ),
      ).listen(
        (Position newLocalData) {
          if (_mapController != null && mounted) {
            try {
              updateMarkerAndCircle(newLocalData, imageData);
            } catch (e) {
              debugPrint("Error updating camera: $e");
            }
          }
        },
        onError: (error) {
          debugPrint("Location stream error: $error");
        },
      );
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied: ${e.message}");
      } else {
        debugPrint("Platform Error: ${e.message}");
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (Navigator.canPop(context)) {
          Get.find<RideController>().getOngoingParcelList();
          Get.find<RideController>().getLastTrip();
          Get.find<RideController>().updateRoute(true, notify: true);
        } else {
          Get.offAll(() => const DashboardScreen());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GetBuilder<RiderMapController>(builder: (riderMapController) {
          return GetBuilder<RideController>(builder: (rideController) {
            return ExpandableBottomSheet(
              key: key,
              persistentContentHeight: riderMapController.sheetHeight,
              background: GetBuilder<RideController>(builder: (rideController) {
                return Stack(children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: riderMapController.sheetHeight -
                          (Get.find<RiderMapController>().currentRideState ==
                                  RideState.initial
                              ? 80
                              : 20),
                    ),
                    child: GoogleMap(
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      // style: Get.isDarkMode`
                      //     ? Get.find<ThemeController>().darkMap
                      //     : Get.find<ThemeController>().lightMap,
                      initialCameraPosition: CameraPosition(
                        target: (rideController.tripDetail != null &&
                                rideController.tripDetail!.pickupCoordinates !=
                                    null)
                            ? LatLng(
                                rideController.tripDetail!.pickupCoordinates!
                                    .coordinates![1],
                                rideController.tripDetail!.pickupCoordinates!
                                    .coordinates![0],
                              )
                            : Get.find<LocationController>().initialPosition,
                        zoom: 16,
                      ),
                      onMapCreated: (GoogleMapController controller) async {
                        riderMapController.mapController = controller;
                        if (riderMapController.currentRideState.name !=
                            'initial') {
                          if (riderMapController.currentRideState.name ==
                                  'accepted' ||
                              riderMapController.currentRideState.name ==
                                  'ongoing') {
                            Get.find<RideController>().remainingDistance(
                                Get.find<RideController>().tripDetail!.id!,
                                mapBound: true);
                          } else {
                            riderMapController.getPickupToDestinationPolyline();
                          }
                        }
                        _mapController = controller;
                      },
                      onCameraMove: (CameraPosition cameraPosition) {},
                      onCameraIdle: () {},
                      minMaxZoomPreference:
                          const MinMaxZoomPreference(0, AppConstants.mapZoom),
                      markers: Set<Marker>.of(riderMapController.markers),
                      polylines: riderMapController.polylines,
                      zoomControlsEnabled: false,
                      trafficEnabled: riderMapController.isTrafficEnable,
                      indoorViewEnabled: true,
                      mapToolbarEnabled: true,
                    ),
                  ),
                  const DriverHeaderInfoWidget(),
                  Positioned(
                      bottom: Get.width * 0.87,
                      right: 0,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GetBuilder<LocationController>(
                            builder: (locationController) {
                          return CustomIconCardWidget(
                            title: '',
                            index: 5,
                            icon: riderMapController.isTrafficEnable
                                ? Images.trafficOnlineIcon
                                : Images.trafficOfflineIcon,
                            iconColor: riderMapController.isTrafficEnable
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).hintColor,
                            onTap: () => riderMapController.toggleTrafficView(),
                          );
                        }),
                      )),
                  Positioned(
                      bottom: Get.width * 0.73,
                      right: 0,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GetBuilder<LocationController>(
                            builder: (locationController) {
                          return CustomIconCardWidget(
                            iconColor: Theme.of(context).colorScheme.primary,
                            title: '',
                            index: 5,
                            icon: Images.currentLocation,
                            onTap: () async {
                              await locationController.getCurrentLocation(
                                  mapController: _mapController,
                                  isAnimate: false);
                            },
                          );
                        }),
                      )),
                  Positioned(
                      child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Get.find<RideController>()
                            .updateRoute(true, notify: true);
                        Get.off(() => const DashboardScreen());
                      },
                      onHorizontalDragEnd: (DragEndDetails details) {
                        _onHorizontalDrag(details);
                        Get.find<RideController>()
                            .updateRoute(true, notify: true);
                        Get.off(() => const DashboardScreen());
                      },
                      child: Stack(children: [
                        SizedBox(
                            width: Dimensions.iconSizeExtraLarge,
                            child: Image.asset(
                              Images.mapToHomeIcon,
                              color: Theme.of(context).hintColor,
                            )),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 5,
                          right: 5,
                          child: SizedBox(
                              width: 15,
                              child: Image.asset(
                                Images.homeSmallIcon,
                                color: Theme.of(context).colorScheme.primary,
                              )),
                        )
                      ]),
                    ),
                  )),
                ]);
              }),
              persistentHeader: SizedBox(
                  height: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child:
                          GetBuilder<RideController>(builder: (rideController) {
                        return InkWell(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          onTap: () => Get.to(() => const RideRequestScreen()),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeExtraLarge),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                      height: Dimensions.iconSizeSmall,
                                      child: Image.asset(
                                        Images.reqListIcon,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeSmall),
                                  Text(
                                    '${rideController.pendingRideRequestModel?.data?.length ?? 0} ${'more_request'.tr}',
                                    style: textRegular.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })),
                    ],
                  )),
              expandableContent: Builder(builder: (context) {
                return RiderBottomSheetWidget(
                  expandableKey: key,
                );
              }),
            );
          });
        }),
      ),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0) {
      return;
    }

    if (details.primaryVelocity!.compareTo(0) == -1) {
    } else {}
  }
}
