import 'package:park_mind_x/features/parking/data/models/parking_reservation_status.dart';

/// موقف واحد داخل «مكان» يضم عدة مواقف — تجريبي في الذاكرة.
class ParkingSpotModel {
  final String id;
  final String locationId;
  final String locationName;

  /// وصف المنطقة يُعرض في بطاقة المكان (نفس القيمة لكل مواقف المكان).
  final String locationSubtitle;

  /// ترتيب/تنسيق البطاقة في الواجهة (0…n).
  final int themeIndex;
  final String code;

  bool isOccupied;
  String? occupiedPlate;

  ParkingReservationStatus reservationStatus;

  /// تُملأ عند طلب الحجز (قيد التأكيد أو بعد التأكيد)
  String? reservedPlate;
  String? ownerName;
  String? ownerPhone;
  int? durationHours;

  ParkingSpotModel({
    required this.id,
    required this.locationId,
    required this.locationName,
    this.locationSubtitle = '',
    this.themeIndex = 0,
    required this.code,
    this.isOccupied = false,
    this.occupiedPlate,
    this.reservationStatus = ParkingReservationStatus.none,
    this.reservedPlate,
    this.ownerName,
    this.ownerPhone,
    this.durationHours,
  });

  bool get isOpenForBooking =>
      !isOccupied && reservationStatus == ParkingReservationStatus.none;

  bool get hasPendingReservation =>
      !isOccupied &&
      reservationStatus == ParkingReservationStatus.pendingConfirmation;

  bool get hasConfirmedReservation =>
      !isOccupied &&
      reservationStatus == ParkingReservationStatus.confirmed &&
      reservedPlate != null &&
      reservedPlate!.isNotEmpty;

  /// للتوافق مع الشاشات القديمة
  bool get hasActiveReservation => hasConfirmedReservation;

  ParkingSpotModel copyWith({
    bool? isOccupied,
    String? occupiedPlate,
    ParkingReservationStatus? reservationStatus,
    String? reservedPlate,
    String? ownerName,
    String? ownerPhone,
    int? durationHours,
    bool clearReservedPlate = false,
    bool clearOccupiedPlate = false,
    bool clearOwner = false,
    bool clearDuration = false,
  }) {
    return ParkingSpotModel(
      id: id,
      locationId: locationId,
      locationName: locationName,
      locationSubtitle: locationSubtitle,
      themeIndex: themeIndex,
      code: code,
      isOccupied: isOccupied ?? this.isOccupied,
      occupiedPlate:
          clearOccupiedPlate ? null : (occupiedPlate ?? this.occupiedPlate),
      reservationStatus: reservationStatus ?? this.reservationStatus,
      reservedPlate:
          clearReservedPlate ? null : (reservedPlate ?? this.reservedPlate),
      ownerName: clearOwner ? null : (ownerName ?? this.ownerName),
      ownerPhone: clearOwner ? null : (ownerPhone ?? this.ownerPhone),
      durationHours: clearDuration ? null : (durationHours ?? this.durationHours),
    );
  }
}

String normalizeParkingPlate(String input) {
  return input.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
}