import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/router/routes.dart';
import 'package:park_mind_x/core/utils/extension_router.dart';
import 'package:park_mind_x/features/parking/presentation/cubits/parking_cubit.dart';
import 'package:park_mind_x/features/parking/presentation/parking_ui.dart';
import 'package:park_mind_x/features/parking/presentation/screens/parking_location_detail_screen.dart';

/// قائمة أماكن ليبية مع تصميم محدّث.
class ParkingMainScreen extends StatefulWidget {
  const ParkingMainScreen({super.key});

  @override
  State<ParkingMainScreen> createState() => _ParkingMainScreenState();
}

class _ParkingMainScreenState extends State<ParkingMainScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: ParkingGradientAppBar(
          title: 'مواقف ليبيا',
          actions: [
            TextButton.icon(
              onPressed: () => context.pushNamed(Routes.parkingVerify),
              icon: const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
              label: Text('تحقق', style: AppTextStyles.size11White),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: ParkingUi.pageBackgroundGradient()),
          child: BlocBuilder<ParkingCubit, ParkingState>(
            builder: (context, state) {
              if (state is! ParkingReady) {
                return const Center(child: CircularProgressIndicator());
              }
              final locations = state.visibleLocations;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppPadding.allLg.copyWith(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر مكاناً لعرض المواقف والحجز',
                            style: AppTextStyles.size11Grey.copyWith(height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          ParkingStatsStrip(
                            available: state.availableForBookingCount,
                            occupied: state.occupiedCount,
                            reserved: state.spots
                                .where(
                                  (s) =>
                                      s.hasConfirmedReservation ||
                                      s.hasPendingReservation,
                                )
                                .length,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: ParkingUi.searchDecoration(),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (v) =>
                                  context.read<ParkingCubit>().setSearchQuery(v),
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                hintText:
                                    'بحث: طرابلس، نوفلين، جامعة، أندلس، قرقارش…',
                                hintStyle: AppTextStyles.size10Grey,
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final loc = locations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ParkingLocationHeroCard(
                              location: loc,
                              themeIndex: loc.themeIndex,
                              onTap: () => context.push(
                                ParkingLocationDetailScreen(
                                  locationId: loc.id,
                                  locationName: loc.name,
                                  locationSubtitle: loc.subtitle,
                                  themeIndex: loc.themeIndex,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: locations.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
