import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/map/widgets/parcel_card_widget.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/parcel_list_model.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';

class OngoingParcelListViewWidget extends StatefulWidget {
  final String title;
  final ParcelListModel parcelListModel;
  const OngoingParcelListViewWidget({super.key, required this.title, required this.parcelListModel});

  @override
  State<OngoingParcelListViewWidget> createState() => _OngoingParcelListViewWidgetState();
}

class _OngoingParcelListViewWidgetState extends State<OngoingParcelListViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(title: widget.title.tr, regularAppbar: true,),
        body: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: widget.parcelListModel.data!.length,
            itemBuilder: (context, index){
            return ParcelRequestCardWidget(rideRequest: widget.parcelListModel.data![index], index: index);
        }),

    );
  }
}
