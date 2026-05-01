import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import '../giveaway_module_controller.dart';
import '../models/giveaway_model.dart';

class GiveawayDetailSheet extends StatelessWidget {
  final int giveawayId;
  final GiveawayModuleController controller = Get.find<GiveawayModuleController>();

  GiveawayDetailSheet({super.key, required this.giveawayId});

  @override
  Widget build(BuildContext context) {
    // cache the future to prevent re-fetching on rebuild
    final detailFuture = controller.fetchGiveawayDetail(giveawayId);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: FutureBuilder<GiveawayDetailModel?>(
        future: detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: AppColors.primaryGrey2),
                  const Gap(16),
                  const Text(
                    'Failed to load giveaway details',
                    style: TextStyle(fontFamily: AppFonts.manRope, fontSize: 16),
                  ),
                  const Gap(20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final detail = snapshot.data!;
          final currentUsername = controller.box.read('biometric_username_real') ?? '';
          final isOwnGiveaway = detail.giveaway.userName.trim().toLowerCase() ==
              currentUsername.trim().toLowerCase();

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Image
                if (detail.giver.photo.isNotEmpty)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(detail.giver.photo),
                    backgroundColor: const Color(0xffF3FFF7),
                  )
                else
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xffF3FFF7),
                    child: Icon(Icons.person, size: 50, color: AppColors.primaryGrey2),
                  ),
                const Gap(12),
                TextSemiBold(
                  '@${detail.giveaway.userName}',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                const Gap(8),
                Text(
                  detail.giveaway.description,
                  style: const TextStyle(fontSize: 14, color: AppColors.primaryGrey2),
                  textAlign: TextAlign.center,
                ),
                const Gap(20),
                // Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xffF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffE5E5E5)),
                  ),
                  child: Column(
                    children: [
                      _detailRow('Type', detail.giveaway.type.toUpperCase()),
                      const Divider(height: 20, color: Color(0xffE5E5E5)),
                      _detailRow('Provider', detail.giveaway.typeCode.toUpperCase()),
                      const Divider(height: 20, color: Color(0xffE5E5E5)),
                      _detailRowAmount('Amount',
                          '₦${AmountUtil.formatFigure(double.tryParse(detail.giveaway.amount.toString()) ?? 0)}'),
                      const Divider(height: 20, color: Color(0xffE5E5E5)),
                      _detailRow('User', '${detail.requesters.length}/${detail.giveaway.quantity}'),
                    ],
                  ),
                ),
                const Gap(20),
                // Claim button
                if (!detail.completed && detail.giveaway.status == 1)
                  isOwnGiveaway
                      ? _statusBanner('This is your giveaway', AppColors.primaryGrey2)
                      : SizedBox(
                          width: double.infinity,
                          child: BusyButton(
                            title: "Claim",
                            onTap: () {
                              Get.back(); // Close sheet
                              controller.showAdClaimDialogFirst(
                                  giveawayId, detail.giveaway.type, context);
                            },
                          ),
                        )
                else
                  _statusBanner('This giveaway has been fully claimed', Colors.orange),
                const Gap(20),
                controller.adsService.showBannerAdWidget(),
                const Gap(20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextSemiBold(label, fontSize: 14, color: AppColors.primaryGrey2),
        TextSemiBold(value, fontSize: 14, fontWeight: FontWeight.w600),
      ],
    );
  }

  Widget _detailRowAmount(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextSemiBold(label, fontSize: 14, color: AppColors.primaryGrey2),
        TextSemiBold(value, fontSize: 14, style: GoogleFonts.plusJakartaSans(), fontWeight: FontWeight.w600),
      ],
    );
  }

  Widget _statusBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}
