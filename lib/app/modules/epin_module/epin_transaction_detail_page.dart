import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/epin_module/epin_transaction_detail_controller.dart';
import 'package:mcd/core/utils/date_util.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/busy_button.dart';

class EpinTransactionDetailPage
    extends GetView<EpinTransactionDetailController> {
  const EpinTransactionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
          title: "Transaction Detail", centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const Gap(30),
            _buildTransactionCard(),
            const Gap(30),
            BusyButton(
              title: "Share receipt",
              onTap: controller.shareReceipt,
            ),
            const Gap(20),
            _buildActionButtons(),
            const Gap(30),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Network Image
          if (controller.networkImage.isNotEmpty)
            Image.asset(
              controller.networkImage,
              height: 70,
              width: 70,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.phone_android, size: 70),
            ),
          const Gap(10),
          Text(
            controller.networkName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Gap(5),
          Text(
            '-₦${controller.amount}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green[700], size: 18),
                    const Gap(5),
                    Text(
                      'Successful',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(30),
          _buildDetailRow('Network Type', controller.networkName),
          _buildDetailRow('Design Type', controller.designType),
          _buildDetailRow('Quantity', controller.quantity),
          _buildDetailRow('Payment method', controller.paymentMethod),
          const Gap(20),
          _buildDetailRow('Transaction ID:', controller.transactionId,
              isFullWidth: true),
          // _buildDetailRow('Posted date:', controller.postedDate, isFullWidth: true),
          _buildDetailRow('Transaction date:',
              DateUtil.formatDateTime(controller.transactionDate),
              isFullWidth: true),
          _buildDetailRow('Token:', controller.token, isFullWidth: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isFullWidth = false}) {
    if (isFullWidth) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: TextSemiBold(label, fontSize: 14),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextSemiBold(label, fontSize: 15),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
            Icons.download, 'Download', controller.downloadReceipt),
        _buildActionButton(Icons.refresh, 'Buy again', controller.buyAgain),
        _buildActionButton(
            Icons.repeat, 'Add to recurring', controller.addToRecurring),
        _buildActionButton(
            Icons.help_outline, 'Support', controller.contactSupport),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF5ABB7B)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF5ABB7B), size: 24),
            const Gap(5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
