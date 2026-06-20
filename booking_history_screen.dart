import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:park_mind_x_app/core/constants/app_colors.dart';
import 'package:park_mind_x_app/core/constants/app_padding.dart';
import 'package:park_mind_x_app/core/constants/app_text_styles.dart';
import 'package:park_mind_x_app/core/theme/app_theme.dart';
import 'package:park_mind_x_app/features/parking/presentation/cubits/parking_cubit.dart';
import 'package:park_mind_x_app/features/parking/presentation/parking_ui.dart';
import 'package:park_mind_x_app/features/reservations/data/reservation_record.dart';

/// سجل الحجوزات السابقة والنشطة.
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: context.pageBackground,
  appBar: embedded
      ? AppBar(title: const Text('سجل الحجوزات'))
      : const ParkingGradientAppBar(title: 'سجل الحجوزات'),
  body: BlocBuilder<ParkingCubit, ParkingState>(
    builder: (context, state) {
      if (state is! ParkingReady) {
        return const Center(child: CircularProgressIndicator());
      }
      final history = state.reservationHistory;
      if (history.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 56, color: AppColors.grey400),
              AppPadding.verticalSpaceMd,
              Text('لا توجد حجوزات سابقة', style: AppTextStyles.size12Bold),
            ],
          ),
        );
      }

      final active = history.where((r) => r.isActive).toList();
      final past = history.where((r) => !r.isActive).toList();
      final fmt = DateFormat('yyyy/MM/dd · HH:mm', 'ar');

      return ListView(
        padding: AppPadding.allLg,
        children: [
          if (active.isNotEmpty) ...[
            Text('حجوزات نشطة', style: AppTextStyles.size12Bold),
            AppPadding.verticalSpaceSm,
            ...active.map((r) => _ReservationTile(record: r, fmt: fmt, isActive: true)),
            AppPadding.verticalSpaceLg,
          ],
          Text('سجل سابق', style: AppTextStyles.size12Bold),
          AppPadding.verticalSpaceSm,
          ...past.map((r) => _ReservationTile(record: r, fmt: fmt, isActive: false)),
        ],
      );
    },
  ),
);
  }
}

class _ReservationTile extends StatelessWidget {
  const _ReservationTile({
    required this.record,
    required this.fmt,
    required this.isActive,
  });

  final ReservationRecord record;
  final DateFormat fmt;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (record.status) {
      ReservationHistoryStatus.active => AppColors.success,
      ReservationHistoryStatus.completed => AppColors.info,
      ReservationHistoryStatus.expired => AppColors.warning,
      ReservationHistoryStatus.cancelled => AppColors.grey500,
    };
    final statusLabel = switch (record.status) {
      ReservationHistoryStatus.active => 'نشط',
      ReservationHistoryStatus.completed => 'مكتمل',
      ReservationHistoryStatus.expired => 'منتهٍ',
      ReservationHistoryStatus.cancelled => 'ملغى',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: AppPadding.allLg,
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: AppColors.success.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.size10Bold.copyWith(color: statusColor),
                ),
              ),
              const Spacer(),
              Text(record.spotCode, style: AppTextStyles.size12Bold),
            ],
          ),
          AppPadding.verticalSpaceSm,
          Text(record.locationName, style: AppTextStyles.size11Grey),
          AppPadding.verticalSpaceSm,
          Row(
            children: [
              const Icon(Icons.directions_car, size: 16, color: AppColors.grey600),
              const SizedBox(width: 6),
              Text(record.plate, style: AppTextStyles.size10Grey),
            ],
          ),
          AppPadding.verticalSpaceSm,
          Text(
            'من ${fmt.format(record.startTime)} إلى ${fmt.format(record.endTime)}',
            style: AppTextStyles.size9Grey,
          ),
          if (isActive && record.remaining.inMinutes >= 0) ...[
            AppPadding.verticalSpaceSm,
            Text(
              'متبقّي: ${record.remaining.inHours} س ${record.remaining.inMinutes.remainder(60)} د',
              style: AppTextStyles.size10Bold.copyWith(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
