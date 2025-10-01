import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/modal/custom_popup_modal.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/feature/common/models/notification_list_model.dart';
import 'package:kdkd_mobile/feature/common/providers/notification_provider.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationListProvider);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "알림",
          actionType: AppBarActionType.none,
        ),
        body: Stack(
          children: [
            notificationState.when(
              idle: () => const Center(child: Text('알림을 불러오는 중...')),
              loading: () => const Center(child: CircularProgressIndicator()),
              success: (data, isFallback, fromCache) => RefreshIndicator(
                onRefresh: () => ref.read(notificationListProvider.notifier).fetchNotifications(isRefresh: true),
                child: data.alerts.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        itemCount: data.alerts.length,
                        itemBuilder: (context, index) {
                          final notification = data.alerts[index];
                          return _buildNotificationItem(notification);
                        },
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.grayBorder,
                        ),
                      ),
              ),
              failure: (error, message) => RefreshIndicator(
                onRefresh: () => ref.read(notificationListProvider.notifier).fetchNotifications(isRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('오류가 발생했습니다: ${message ?? error.toString()}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(notificationListProvider.notifier).fetchNotifications(),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 전체 삭제 버튼
            if (notificationState is Success<NotificationListResponse> && notificationState.data.alerts.isNotEmpty)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => _showDeleteAllDialog(),
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.delete_sweep,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => ref.read(notificationListProvider.notifier).fetchNotifications(isRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '알림이 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.senderName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _formatDate(notification.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    CustomPopupModal.show(
      context: context,
      popupType: PopupType.completeAndDelete,
      confirmText: "삭제",
      confirmText2: "취소",
      onConfirm: () {
        Navigator.of(context).pop();
        ref.read(notificationListProvider.notifier).deleteAllNotifications();
      },
      onConfirm2: () => Navigator.of(context).pop(),
      child: const Column(
        children: [
          Text(
            '알림 전체 삭제',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '모든 알림을 삭제하시겠습니까?\n삭제된 알림은 복구할 수 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
