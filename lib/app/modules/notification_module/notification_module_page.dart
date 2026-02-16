import 'package:intl/intl.dart';
import 'package:mcd/app/modules/notification_module/notification_module_controller.dart';
import 'package:mcd/app/modules/notification_module/model/notification_model.dart';
import 'package:mcd/app/widgets/skeleton_loader.dart';
import 'package:mcd/core/import/imports.dart';

class NotificationModulePage extends GetView<NotificationModuleController> {
  const NotificationModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaylonyAppBarTwo(
        title: 'Notifications',
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: TextSemiBold('Mark all as read',
                fontSize: 12, color: AppColors.primaryColor),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: controller.fetchNotifications,
          child: Column(
            children: [
              // filter pills
              _buildFilterPills(),
              const Gap(10),
              // notifications list
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: List.generate(
                          6,
                          (index) => const SkeletonNotificationItem(),
                        ),
                      ),
                    );
                  }

                  if (controller.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 64, color: AppColors.primaryGrey),
                          const Gap(16),
                          TextSemiBold('No notifications yet',
                              color: AppColors.primaryGrey),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return _buildNotificationTile(notification);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    return Obx(() {
      final allGroups = ['', ...controller.groups];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: allGroups.map((group) {
            final isSelected = controller.selectedGroup.value == group;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: TextSemiBold(
                  controller.formatGroupName(group),
                  fontSize: 12,
                  color:
                      isSelected ? AppColors.white : AppColors.textPrimaryColor,
                ),
                selected: isSelected,
                onSelected: (_) => controller.onGroupSelected(group),
                backgroundColor: AppColors.white,
                selectedColor: AppColors.primaryColor,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.primaryGrey,
                ),
                showCheckmark: false,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildNotificationTile(NotificationItem notification) {
    final isUnread = !notification.isRead;
    final isPriority = notification.data.priority == 'high';
    final hasActions = notification.data.actions.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primaryColor.withOpacity(0.05) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // circle indicator with green badge for unread
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGrey.withOpacity(0.1),
                ),
                child: Icon(
                  _getNotificationIcon(notification.data.group),
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
              // green badge for unread
              if (isUnread)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(12),
          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextBold(
                        notification.data.title,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isPriority)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HIGH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            fontFamily: AppFonts.manRope,
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(6),
                Text(
                  notification.data.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimaryColor.withOpacity(0.8),
                    fontFamily: AppFonts.manRope,
                  ),
                ),
                const Gap(8),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGrey,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
                // action buttons
                if (hasActions) ...[
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: notification.data.actions.map((action) {
                      return OutlinedButton(
                        onPressed: () => _handleAction(action.action),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(color: AppColors.primaryColor),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          action.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String group) {
    switch (group) {
      case 'account_security':
        return Icons.security;
      case 'money':
        return Icons.account_balance_wallet;
      case 'support_service':
        return Icons.support_agent;
      case 'updates_offers':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  void _handleAction(String action) {
    // remove # prefix if present
    final cleanAction = action.startsWith('#') ? action.substring(1) : action;

    switch (cleanAction) {
      case 'open_security_center':
        Get.toNamed(Routes.SETTINGS_SCREEN);
        break;
      case 'open_history':
        Get.toNamed(Routes.HISTORY_SCREEN);
        break;
      default:
        Get.snackbar(
          'Action',
          'Action: $cleanAction',
          backgroundColor: AppColors.primaryColor,
          colorText: AppColors.white,
        );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays < 7) {
      return '${DateFormat('EEEE').format(date)} at ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
