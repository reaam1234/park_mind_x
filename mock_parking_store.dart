import 'package:park_mind_x/features/parking/data/models/parking_location_summary.dart';
import 'package:park_mind_x/features/parking/data/models/parking_reservation_status.dart';
import 'package:park_mind_x/features/parking/data/models/parking_spot_model.dart';

/// مخزن تجريبي في الذاكرة — يُعاد تعيينه عند إعادة تشغيل التطبيق.
class MockParkingStore {
  MockParkingStore(List<ParkingSpotModel> initial) : _spots = List.from(initial);

  final List<ParkingSpotModel> _spots;

  List<ParkingSpotModel> get spots => List.unmodifiable(_spots);

  List<ParkingSpotModel> spotsInLocation(String locationId) =>
      _spots.where((s) => s.locationId == locationId).toList();

  List<ParkingLocationSummary> locationSummaries() {
    const order = [
      'loc_tripoli_university',
      'loc_nofleen',
      'loc_tripoli_andalus',
      'loc_gargaresh',
    ];
    int rank(String locId) {
      final i = order.indexOf(locId);
      return i < 0 ? 100 : i;
    }

    final ids = _spots.map((s) => s.locationId).toSet();
    final summaries = ids.map((id) {
      final list = spotsInLocation(id);
      final first = list.isNotEmpty ? list.first : null;
      return ParkingLocationSummary(
        id: id,
        name: first?.locationName ?? id,
        subtitle: first?.locationSubtitle ?? '',
        themeIndex: first?.themeIndex ?? 0,
        totalSpots: list.length,
        availableToBook: list.where((s) => s.isOpenForBooking).length,
        occupiedCount: list.where((s) => s.isOccupied).length,
        pendingCount: list.where((s) => s.hasPendingReservation).length,
        confirmedReservedCount:
            list.where((s) => s.hasConfirmedReservation).length,
      );
    }).toList();
    summaries.sort((a, b) => rank(a.id).compareTo(rank(b.id)));
    return summaries;
  }

  int get availableForBookingCount =>
      _spots.where((s) => s.isOpenForBooking).length;

  int get occupiedCount => _spots.where((s) => s.isOccupied).length;

