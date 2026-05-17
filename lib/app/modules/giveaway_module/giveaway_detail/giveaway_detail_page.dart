import 'package:mcd/core/import/imports.dart';
import 'package:intl/intl.dart';
import 'giveaway_detail_controller.dart';

import '../giveaway_module_controller.dart';

class GiveawayDetailPage extends GetView<GiveawayDetailController> {
  const GiveawayDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextSemiBold(
          'Giveaway Details',
          fontSize: 18,
          color: Colors.black,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
        ),
        actions: [
          Obx(() {
            final detail = controller.detail.value;
            if (detail == null) return const SizedBox.shrink();

            final currentUsername =
                controller.box.read('biometric_username_real') ?? '';
            final isOwnGiveaway =
                detail.giveaway.userName.trim().toLowerCase() ==
                    currentUsername.trim().toLowerCase();

            if (!isOwnGiveaway) return const SizedBox.shrink();

            return IconButton(
              onPressed: () {
                if (Get.isRegistered<GiveawayModuleController>()) {
                  Get.find<GiveawayModuleController>()
                      .shareGiveaway(detail.giveaway.id);
                }
              },
              icon: const Icon(Icons.share, color: Colors.black, size: 20),
              tooltip: 'Share Giveaway',
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        final detail = controller.detail.value;
        if (detail == null) {
          return const Center(child: Text('No details found'));
        }

        final giveaway = detail.giveaway;
        final giver = detail.giver;
        final requesters = detail.requesters;
        final currentUsername =
            controller.box.read('biometric_username_real') ?? '';
        final isOwnGiveaway = giveaway.userName.trim().toLowerCase() ==
            currentUsername.trim().toLowerCase();

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Giveaway Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: giveaway.image.isNotEmpty
                            ? Image.network(
                                giveaway.image,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: AppColors.primaryGrey.withOpacity(0.1),
                                  child: const Icon(Icons.image,
                                      size: 50, color: AppColors.primaryGrey),
                                ),
                              )
                            : Container(
                                color: AppColors.primaryGrey.withOpacity(0.1),
                                child: const Icon(Icons.image,
                                    size: 50, color: AppColors.primaryGrey),
                              ),
                      ),
                    ),
                    const Gap(24),

                    // Giveaway Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextBold(
                                giveaway.type.toUpperCase(),
                                fontSize: 24,
                                color: AppColors.primaryColor,
                              ),
                              TextSemiBold(
                                '₦${giveaway.amount}',
                                fontSize: 18,
                                color: AppColors.primaryGrey2,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: giveaway.status == 1
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextSemiBold(
                            giveaway.status == 1 ? 'Active' : 'Expired',
                            color: giveaway.status == 1
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Text(
                      giveaway.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primaryGrey2,
                        fontFamily: AppFonts.manRope,
                        height: 1.5,
                      ),
                    ),
                    const Gap(32),

                    // Giver Details Section
                    _buildSectionHeader('Giver Info'),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.filledInputColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: giver.photo.isNotEmpty
                                ? NetworkImage(giver.photo)
                                : null,
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.1),
                            child: giver.photo.isEmpty
                                ? const Icon(Icons.person,
                                    color: AppColors.primaryColor)
                                : null,
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextBold(giver.fullName, fontSize: 16),
                                if (giver.companyName.isNotEmpty)
                                  TextSemiBold(giver.companyName,
                                      fontSize: 12,
                                      color: AppColors.primaryColor),
                                TextSemiBold('@${giver.userName}',
                                    fontSize: 13,
                                    color: AppColors.primaryGrey2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(32),

                    // Statistics Section
                    _buildSectionHeader('Statistics'),
                    const Gap(12),
                    Row(
                      children: [
                        _buildStatCard('Quantity', giveaway.quantity.toString(),
                            Icons.inventory_2_outlined),
                        const Gap(16),
                        _buildStatCard('Claimed', requesters.length.toString(),
                            Icons.people_outline),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        _buildStatCard('Views', giveaway.views.toString(),
                            Icons.visibility_outlined),
                        const Gap(16),
                        _buildStatCard(
                            'Remaining',
                            (giveaway.quantity - requesters.length)
                                .clamp(0, giveaway.quantity)
                                .toString(),
                            Icons.hourglass_empty),
                      ],
                    ),
                    const Gap(32),

                    // Claimants List
                    _buildSectionHeader('Recent Claimants'),
                    const Gap(12),
                    if (requesters.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No claims yet. Be the first!',
                              style: TextStyle(color: AppColors.primaryGrey2)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requesters.length,
                        separatorBuilder: (c, i) => const Gap(12),
                        itemBuilder: (c, i) {
                          final req = requesters[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      AppColors.primaryGrey.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  child: const Icon(Icons.person,
                                      size: 16, color: AppColors.primaryColor),
                                ),
                                const Gap(12),
                                Expanded(
                                  child:
                                      TextSemiBold(req.userName, fontSize: 14),
                                ),
                                Text(
                                  _formatDate(req.createdAt),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryGrey2),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const Gap(40),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            if (!detail.completed && giveaway.status == 1)
              Padding(
                padding: const EdgeInsets.all(20),
                child: isOwnGiveaway
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGrey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primaryGrey.withOpacity(0.25)),
                        ),
                        child: const Text(
                          'This is your giveaway',
                          style: TextStyle(
                            fontFamily: AppFonts.manRope,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGrey2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : BusyButton(
                        title: 'Claim Giveaway',
                        onTap: () => controller.claimGiveaway(),
                      ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return TextBold(title, fontSize: 16, color: Colors.black87);
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryGrey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 20),
            const Gap(8),
            TextBold(value, fontSize: 18),
            const Gap(4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primaryGrey2)),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
