import 'package:flutter/services.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:mcd/core/utils/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import './transaction_detail_module_controller.dart';

class TransactionDetailModulePage
    extends GetView<TransactionDetailModuleController> {
  const TransactionDetailModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PaylonyAppBarTwo(
        title: "Transaction Detail",
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () => Get.offAllNamed(Routes.HOME_SCREEN),
              child: TextSemiBold(
                'Go Home',
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          RepaintBoundary(
            key: controller.receiptKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 12),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(AppAsset.spiralBg), fit: BoxFit.fill)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Material(
                    elevation: 2,
                    color: AppColors.white,
                    shadowColor: const Color(0xff000000).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Image(
                            image: AssetImage(controller.image),
                            width: 50,
                            height: 50,
                          ),
                          const Gap(8),
                          TextSemiBold(
                            controller.name,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          const Gap(6),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "₦",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: Functions.money(controller.amount, "")
                                      .trim(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily: AppFonts.manRope,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_outlined,
                                color: AppColors.primaryColor,
                              ),
                              const Gap(4),
                              TextSemiBold(
                                "Successful",
                                color: AppColors.primaryColor,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const Gap(8),

                  // Show token for electricity, E-PIN, JAMB, and result checker payments
                  if (((controller.paymentType.toLowerCase() == "electricity" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('electric')) ||
                          (controller.paymentType.toLowerCase() ==
                                  "airtime pin" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('airtime_pin')) ||
                          controller.paymentType.toLowerCase() == "jamb" ||
                          controller.paymentType
                              .toLowerCase()
                              .contains('jamb') ||
                          controller.paymentType.toLowerCase() ==
                              "resultchecker" ||
                          controller.paymentType
                              .toLowerCase()
                              .contains('result')) &&
                      controller.token.isNotEmpty &&
                      controller.token != 'N/A')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          elevation: 2,
                          color: AppColors.white,
                          shadowColor: const Color(0xff000000).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextSemiBold(controller.paymentType
                                        .toLowerCase()
                                        .contains('pin')
                                    ? "E-PIN"
                                    : "Token"),
                                const Gap(8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.token,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFonts.manRope),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(
                                            text: controller.token));
                                        Get.snackbar(
                                          "Copied",
                                          controller.paymentType
                                                  .toLowerCase()
                                                  .contains('pin')
                                              ? "E-PIN copied to clipboard"
                                              : "Token copied to clipboard",
                                          backgroundColor: AppColors
                                              .primaryColor
                                              .withOpacity(0.1),
                                          colorText: AppColors.primaryColor,
                                          snackPosition: SnackPosition.TOP,
                                          duration: const Duration(seconds: 2),
                                          margin: const EdgeInsets.all(10),
                                          icon: const Icon(Icons.check_circle,
                                              color: AppColors.primaryColor),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextSemiBold("Copy",
                                            color: AppColors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(8),
                      ],
                    ),

                  Material(
                    elevation: 2,
                    color: AppColors.white,
                    shadowColor: const Color(0xff000000).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          itemRow("User ID", controller.userId),
                          // Show Meter Number for electricity, Phone Number for others
                          if (controller.paymentType.toLowerCase() ==
                                  "electricity" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('electric'))
                            itemRow("Meter Number", controller.phoneNumber)
                          else if (controller.paymentType.toLowerCase() ==
                                  "betting" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('bet'))
                            itemRow("Account ID", controller.phoneNumber)
                          else if (controller.paymentType.toLowerCase() !=
                                  "airtime pin" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('airtime_pin') &&
                              controller.paymentType.toLowerCase() !=
                                  "data pin" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('data_pin') &&
                              controller.paymentType.toLowerCase() !=
                                  "wallet_funding" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('wallet') &&
                              controller.paymentType.toLowerCase() !=
                                  "giveaway" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('giveaway') &&
                              controller.paymentType.toLowerCase() !=
                                  "vCard Funding" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('funding') &&
                              controller.paymentType.toLowerCase() !=
                                  "vCard Creation Fee" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('vcard') 
                            )
                            itemRow("Phone Number", controller.phoneNumber),

                          // Airtime PIN-specific fields
                          if (controller.paymentType.toLowerCase() ==
                                  "airtime pin" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('airtime_pin')) ...[
                            if (controller.network.isNotEmpty)
                              itemRow("Network", controller.network),
                            if (controller.quantity != '1')
                              itemRow("Quantity", controller.quantity),
                          ],

                          // Data PIN-specific fields
                          if (controller.paymentType.toLowerCase() ==
                                  "data pin" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('data_pin')) ...[
                            if (controller.network.isNotEmpty)
                              itemRow("Network", controller.network),
                            if (controller.quantity != '1')
                              itemRow("Quantity", controller.quantity),
                          ],

                          // Data-specific fields
                          if (controller.paymentType.toLowerCase() ==
                              "data") ...[
                            // if (controller.packageName != ' N/A')
                            //   itemRow("Data Plan", controller.packageName),
                            if (controller.network.isNotEmpty)
                              itemRow("Network", controller.network),
                          ],

                          // Cable TV-specific fields
                          if (controller.paymentType.toLowerCase() ==
                                  "cable tv" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('cable')) ...[
                            if (controller.customerName != 'N/A')
                              itemRow("Customer Name", controller.customerName),
                            if (controller.packageName != 'N/A')
                              itemRow("Package", controller.packageName),
                          ],

                          // Electricity-specific fields
                          if (controller.paymentType.toLowerCase() ==
                                  "electricity" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('electric')) ...[
                            if (controller.customerName != 'N/A')
                              itemRow("Customer Name", controller.customerName),
                            if (controller.packageName != 'N/A')
                              itemRow("Meter Type", controller.packageName),
                          ],

                          // Betting-specific fields
                          if (controller.paymentType.toLowerCase() ==
                                  "betting" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('bet')) ...[
                            if (controller.network.isNotEmpty)
                              itemRow("Betting Platform", controller.network),
                            // itemRow("Account ID", controller.phoneNumber),
                          ],

                          // JAMB-specific fields
                          if (controller.paymentType.toLowerCase() == "jamb" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('jamb')) ...[
                            itemRow("Biller Name", controller.billerName),
                            if (controller.packageName != 'N/A')
                              itemRow("Type", controller.packageName),
                          ],

                          // Result Checker-specific fields
                          if (controller.paymentType.toLowerCase() ==
                                  "resultchecker" ||
                              controller.paymentType
                                  .toLowerCase()
                                  .contains('result')) ...[
                            if (controller.billerName != 'N/A')
                              itemRow("Biller Name", controller.billerName),
                            if (controller.packageName != 'N/A')
                              itemRow("Type", controller.packageName),
                          ],

                          // NIN Validation-specific fields
                          if (controller.paymentType == "NIN Validation") ...[
                            itemRow("NIN Number", controller.userId),
                            itemRow("Service Type", controller.packageName),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: AppColors.primaryColor, size: 16),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      "Response will be available within 24 hours",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          itemRow("Payment Type", controller.paymentType),
                          itemRow("Payment Method",
                              _formatPaymentMethod(controller.paymentMethod)),
                          if (controller.status.isNotEmpty)
                            itemRow("Status", controller.status.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                  const Gap(8),
                  Material(
                    elevation: 2,
                    color: AppColors.white,
                    shadowColor: const Color(0xff000000).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          itemRowWithCopy(
                              "Transaction ID:", controller.transactionId),
                          // itemRow("Posted date:", controller.date),
                          itemRow("Transaction date:", controller.date),
                        ],
                      ),
                    ),
                  ),

                  if (controller.description.isNotEmpty) ...[
                    const Gap(8),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        elevation: 2,
                        color: AppColors.white,
                        shadowColor: const Color(0xff000000).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextSemiBold(
                                "Description",
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              const Gap(8),
                              Text(
                                controller.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                  fontFamily: AppFonts.manRope,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Obx(
            () => controller.isSharing
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    child: BusyButton(
                      title: "Share Receipt",
                      onTap: () => controller.shareReceipt(),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => controller.isDownloading
                    ? const Padding(
                        padding: EdgeInsets.all(15),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : actionButtons(() => controller.downloadReceipt(),
                        SvgPicture.asset(AppAsset.downloadIcon), "Download")),
                Obx(() => controller.isRepeating
                    ? const Padding(
                        padding: EdgeInsets.all(15),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : actionButtons(() => controller.repeatTransaction(),
                        SvgPicture.asset(AppAsset.redoIcon), "Buy Again")),
                actionButtons(() {
                  Get.toNamed(
                    '/recurring_transactions_module',
                    arguments: {
                      'ref': controller.transactionId,
                      'name': controller.name,
                      'amount': controller.amount,
                    },
                  );
                }, SvgPicture.asset(AppAsset.rotateIcon), "Add to recurring"),
                actionButtons(() async {
                  try {
                    final authController = Get.find<LoginScreenController>();
                    final username =
                        authController.dashboardData?.user.userName ?? 'User';
                    final reference = controller.transactionId;
                    String mail =
                        "mailto:info@5starcompany.com.ng?subject=Support Needed on $reference&body=Hi, my username is $username, I will like to ";
                    await launcher.launchUrl(Uri.parse(mail));
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Could not open email client',
                      backgroundColor: AppColors.errorBgColor,
                      colorText: AppColors.textSnackbarColor,
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                }, SvgPicture.asset(AppAsset.helpIcon), "Support"),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper widgets can remain in the view file
  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'wallet':
        return 'MCD Wallet';
      case 'paystack':
        return 'Paystack';
      case 'general_market':
        return 'General Market';
      case 'mega_bonus':
        return 'Mega Bonus';
      case 'bank':
        return 'Bank';
      default:
        return method;
    }
  }

  Widget itemRow(String name, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextSemiBold(name, fontSize: 15, fontWeight: FontWeight.w500),
          const Gap(8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget itemRowWithCopy(String name, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextSemiBold(name, fontSize: 15, fontWeight: FontWeight.w500),
          const Gap(8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                  ),
                ),
                const Gap(8),
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    Get.snackbar(
                      "Copied",
                      "Transaction ID copied to clipboard",
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      colorText: AppColors.primaryColor,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(10),
                      icon: const Icon(Icons.check_circle,
                          color: AppColors.primaryColor),
                    );
                  },
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButtons(VoidCallback onTap, Widget item, String name) {
    return Column(
      children: [
        InkWell(
          // Added InkWell for tap effect
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15), // Used all for uniform padding
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(5)),
            child: item,
          ),
        ),
        const Gap(5),
        TextSemiBold(name, fontSize: 13, fontWeight: FontWeight.w600)
      ],
    );
  }
}
