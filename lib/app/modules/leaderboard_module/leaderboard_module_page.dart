import 'package:mcd/app/modules/leaderboard_module/leaderboard_module_controller.dart';
import 'package:mcd/app/modules/leaderboard_module/models/leaderboard_model.dart';
import 'package:mcd/app/widgets/skeleton_loader.dart';
import 'package:mcd/core/import/imports.dart';

class LeaderboardModulePage extends GetView<LeaderboardModuleController> {
  const LeaderboardModulePage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PaylonyAppBarTwo(
        title: 'Leaderboard',
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Obx(() => TextSemiBold(
                    'My Rank: ${controller.leaderboardData?.rank ?? 0}',
                    fontSize: 14,
                    color: Colors.black,
                  )),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.leaderboardData == null) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top 3 Podium Skeleton
                  SizedBox(
                    height: 260,
                    child: Stack(
                      children: [
                        // Second Place
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Gap(40),
                              const SkeletonLoader(
                                  width: 110, height: 180, borderRadius: 12),
                            ],
                          ),
                        ),
                        // First Place
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SkeletonLoader(
                                    width: 32, height: 32, borderRadius: 16),
                                const Gap(8),
                                const SkeletonLoader(
                                    width: 110, height: 220, borderRadius: 12),
                              ],
                            ),
                          ),
                        ),
                        // Third Place
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Gap(40),
                              const SkeletonLoader(
                                  width: 110, height: 180, borderRadius: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  // List Skeleton
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const SkeletonLoader(
                          width: double.infinity, height: 70, borderRadius: 8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.leaderboardData == null ||
            controller.leaderboardData!.leaderboard.isEmpty) {
          return const Center(
            child: Text('No leaderboard data available',
                style: TextStyle(fontSize: 14, fontFamily: AppFonts.manRope)),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshLeaderboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top 3 Users Podium
                  _buildTopThreePodium(),
                  const Gap(24),

                  // Remaining Users List
                  _buildRemainingUsersList(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTopThreePodium() {
    final topThree = controller.topThree;

    if (topThree.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get users by rank
    final firstPlace = topThree.firstWhere((user) => user.rank == 1,
        orElse: () => topThree.first);
    final secondPlace = topThree.firstWhere((user) => user.rank == 2,
        orElse: () => topThree.length > 1 ? topThree[1] : firstPlace);
    final thirdPlace = topThree.firstWhere((user) => user.rank == 3,
        orElse: () => topThree.length > 2 ? topThree[2] : firstPlace);

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Second Place (Left)
          Positioned(
            left: 0,
            bottom: 0,
            child: _buildPodiumCard(
              user: secondPlace,
              color: AppColors.primaryColor,
              height: 180,
              showCrown: false,
            ),
          ),

          // First Place (Center)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: _buildPodiumCard(
                user: firstPlace,
                color: const Color(0xFFFFA726),
                height: 220,
                showCrown: true,
              ),
            ),
          ),

          // Third Place (Right)
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildPodiumCard(
              user: thirdPlace,
              color: const Color(0xFF4DD0E1),
              height: 180,
              showCrown: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard({
    required LeaderboardUser user,
    required Color color,
    required double height,
    required bool showCrown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCrown) ...[
          const Icon(
            Icons.emoji_events,
            color: Color(0xFFFFA726),
            size: 32,
          ),
          const Gap(8),
        ] else
          const Gap(40),
        Container(
          width: 110,
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
                backgroundColor: Colors.white,
                child: user.avatar.isEmpty
                    ? Icon(Icons.person, size: 28, color: color)
                    : null,
              ),
              const Gap(8),
               TextSemiBold(
                user.fullName,
                fontSize: 12,
                color: AppColors.white,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(4),
              TextSemiBold(
                _maskUsername(user.userName),
                fontSize: 11,
                color: AppColors.white,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(4),
              TextSemiBold(
                '${user.pointsValue}',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingUsersList() {
    final remainingUsers = controller.remainingUsers;

    if (remainingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: remainingUsers.map((user) {
        return _buildUserListItem(user);
      }).toList(),
    );
  }

  Widget _buildUserListItem(LeaderboardUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryGrey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: TextSemiBold(
              '${user.rank}',
              fontSize: 14,
              color: AppColors.primaryGrey,
            ),
          ),
          const Gap(12),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage:
                user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            child: user.avatar.isEmpty
                ? Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.primaryColor,
                  )
                : null,
          ),
          const Gap(12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSemiBold(
                  user.fullName ?? 'N/A',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Text(
                  '@${_maskUsername(user.userName)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGrey,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
              ],
            ),
          ),

          // Points
          TextSemiBold(
            '${user.pointsValue}',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  // mask username: mask only the last 3 characters
  String _maskUsername(String username) {
    if (username.length <= 3) return '${username}***';
    return '${username.substring(0, username.length - 3)}***';
  }
}