  static MockParkingStore seeded() {
    return MockParkingStore([
      // ——— جامعة طرابلس ———
      ParkingSpotModel(
        id: 's1',
        locationId: 'loc_tripoli_university',
        locationName: 'جامعة طرابلس — مجمع المواقف الجامعي',
        locationSubtitle: 'الحرم الرئيسي · قرب كلية العلوم والبوابة الشمالية',
        themeIndex: 0,
        code: 'جام-01',
        isOccupied: true,
        occupiedPlate: normalizeParkingPlate('5-451384'),
      ),
      ParkingSpotModel(
        id: 's2',
        locationId: 'loc_tripoli_university',
        locationName: 'جامعة طرابلس — مجمع المواقف الجامعي',
        locationSubtitle: 'الحرم الرئيسي · قرب كلية العلوم والبوابة الشمالية',
        themeIndex: 0,
        code: 'جام-02',
        reservationStatus: ParkingReservationStatus.confirmed,
        reservedPlate: normalizeParkingPlate('123أ-45'),
        ownerName: 'أحمد التجريبي',
        ownerPhone: '0910000000',
        durationHours: 2,
      ),
      ParkingSpotModel(
        id: 's3',
        locationId: 'loc_tripoli_university',
        locationName: 'جامعة طرابلس — مجمع المواقف الجامعي',
        locationSubtitle: 'الحرم الرئيسي · قرب كلية العلوم والبوابة الشمالية',
        themeIndex: 0,
        code: 'جام-03',
      ),
      ParkingSpotModel(
        id: 's4',
        locationId: 'loc_tripoli_university',
        locationName: 'جامعة طرابلس — مجمع المواقف الجامعي',
        locationSubtitle: 'الحرم الرئيسي · قرب كلية العلوم والبوابة الشمالية',
        themeIndex: 0,
        code: 'جام-04',
      ),
      // ——— نوفلين ———
      ParkingSpotModel(
        id: 's5',
        locationId: 'loc_nofleen',
        locationName: 'منطقة نوفلين — مواقف الخدمات',
        locationSubtitle: 'طريق النوفليين · قرب الدائري والمراكز التجارية',
        themeIndex: 1,
        code: 'نو-01',
        isOccupied: true,
        occupiedPlate: normalizeParkingPlate('7-889900'),
      ),
      ParkingSpotModel(
        id: 's6',
        locationId: 'loc_nofleen',
        locationName: 'منطقة نوفلين — مواقف الخدمات',
        locationSubtitle: 'طريق النوفليين · قرب الدائري والمراكز التجارية',
        themeIndex: 1,
        code: 'نو-02',
      ),
      ParkingSpotModel(
        id: 's7',
        locationId: 'loc_nofleen',
        locationName: 'منطقة نوفلين — مواقف الخدمات',
        locationSubtitle: 'طريق النوفليين · قرب الدائري والمراكز التجارية',
        themeIndex: 1,
        code: 'نو-03',
      ),
      // ——— حي الأندلس ———
      ParkingSpotModel(
        id: 's8',
        locationId: 'loc_tripoli_andalus',
        locationName: 'طرابلس — حي الأندلس',
        locationSubtitle: 'شارع الجمهورية · منطقة سكنية هادئة',
        themeIndex: 2,
        code: 'أن-01',
      ),
      ParkingSpotModel(
        id: 's9',
        locationId: 'loc_tripoli_andalus',
        locationName: 'طرابلس — حي الأندلس',
        locationSubtitle: 'شارع الجمهورية · منطقة سكنية هادئة',
        themeIndex: 2,
        code: 'أن-02',
      ),
      ParkingSpotModel(
        id: 's10',
        locationId: 'loc_tripoli_andalus',
        locationName: 'طرابلس — حي الأندلس',
        locationSubtitle: 'شارع الجمهورية · منطقة سكنية هادئة',
        themeIndex: 2,
        code: 'أن-03',
      ),
      // ——— قرقارش ———
      ParkingSpotModel(
        id: 's11',
        locationId: 'loc_gargaresh',
        locationName: 'طرابلس — طريق قرقارش',
        locationSubtitle: 'باتجاه سوق الجمعة والكورنيش',
        themeIndex: 3,
        code: 'قر-01',
      ),
      ParkingSpotModel(
        id: 's12',
        locationId: 'loc_gargaresh',
        locationName: 'طرابلس — طريق قرقارش',
        locationSubtitle: 'باتجاه سوق الجمعة والكورنيش',
        themeIndex: 3,
        code: 'قر-02',
      ),
    ]);
  }

  /// طلب حجز — يضع الحجز في انتظار التأكيد (تجريبي).
  String? requestBooking({
    required String spotId,
    required String plateRaw,
    required String ownerName,
    required String ownerPhone,
    required int durationHours,
  }) {
    final i = _spots.indexWhere((e) => e.id == spotId);
    if (i < 0) return 'معرّف الموقف غير صالح';
    final plate = normalizeParkingPlate(plateRaw);
    if (plate.isEmpty) return 'أدخل رقم اللوحة';
    final name = ownerName.trim();
    if (name.isEmpty) return 'أدخل الاسم';
    final phone = ownerPhone.trim();
    if (phone.isEmpty) return 'أدخل رقم الهاتف';
    if (durationHours < 1 || durationHours > 72) {
      return 'مدة الحجز بين 1 و 72 ساعة';
    }
    final s = _spots[i];
    if (!s.isOpenForBooking) return 'هذا الموقف غير متاح للحجز';
    _spots[i] = s.copyWith(
      reservationStatus: ParkingReservationStatus.pendingConfirmation,
      reservedPlate: plate,
      ownerName: name,
      ownerPhone: phone,
      durationHours: durationHours,
    );
    return null;
  }

