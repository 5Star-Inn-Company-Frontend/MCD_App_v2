import 'package:mcd/core/import/imports.dart';

import './qrcode_transfer_module_controller.dart';

class QrcodeTransferModulePage extends GetView<QrcodeTransferModuleController> {
  const QrcodeTransferModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: 'Transfer',
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Scan the other party's QR Code to transfer",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFonts.manRope,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Gap(30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.SCAN_QRCODE_MODULE);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/scan_icon.svg',
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    height: 20,
                  ),
                  label: const Text(
                    'Scan QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: AppFonts.manRope,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (controller.savedQRCodes.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(40),
                    TextSemiBold(
                      "Saved QR Contacts",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const Gap(15),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.savedQRCodes.length,
                        separatorBuilder: (_, __) => const Gap(16),
                        itemBuilder: (context, index) {
                          final contact = controller.savedQRCodes[index];
                          final nickname = contact['nickname']?.toString() ?? 'Unknown';
                          
                          return GestureDetector(
                            onTap: () => controller.selectSavedQRCode(contact),
                            onLongPress: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Delete Contact'),
                                  content: Text('Are you sure you want to delete "$nickname"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        controller.deleteSavedQRCode(index);
                                        Get.back();
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                )
                              );
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.qr_code,
                                      color: AppColors.primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  nickname,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: AppFonts.manRope,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
