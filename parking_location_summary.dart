/// ملخص «مكان» يضم عدة مواقف (للعرض في الشاشة الأولى).
class ParkingLocationSummary {
  const ParkingLocationSummary({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.themeIndex,
    required this.totalSpots,
    required this.availableToBook,
    required this.occupiedCount,
    required this.pendingCount,
    required this.confirmedReservedCount,
  });

  final String id;
  final String name;

  /// وصف قصير للمنطقة (ليبي).
  final String subtitle;

  /// فهرس تنسيق الألوان في الواجهة.
  final int themeIndex;
  final int totalSpots;
  final int availableToBook;
  final int occupiedCount;
  final int pendingCount;
  final int confirmedReservedCount;
}