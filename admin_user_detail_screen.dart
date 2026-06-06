import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_colors.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/features/admin/presentation/admin_ui.dart';
import 'package:park_mind_x/features/admin/presentation/cubits/admin_cubit.dart';

class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AdminCubit>().userById(userId);
    if (user == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: const AdminGradientAppBar(title: 'تفاصيل المستخدم'),
          body: const Center(child: Text('المستخدم غير موجود')),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminUi.pageBg,
        appBar: const AdminGradientAppBar(title: 'تفاصيل المستخدم'),
        body: SingleChildScrollView(
          padding: AppPadding.allLg,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: AppPadding.allLg,
                decoration: AdminUi.cardDecoration(),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AdminUi.shell.withOpacity(0.15),
                      child: Text(
                        user.name[0],
                        style: AppTextStyles.size14Bold.copyWith(
                          color: AdminUi.shell,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    AppPadding.verticalSpaceMd,
                    Text(user.name, style: AppTextStyles.size14Bold),
                    Text(user.email, style: AppTextStyles.size11Grey),
                    if (!user.isActive) ...[
                      AppPadding.verticalSpaceSm,
                      Text(
                        'حساب موقوف',
                        style: AppTextStyles.size11.copyWith(color: AppColors.warning),
                      ),
                    ],
                  ],
                ),
              ),
              AppPadding.verticalSpaceMd,
              Container(
                width: double.infinity,
                padding: AppPadding.allLg,
                decoration: AdminUi.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('البيانات الشخصية', style: AppTextStyles.size12Bold),
                    const Divider(),
                    AdminInfoRow(
                      label: 'الهاتف',
                      value: user.phone,
                      icon: Icons.phone,
                    ),
                    AdminInfoRow(
                      label: 'الرقم الجامعي',
                      value: user.studentId,
                      icon: Icons.badge,
                    ),
                    AdminInfoRow(
                      label: 'الكلية',
                      value: user.college,
                      icon: Icons.school,
                    ),
                  ],
                ),
              ),
              AppPadding.verticalSpaceMd,
              Container(
                width: double.infinity,
                padding: AppPadding.allLg,
                decoration: AdminUi.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('المركبة', style: AppTextStyles.size12Bold),
                    const Divider(),
                    AdminInfoRow(
                      label: 'رقم اللوحة',
                      value: user.plateNumber,
                      icon: Icons.directions_car,
                    ),
                  ],
                ),
              ),
              AppPadding.verticalSpaceMd,
              Container(
                width: double.infinity,
                padding: AppPadding.allLg,
                decoration: AdminUi.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('المحفظة', style: AppTextStyles.size12Bold),
                    const Divider(),
                    AdminInfoRow(
                      label: 'الرصيد الحالي',
                      value: '${user.walletBalance.toStringAsFixed(2)} د.ل',
                      icon: Icons.account_balance_wallet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