  /// تأكيد تجريبي للحجز (يُستدعى بعد رسالة الانتظار).
  String? confirmPendingBooking(String spotId) {
    final i = _spots.indexWhere((e) => e.id == spotId);
    if (i < 0) return 'معرّف الموقف غير صالح';
    final s = _spots[i];
    if (s.reservationStatus != ParkingReservationStatus.pendingConfirmation) {
      return 'لا يوجد حجز قيد التأكيد لهذا الموقف';
    }
    _spots[i] = s.copyWith(
      reservationStatus: ParkingReservationStatus.confirmed,
    );
    return null;
  }

  /// دخول مركبة — يتطلب حجزاً مؤكداً أو موقفاً غير محجوز (دخول مباشر)
  String? vehicleEnter(String spotId, String plateRaw) {
    final i = _spots.indexWhere((e) => e.id == spotId);
    if (i < 0) return 'معرّف الموقف غير صالح';
    final s = _spots[i];
    if (s.isOccupied) return 'الموقف مشغول بالفعل';
    final plate = normalizeParkingPlate(plateRaw);
    if (plate.isEmpty) return 'أدخل رقم اللوحة';
    if (s.hasPendingReservation) {
      return 'الحجز ما زال في انتظار التأكيد — لا يمكن الدخول بعد';
    }
    if (s.hasConfirmedReservation &&
        s.reservedPlate != null &&
        s.reservedPlate != plate) {
      return 'اللوحة لا تطابق الحجز لهذا الموقف';
    }
    _spots[i] = s.copyWith(
      isOccupied: true,
      occupiedPlate: plate,
      reservationStatus: ParkingReservationStatus.none,
      clearReservedPlate: true,
      clearOwner: true,
      clearDuration: true,
    );
    return null;
  }

  String? vehicleExit(String spotId) {
    final i = _spots.indexWhere((e) => e.id == spotId);
    if (i < 0) return 'معرّف الموقف غير صالح';
    final s = _spots[i];
    if (!s.isOccupied) return 'لا توجد مركبة في هذا الموقف';
    _spots[i] = ParkingSpotModel(
      id: s.id,
      locationId: s.locationId,
      locationName: s.locationName,
      locationSubtitle: s.locationSubtitle,
      themeIndex: s.themeIndex,
      code: s.code,
      isOccupied: false,
      reservationStatus: ParkingReservationStatus.none,
    );
    return null;
  }

  ({bool ok, String message, ParkingSpotModel? spot, bool isPending})
      verifyReservation(
    String plateRaw,
  ) {
    final plate = normalizeParkingPlate(plateRaw);
    if (plate.isEmpty) {
      return (
        ok: false,
        message: 'أدخل رقم اللوحة',
        spot: null,
        isPending: false,
      );
    }
    for (final s in _spots) {
      if (!s.isOccupied &&
          s.reservedPlate != null &&
          s.reservedPlate == plate) {
        if (s.hasPendingReservation) {
          return (
            ok: true,
            message:
                'حجزك مسجّل لكنه في انتظار التأكيد — الموقف ${s.code} (${s.locationName})',
            spot: s,
            isPending: true,
          );
        }
        if (s.hasConfirmedReservation) {
          return (
            ok: true,
            message: 'حجز مؤكد — الموقف ${s.code} (${s.locationName})',
            spot: s,
            isPending: false,
          );
        }
      }
    }
    return (
      ok: false,
      message: 'لا يوجد حجز مطابق لهذه اللوحة',
      spot: null,
      isPending: false,
    );
  }

  List<ParkingSpotModel> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return spots;
    return _spots
        .where(
          (s) =>
              s.locationName.toLowerCase().contains(q) ||
              s.locationSubtitle.toLowerCase().contains(q) ||
              s.code.toLowerCase().contains(q),
        )
        .toList();
  }
}