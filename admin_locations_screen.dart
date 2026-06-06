import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/router/routes.dart';
import 'package:park_mind_x/core/utils/extension_router.dart';
import 'package:park_mind_x/core/widgets/button_app.dart';
import 'package:park_mind_x/features/admin/presentation/admin_ui.dart';
import 'package:park_mind_x/features/admin/presentation/cubits/admin_cubit.dart';
import 'package:park_mind_x/features/parking/data/models/parking_location_summary.dart';
import 'package:park_mind_x/features/parking/presentation/cubits/parking_cubit.dart';

class AdminLocationsScreen extends StatelessWidget {
  const AdminLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminUi.pageBg,
        appBar: const AdminGradientAppBar(title: 'الأماكن والمواقف'),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushNamed(Routes.adminAddLocation),
          backgroundColor: AdminUi.shell,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('مكان جديد', style: TextStyle(color: Colors.white)),
        ),
        body: BlocConsumer<AdminCubit, AdminState>(
          listenWhen: (p, c) =>
              c is AdminReady &&
              c.feedbackMessage != null &&
              (p is! AdminReady || p.feedbackMessage != c.feedbackMessage),
          listener: (context, state) {
            if (state is! AdminReady || state.feedbackMessage == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.feedbackMessage!, textDirection: TextDirection.rtl),
                backgroundColor:
                    state.feedbackIsError ? AppColors.error : AppColors.success,
              ),
            );
            context.read<AdminCubit>().clearFeedback();
            context.read<ParkingCubit>().load();
          },
          builder: (context, state) {
            if (state is! AdminReady) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.separated(
              padding: AppPadding.allLg.copyWith(bottom: 88),
              itemCount: state.locations.length,
              separatorBuilder: (_, __) => AppPadding.verticalSpaceSm,
              itemBuilder: (context, index) {
                return _LocationAdminCard(location: state.locations[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _LocationAdminCard extends StatelessWidget {
  const _LocationAdminCard({required this.location});

  final ParkingLocationSummary location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.allLg,
      decoration: AdminUi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location.name, style: AppTextStyles.size12Bold),
          if (location.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(location.subtitle, style: AppTextStyles.size10Grey),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip('${location.totalSpots} موقف'),
              _chip('${location.availableToBook} متاح'),
              _chip('${location.occupiedCount} مشغول'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AdminUi.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: AppTextStyles.size9.copyWith(color: AdminUi.shell)),
    );
  }
}
