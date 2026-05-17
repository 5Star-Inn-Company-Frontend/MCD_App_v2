import 'package:flutter/services.dart';
import 'package:mcd/app/modules/transaction_detail_module/receipt_template.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:mcd/core/utils/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/core/utils/date_util.dart';
import './transaction_detail_module_controller.dart';
import './receipt_preview_page.dart';

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
                          Builder(
                            builder: (context) {
                              final status = controller.status.toLowerCase();
                              // final isSuccessful = status == 'successful' ||
                              //     status == 'success' ||
                              //     status == 'delivered';
                              final isPending =
                                  status == 'pending' || status == 'processing';
                              final isReversed =
                                  status == 'reversed' || status == 'reversal';
                              final isFailed =
                                  status == 'failed' || status == 'error';

                              Color statusColor = AppColors.primaryColor;
                              IconData statusIcon =
                                  Icons.check_circle_outline_outlined;
                              String statusText = 'Successful';

                              if (isPending) {
                                statusColor = Colors.orange;
                                statusIcon = Icons.pending_outlined;
                                statusText = 'Pending';
                              } else if (isReversed) {
                                statusColor = Colors.blue;
                                statusIcon = Icons.sync_outlined;
                                statusText = 'Reversed';
                              } else if (isFailed) {
                                statusColor = Colors.red;
                                statusIcon = Icons.cancel_outlined;
                                statusText = 'Failed';
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                  ),
                                  const Gap(4),
                                  TextSemiBold(
                                    statusText,
                                    color: statusColor,
                                  )
                                ],
                              );
                            },
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
                          if (controller.paymentType.toLowerCase() == "electricity" ||
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
                                  .contains('vcard') &&
                              controller.paymentType.toLowerCase() !=
                                  "reversal" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('reversal') &&
                              controller.paymentType.toLowerCase() !=
                                  "predictwin" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('predictwin') &&
                              controller.paymentType.toLowerCase() != "momo" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('momo') &&
                              controller.paymentType.toLowerCase() !=
                                  "nin validation" &&
                              !controller.paymentType
                                  .toLowerCase()
                                  .contains('nin validation'))
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
                            if (controller.designType != 'N/A' &&
                                controller.designType.isNotEmpty)
                              itemRow("Design Type", controller.designType),
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
                            if (controller.designType != 'N/A' &&
                                controller.designType.isNotEmpty)
                              itemRow("Design Type", controller.designType),
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
                            itemRow("Biller Name", controller.name),
                            Obx(() => controller.customerName != 'N/A'
                                ? itemRow(
                                    "Customer Name", controller.customerName)
                                : const SizedBox.shrink()),
                            Obx(() => controller.customerAddress != 'N/A'
                                ? itemRow("Customer Address",
                                    controller.customerAddress)
                                : const SizedBox.shrink()),
                            Obx(() => controller.kwUnits != 'N/A'
                                ? itemRow("Units", controller.kwUnits)
                                : const SizedBox.shrink()),
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

                          // Balance information (for all services)
                          Obx(() =>
                              (controller.isSharing || controller.isDownloading)
                                  ? const SizedBox.shrink()
                                  : Column(
                                      children: [
                                        if (controller.initialAmount != 'N/A')
                                          itemRow("Initial Balance",
                                              "₦${controller.initialAmount}"),
                                        if (controller.finalAmount != 'N/A')
                                          itemRow("Final Balance",
                                              "₦${controller.finalAmount}"),
                                      ],
                                    )),

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
                          if (controller.paymentType
                              .toLowerCase()
                              .contains('nin')) ...[
                            itemRow(
                                "NIN Number",
                                controller.ninNin != 'N/A'
                                    ? controller.ninNin
                                    : controller.phoneNumber),

                            // NIN Details Section
                            Obx(() {
                              // check if any NIN data is available
                              // final hasNinData =
                              //     controller.ninSurname != 'N/A' ||
                              //         controller.ninFirstName != 'N/A' ||
                              //         controller.ninMiddleName != 'N/A';

                              // if (!hasNinData) {
                              //   return Container(
                              //     margin: const EdgeInsets.symmetric(
                              //         horizontal: 12, vertical: 10),
                              //     padding: const EdgeInsets.all(10),
                              //     decoration: BoxDecoration(
                              //       color:
                              //           AppColors.primaryColor.withOpacity(0.1),
                              //       borderRadius: BorderRadius.circular(5),
                              //     ),
                              //     child: Row(
                              //       children: [
                              //         Icon(Icons.access_time,
                              //             color: AppColors.primaryColor,
                              //             size: 16),
                              //         const Gap(8),
                              //         Expanded(
                              //           child: Text(
                              //             "Response will be available within 24 hours",
                              //             style: TextStyle(
                              //                 fontSize: 13,
                              //                 color: AppColors.primaryColor),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   );
                              // }

                              return Column(
                                children: [
                                  itemRow("Surname", controller.ninSurname),
                                  itemRow(
                                      "First Name", controller.ninFirstName),
                                  itemRow(
                                      "Middle Name", controller.ninMiddleName),
                                  itemRow("Gender",
                                      controller.ninGender.toUpperCase()),
                                  itemRow(
                                      "Date of Birth", controller.ninBirthDate),
                                  itemRow("Phone Number",
                                      controller.ninPhoneNumber),
                                  itemRow("State of Origin",
                                      controller.ninStateOfOrigin),
                                  itemRow("State of Residence",
                                      controller.ninStateOfResidence),
                                  itemRow("Educational Level",
                                      controller.ninEducationalLevel),
                                  itemRow("Marital Status",
                                      controller.ninMaritalStatus),
                                  itemRow(
                                      "Profession", controller.ninProfession),
                                ],
                              );
                            }),
                          ],

                          itemRow("Payment Type", controller.paymentType),
                          Obx(() => controller.paymentMethod.isNotEmpty
                              ? itemRow(
                                  "Payment Method",
                                  _formatPaymentMethod(
                                      controller.paymentMethod))
                              : const SizedBox.shrink()),
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
                          itemRow("Transaction date:",
                              DateUtil.formatDateTime(controller.date)),
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

          // Epin Design Cards
          Obx(() {
            // Read observables eagerly so GetX always registers a subscription
            final epins = controller.epins;
            final isFetching = controller.isFetchingDetail;

            // Show loader while fetching epin data from API
            if (controller.isEpinTransaction && isFetching) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(30),
                    TextSemiBold(
                      'Your PINs',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    const Gap(12),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryColor,
                              strokeWidth: 2.5,
                            ),
                            Gap(12),
                            Text(
                              'Loading PIN details...',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!controller.isEpinTransaction || epins.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextSemiBold(
                        'Your PIN${epins.length > 1 ? 's' : ''}',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      GestureDetector(
                        onTap: () => controller.shareAllEpins(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share,
                                size: 18, color: AppColors.primaryColor),
                            const Gap(4),
                            Text(
                              'Share All',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  SizedBox(
                    height: epins.length == 1 ? null : 320,
                    child: epins.length == 1
                        ? _buildEpinCard(epins.first, 0)
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: epins.length,
                            itemBuilder: (context, index) {
                              return _buildEpinCard(epins[index], index);
                            },
                          ),
                  ),
                ],
              ),
            );
          }),

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
          ),

          // receipt template selector
          _ReceiptStyleSection(controller: controller),
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

  // ── Epin Design Card ──

  Widget _buildEpinCard(Map<String, dynamic> epin, int index) {
    final network = epin['network']?.toString().toUpperCase() ??
        controller.networkCode ??
        'MTN';
    final dialCode = controller.getDialCodeFor(network);
    final networkLogo = controller.getNetworkLogoFor(network);

    final pin = epin['pin']?.toString() ?? '';
    final refNo = epin['refNo']?.toString() ?? '';
    final expiry = epin['expiry']?.toString() ?? '';
    final serial = epin['serial']?.toString() ?? '';
    final hasDetails = pin.isNotEmpty ||
        refNo.isNotEmpty ||
        expiry.isNotEmpty ||
        serial.isNotEmpty;

    return RepaintBoundary(
      key: controller.getEpinCardKey(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Design background image - stretched to fit content
                  Positioned.fill(
                    child: Image.asset(
                      controller.designImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Content overlay
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Network logo + Username + Amount
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Network logo
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                networkLogo,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Spacer(),
                            // Username
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                controller.username,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Amount
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '₦${epin['amount'] ?? ''}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (hasDetails) ...[
                          const Gap(20),

                          // PIN
                          if (pin.isNotEmpty) ...[
                            _buildEpinRow('PIN:', pin, isBold: true),
                            const Gap(10),
                          ],

                          // Ref No
                          if (refNo.isNotEmpty) ...[
                            _buildEpinRow('Ref No:', refNo),
                            const Gap(10),
                          ],

                          // Expiry Date
                          if (expiry.isNotEmpty) ...[
                            _buildEpinRow('Expiry Date:', expiry),
                            const Gap(10),
                          ],

                          // Serial No
                          if (serial.isNotEmpty) ...[
                            _buildEpinRow('Serial No:', serial),
                          ],
                        ] else
                          const Gap(20),

                        const Gap(16),

                        // Dial code + Share button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              dialCode,
                              style: GoogleFonts.courierPrime(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.shareSingleEpin(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.share,
                                        size: 14, color: Colors.white),
                                    const Gap(4),
                                    Text(
                                      'Share',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEpinRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Receipt Style Selector ──

class _ReceiptStyleSection extends StatelessWidget {
  final TransactionDetailModuleController controller;
  const _ReceiptStyleSection({required this.controller});

  static final _templates = [
    (
      ReceiptTemplate.receipt,
      'assets/icons/receipts/receipt.png',
      'Receipt',
      const Color(0xFFD6F0DC), // light green bg
    ),
    (
      ReceiptTemplate.wishes,
      'assets/icons/receipts/wishes.png',
      'Wishes',
      const Color(0xFFFDD87A), // yellow bg
    ),
    (
      ReceiptTemplate.birthday,
      'assets/icons/receipts/birthday.png',
      'Birthday',
      const Color(0xFFF9A8D4), // pink gradient start
    ),
    (
      ReceiptTemplate.valentine,
      'assets/icons/receipts/valentine.png',
      'Valentine',
      const Color(0xFFF9A8D4), // pink bg
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Choose Receipt Style',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _templates.map((t) {
              return _ReceiptOptionCard(
                template: t.$1,
                iconPath: t.$2,
                label: t.$3,
                bgColor: t.$4,
                controller: controller,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ReceiptOptionCard extends StatelessWidget {
  final ReceiptTemplate template;
  final String iconPath;
  final String label;
  final Color bgColor;
  final TransactionDetailModuleController controller;

  const _ReceiptOptionCard({
    required this.template,
    required this.iconPath,
    required this.label,
    required this.bgColor,
    required this.controller,
  });

  Decoration _topDecoration() {
    if (template == ReceiptTemplate.birthday) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF472B6), Color(0xFFFDA4AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      );
    }
    return BoxDecoration(
      color: bgColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedTemplate == template;
      return GestureDetector(
        onTap: () {
          controller.selectedTemplate = template;
          Get.to(
            () =>
                ReceiptPreviewPage(template: template, controller: controller),
            transition: Transition.cupertino,
          );
        },
        child: SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: [
                      // colored top with icon
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: _topDecoration(),
                          child: Center(
                            child: Image.asset(
                              iconPath,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      // green label bar
                      Container(
                        width: double.infinity,
                        height: 32,
                        color: const Color(0xFF5ABB7B),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // checkmark badge when selected
              if (isSelected)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5ABB7B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
