import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_mind_x/core/constants/app_padding.dart';
import 'package:park_mind_x/core/constants/app_text_styles.dart';
import 'package:park_mind_x/core/router/routes.dart';
import 'package:park_mind_x/core/utils/extension_router.dart';
import 'package:park_mind_x/features/admin/data/models/admin_user_model.dart';
import 'package:park_mind_x/features/admin/presentation/admin_ui.dart';
import 'package:park_mind_x/features/admin/presentation/cubits/admin_cubit.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminUi.pageBg,
        appBar: const AdminGradientAppBar(title: 'المستخدمون'),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is! AdminReady) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = state.visibleUsers;
            return Column(
              children: [
                Padding(
                  padding: AppPadding.allLg,
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => context.read<AdminCubit>().setUserSearch(v),
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم، اللوحة، الهاتف، الرقم الجامعي…',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: AppPadding.horizontalLg.copyWith(bottom: 24),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => AppPadding.verticalSpaceSm,
                    itemBuilder: (context, index) {
                      return _UserCard(
                        user: users[index],
                        onTap: () => context.pushNamed(
                          Routes.adminUserDetail,
                          arguments: users[index].id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});

  final AdminUserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: AdminUi.cardDecoration(),
          child: Padding(
            padding: AppPadding.allLg,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AdminUi.accent.withOpacity(0.2),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : '?',
                    style: AppTextStyles.size12Bold.copyWith(color: AdminUi.shell),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTextStyles.size12Bold),
                      Text(
                        '${user.plateNumber} · ${user.phone}',
                        style: AppTextStyles.size10Grey,
                      ),
                      Text(
                        'محفظة: ${user.walletBalance.toStringAsFixed(1)} د.ل',
                        style: AppTextStyles.size10Primary,
                      ),
                    ],
                  ),
                ),
                if (!user.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('موقوف', style: AppTextStyles.size9),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
