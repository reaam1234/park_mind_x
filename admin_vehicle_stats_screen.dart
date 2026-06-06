import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/theme/app_theme.dart';
import 'package:park_mind_x/features/admin/presentation/admin_ui.dart';
import 'package:park_mind_x/features/parking/presentation/cubits/parking_cubit.dart';
import 'package:park_mind_x/features/reservations/data/models/reservation_record.dart';

/// لوحة إحصائيات حركة المركبات للمسؤولين.
class AdminVehicleStatsScreen extends StatelessWidget {
  const AdminVehicleStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: context.pageBackground,
  appBar: const AdminGradientAppBar(title: 'إحصائيات حركة المركبات'),
  body: BlocBuilder<ParkingCubit, ParkingState>(
    builder: (context, state) {
      if (state is! ParkingReady) {
        return const Center(child: CircularProgressIndicator());
      }
      final stats = state.vehicleStats;
      final maxHourly = stats.hourlyEntries.fold<int>(
        1,
        (a, b) => a > b ? a : b,
      );

      return ListView(
        padding: AppPadding.allLg,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '${stats.totalEntriesToday}',
                  label: 'دخول اليوم',
                  icon: Icons.login_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  value: '${stats.totalExitsToday}',
                  label: 'خروج اليوم',
                  icon: Icons.logout_rounded,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          AppPadding.verticalSpaceSm,
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '${stats.currentlyParked}',
                  label: 'مركبات حالياً',
                  icon: Icons.directions_car,
                  color: AdminUi.shell,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  value: '${stats.activeReservations}',
                  label: 'حجوزات نشطة',
                  icon: Icons.event_available,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          AppPadding.verticalSpaceLg,
          Text('حركة الدخول حسب الساعة (اليوم)', style: AppTextStyles.size12Bold),
          AppPadding.verticalSpaceSm,
          Container(
            padding: AppPadding.allLg,
            decoration: AdminUi.cardDecoration(context),
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (h) {
                final count = stats.hourlyEntries[h];
                final height = (count / maxHourly) * 100;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (count > 0)
                          Text('$count', style: AppTextStyles.size8Grey),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: height.clamp(4, 100),
                          decoration: BoxDecoration(
                            color: AdminUi.shell.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (h % 4 == 0)
                          Text('$h', style: AppTextStyles.size8Grey),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          AppPadding.verticalSpaceLg,
          Text('آخر الأحداث', style: AppTextStyles.size12Bold),
          AppPadding.verticalSpaceSm,
          ...stats.recentEvents.map((e) => _EventTile(event: e)),
        ],
      );
    },
  ),
);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.allMd,
      decoration: AdminUi.cardDecoration(context),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          AppPadding.verticalSpaceSm,
          Text(value, style: AppTextStyles.size14Bold.copyWith(color: color)),
          Text(label, style: AppTextStyles.size9Grey, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final VehicleMovementEvent event;

  @override
  Widget build(BuildContext context) {
    final isEnter = event.type == VehicleMovementType.enter;
    final fmt = DateFormat('HH:mm', 'ar');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: AppPadding.allMd,
      decoration: AdminUi.cardDecoration(context),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: (isEnter ? AppColors.success : AppColors.info)
                .withOpacity(0.15),
            child: Icon(
              isEnter ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: isEnter ? AppColors.success : AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnter ? 'دخول مركبة' : 'خروج مركبة',
                  style: AppTextStyles.size11Bold,
                ),
                Text(
                  '${event.plate} · ${event.spotCode} · ${event.locationName}',
                  style: AppTextStyles.size9Grey,
                ),
              ],
            ),
          ),
          Text(fmt.format(event.timestamp), style: AppTextStyles.size9Grey),
        ],
      ),
    );
  }
}
