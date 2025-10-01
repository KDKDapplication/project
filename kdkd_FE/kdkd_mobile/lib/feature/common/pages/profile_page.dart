import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiState profile = ref.watch(profileProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConst.padding, vertical: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                profile.dataOrNull?.profileImageUrl != null && profile.dataOrNull!.profileImageUrl!.isNotEmpty
                    ? NetworkImage(profile.dataOrNull!.profileImageUrl!)
                    : const AssetImage('assets/images/kids_duck.png') as ImageProvider,
          ),
          SizedBox(
            height: 24,
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.basicShadow,
                  blurRadius: 11.8,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '내정보',
                  style: AppFonts.titleMedium,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '이름',
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        profile.dataOrNull?.name ?? '이름 없음',
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '이메일',
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        profile.dataOrNull?.email ?? '이메일 없음',
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '나이',
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        profile.dataOrNull?.age != null ? '만 ${profile.dataOrNull!.age}세' : '나이 없음',
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '생일',
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatBirthdate(profile.dataOrNull?.birthdate),
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBirthdate(DateTime? birthdate) {
    if (birthdate == null) return '생일 없음';

    const months = [
      '',
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];

    return '${months[birthdate.month]} ${birthdate.day}일';
  }
}
