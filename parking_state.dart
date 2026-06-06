part of 'parking_cubit.dart';

abstract class ParkingState {
  const ParkingState();
}

class ParkingInitial extends ParkingState {
  const ParkingInitial();
}

class ParkingReady extends ParkingState {
  final List<ParkingSpotModel> spots;
  final List<ParkingLocationSummary> locations;
  final List<ReservationRecord> reservationHistory;
  final VehicleMovementStats vehicleStats;
  final String searchQuery;
  final String? feedbackMessage;
  final bool feedbackIsError;

  const ParkingReady({
    required this.spots,
    required this.locations,
    required this.reservationHistory,
    required this.vehicleStats,
    this.searchQuery = '',
    this.feedbackMessage,
    this.feedbackIsError = false,
  });

  List<ParkingLocationSummary> get visibleLocations {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return locations;
    return locations
        .where(
          (l) =>
              l.name.toLowerCase().contains(q) ||
              l.subtitle.toLowerCase().contains(q),
        )
        .toList();
  }

  List<ParkingSpotModel> get visibleSpots {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return spots;
    return spots
        .where(
          (s) =>
              s.locationName.toLowerCase().contains(q) ||
              s.locationSubtitle.toLowerCase().contains(q) ||
              s.code.toLowerCase().contains(q),
        )
        .toList();
  }

  int get availableForBookingCount =>
      spots.where((s) => s.isOpenForBooking).length;

  int get occupiedCount => spots.where((s) => s.isOccupied).length;

  ParkingReady copyWith({
    List<ParkingSpotModel>? spots,
    List<ParkingLocationSummary>? locations,
    List<ReservationRecord>? reservationHistory,
    VehicleMovementStats? vehicleStats,
    String? searchQuery,
    String? feedbackMessage,
    bool? feedbackIsError,
    bool clearFeedback = false,
  }) {
    return ParkingReady(
      spots: spots ?? this.spots,
      locations: locations ?? this.locations,
      reservationHistory: reservationHistory ?? this.reservationHistory,
      vehicleStats: vehicleStats ?? this.vehicleStats,
      searchQuery: searchQuery ?? this.searchQuery,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      feedbackIsError: clearFeedback
          ? false
          : (feedbackIsError ?? this.feedbackIsError),
    );
  }
}
