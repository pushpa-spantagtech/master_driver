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

    // Change the route state without notifying while the widget tree is
    // still being created. Notifying here causes:
    // setState() or markNeedsBuild() called during build.
    Get.find<RideController>().updateRoute(false, notify: false);

    _driverMarkerFuture = getMarker();

    // Notify only after the first frame is complete and open the bottom
    // sheet at its normal content height when this screen is first shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<RideController>().updateRoute(false, notify: true);

      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        key.currentState?.expand();
        if (!_isBottomSheetExpanded) {
          setState(() => _isBottomSheetExpanded = true);
        }
      });
    });
    Get.find<RiderMapController>().setSheetHeight(50, false);
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

    // Update the global shortcut after the current frame. Calling update()
    // directly during dispose can rebuild a GetBuilder while Flutter is
    // already building/removing widgets.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<RideController>()) {
        Get.find<RideController>().updateRoute(true, notify: true);
      }
    });

    super.dispose();
  }

  StreamSubscription? _locationSubscription;
  Marker? marker;
  Future<Uint8List>? _driverMarkerFuture;
  bool _isMapReady = false;
  bool _didMoveToInitialLocation = false;
  bool _isBottomSheetExpanded = false;

  Future<void> _moveToCurrentLocation() async {
    final locationController = Get.find<LocationController>();
    final bool hasPermission = await locationController.checkPermission(() {});

    if (!hasPermission || _mapController == null || !mounted) {
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18,
            bearing: 0,
            tilt: 0,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Unable to move to current location: $e');
    }
  }

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
      Uint8List imageData = await (_driverMarkerFuture ?? getMarker());

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

      if (_mapController != null &&
          mounted &&
          !_didMoveToInitialLocation &&
          Get.find<RiderMapController>().currentRideState ==
              RideState.initial) {
        _didMoveToInitialLocation = true;
        _mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 16.5,
          ),
        ));
      }

      // Start listening to location updates
      // _locationSubscription = Geolocator.getPositionStream(
      //   locationSettings: const LocationSettings(
      //     accuracy: LocationAccuracy.high,
      //     distanceFilter: 5,
      //     timeLimit: Duration(seconds: 5),
      //   ),
      // ).listen(
      //   (Position newLocalData) {
      //     if (_mapController != null && mounted) {
      //       try {
      //         updateMarkerAndCircle(newLocalData, imageData);
      //       } catch (e) {
      //         debugPrint("Error updating camera: $e");
      //       }
      //     }
      //   },
      //   onError: (error) {
      //     debugPrint("Location stream error: $error");
      //   },
      // );
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
        // When back is pressed but this route is not popped, keep the global
        // right-side map tab hidden. This prevents it appearing over MapScreen.
        if (!didPop) {
          if (!Navigator.canPop(context)) {
            Get.offAll(() => const DashboardScreen());
          }
          return;
        }

        Get.find<RideController>().getOngoingParcelList();
        Get.find<RideController>().getLastTrip();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GetBuilder<RiderMapController>(builder: (riderMapController) {
          return GetBuilder<RideController>(builder: (rideController) {
            final double safeBottom = MediaQuery.of(context).padding.bottom;
            final double mapActionBottom = _isBottomSheetExpanded
                ? 310 + safeBottom
                : riderMapController.sheetHeight + 56;

            return ExpandableBottomSheet(
              key: key,
              onIsExtendedCallback: () {
                if (mounted && !_isBottomSheetExpanded) {
                  setState(() => _isBottomSheetExpanded = true);
                }
              },
              onIsContractedCallback: () {
                if (mounted && _isBottomSheetExpanded) {
                  setState(() => _isBottomSheetExpanded = false);
                }
              },
              persistentContentHeight: riderMapController.sheetHeight,
              background: GetBuilder<RideController>(builder: (rideController) {
                return Stack(children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: (riderMapController.sheetHeight -
                          (riderMapController.currentRideState ==
                              RideState.initial
                              ? 80
                              : 20))
                          .clamp(0.0, double.infinity)
                          .toDouble(),
                    ),
                    child: GoogleMap(
                      myLocationEnabled: true,
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
                        _mapController = controller;
                        if (mounted) {
                          setState(() => _isMapReady = true);
                        }
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
                      },
                      onCameraMove: (CameraPosition cameraPosition) {},
                      onCameraIdle: () {},
                      minMaxZoomPreference:
                      const MinMaxZoomPreference(0, AppConstants.mapZoom),
                      markers: Set<Marker>.of(riderMapController.markers),
                      polylines: riderMapController.polylines,
                      zoomControlsEnabled: false,
                      padding: EdgeInsets.only(
                        top: 88,
                        left: 12,
                        right: 12,
                        bottom: riderMapController.sheetHeight + 34,
                      ),
                      trafficEnabled: riderMapController.isTrafficEnable,
                      indoorViewEnabled: true,
                      mapToolbarEnabled: true,
                    ),
                  ),
                  if (!_isMapReady)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.35),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .cardColor
                                    .withOpacity(0.92),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Loading map...',
                                    style: textMedium.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const DriverHeaderInfoWidget(),
                  Positioned(
                      bottom: mapActionBottom + 56,
                      right: 14,
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
                      bottom: mapActionBottom,
                      right: 14,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GetBuilder<LocationController>(
                            builder: (locationController) {
                              return CustomIconCardWidget(
                                iconColor: Theme.of(context).colorScheme.primary,
                                title: '',
                                index: 5,
                                icon: Images.currentLocation,
                                onTap: _moveToCurrentLocation,
                              );
                            }),
                      )),
                  // Hide the left Home/menu tab after the ride is accepted.
                  // It remains visible only on the normal initial map.
                  if (riderMapController.currentRideState == RideState.initial)
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
                          child: Stack(
                            children: [
                              SizedBox(
                                width: Dimensions.iconSizeExtraLarge,
                                child: Image.asset(
                                  Images.mapToHomeIcon,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 5,
                                right: 5,
                                child: SizedBox(
                                  width: 15,
                                  child: Image.asset(
                                    Images.homeSmallIcon,
                                    color:
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                          onTap: () {
                            if (!(Get.currentRoute
                                .contains('RideRequestScreen'))) {
                              Get.to(() => const RideRequestScreen());
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                              Theme.of(context).cardColor.withOpacity(0.94),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeExtraLarge),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
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
              expandableContent: Builder(
                builder: (context) {
                  return AnimatedPadding(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: RiderBottomSheetWidget(
                      expandableKey: key,
                    ),
                  );
                },
              ),
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
