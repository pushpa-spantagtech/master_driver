

import 'package:ride_sharing_user_app/features/trip/domain/repositories/trip_repository_interface.dart';
import 'package:ride_sharing_user_app/features/trip/domain/services/trip_service_interface.dart';

class TripService implements TripServiceInterface{

  final TripRepositoryInterface tripRepositoryInterface;
  TripService({required this.tripRepositoryInterface});

  @override
  Future getTripList(String tripType, String from, String to, int offset, String filter) {
    return tripRepositoryInterface.getTripList(tripType, from, to, offset, filter);
  }

  @override
  Future getTripOverView(String filter) {
    return tripRepositoryInterface.getTripOverView(filter);
  }

  @override
  Future paymentSubmit(String tripId, String paymentMethod) {
    return tripRepositoryInterface.paymentSubmit(tripId, paymentMethod);
  }
  @override
  Future getTripOngoingAndAcceptedCancellationCauseList() async{
    return await tripRepositoryInterface.getTripOngoingAndAcceptedCancellationCauseList();
  }

}