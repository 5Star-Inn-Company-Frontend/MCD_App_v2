import 'package:mcd/app/modules/history_screen_module/history_screen_controller.dart';
import 'package:mcd/app/utils/bottom_navigation.dart';
import 'package:mcd/app/widgets/app_bar.dart';
import 'package:mcd/app/widgets/skeleton_loader.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/utils/functions.dart';
import 'package:collection/collection.dart' show ListExtensions;
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as dev;

class HistoryScreenPage extends GetView<HistoryScreenController> {
  const HistoryScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context) ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PaylonyAppBar(
          title: "Transaction History",
          actions: [
            Obx(() => controller.isDownloadingStatement
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () => _showDownloadDialog(context),
                      child: TextSemiBold(
                        'Download Statement',
                        fontSize: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )),
          ],
        ),
        body: RefreshIndicator(
          color: AppColors.primaryColor,
          backgroundColor: AppColors.white,
          onRefresh: controller.refreshTransactions,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Obx(() => GestureDetector(
                            onTap: () => _showTypeFilterDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: TextBold(
                                      controller.typeFilter,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      size: 20)
                                ],
                              ),
                            ),
                          )),
                    ),
                    Flexible(
                      child: Obx(() => GestureDetector(
                            onTap: () => _showStatusDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: TextBold(
                                      controller.statusFilter,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      size: 20)
                                ],
                              ),
                            ),
                          )),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () => _showDatePicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextBold(
                                "Date",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const Icon(Icons.calendar_month, size: 20)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(30),
                Divider(color: AppColors.placeholderColor.withOpacity(0.6)),
                const Gap(6),
                Obx(() => Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "In ",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: AppFonts.manRope),
                              ),
                              TextSpan(
                                text: "₦",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: Functions.money(controller.totalIn, "")
                                    .trim(),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: AppFonts.manRope),
                              ),
                            ],
                          ),
                        ),
                        const Gap(10),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Out ",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: AppFonts.manRope),
                              ),
                              TextSpan(
                                text: "₦",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: Functions.money(controller.totalOut, "")
                                    .trim(),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: AppFonts.manRope),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const Gap(10),
                Divider(color: AppColors.placeholderColor.withOpacity(0.6)),
                Expanded(
                  child: Obx(() {
                    // show skeleton while loading
                    if (controller.isLoading) {
                      return const SkeletonTransactionList(itemCount: 6);
                    }

                    final transactions = controller.filteredTransactions;

                    if (transactions.isEmpty) {
                      return Center(
                        child: TextSemiBold('No transactions found'),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!controller.isLoadingMore &&
                            controller.hasMorePages &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                          // Load more when user is 200 pixels from bottom
                          controller.loadMoreTransactions();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: transactions.length +
                            (controller.hasMorePages ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show loading indicator at the bottom
                          if (index == transactions.length) {
                            return Obx(() => controller.isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink());
                          }

                          final transaction = transactions[index];
                          final icon =
                              controller.getTransactionIcon(transaction);
                          return _transactionCard(
                            context,
                            transaction.type,
                            icon,
                            transaction.amountValue,
                            transaction.formattedTime,
                            transaction,
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
      ),
    );
  }

  void _showTypeFilterDialog(BuildContext context) {
    final types = [
      'All',
      'Airtime',
      'Data',
      'Cable',
      'Electricity',
      'Betting',
      'Transfer'
    ];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            content: SizedBox(
              width: double.infinity,
              child: Wrap(
                children: [
                  Stack(
                    children: [
                      Center(
                          child: TextBold(
                        "Filter By Type",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                      Positioned(
                          top: 0,
                          right: 2,
                          child: TouchableOpacity(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(
                                Icons.clear,
                                color: AppColors.background,
                              )))
                    ],
                  ),
                  Column(
                    children: types
                        .map((type) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 10),
                            child: TouchableOpacity(
                              onTap: () {
                                controller.typeFilter = type;
                                Navigator.pop(context);
                              },
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 5),
                                  child: TextSemiBold(
                                    type,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  )),
                            )))
                        .toList(),
                  )
                ],
              ),
            ),
          );
        });
  }

  void _showStatusDialog(BuildContext context) {
    final statuses = [
      'All Status',
      'Pending',
      'Successful',
      'Reversed',
      'Delivered'
    ];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            content: SizedBox(
              width: double.infinity,
              child: Wrap(
                children: [
                  Stack(
                    children: [
                      Center(
                          child: TextBold(
                        "Filter By Status",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                      Positioned(
                          top: 0,
                          right: 2,
                          child: TouchableOpacity(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(
                                Icons.clear,
                                color: AppColors.background,
                              )))
                    ],
                  ),
                  Column(
                    children: statuses
                        .map((status) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 10),
                            child: TouchableOpacity(
                              onTap: () {
                                controller.statusFilter = status;
                                Navigator.pop(context);
                              },
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 5),
                                  child: TextSemiBold(
                                    status,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  )),
                            )))
                        .toList(),
                  )
                ],
              ),
            ),
          );
        });
  }

  void _showDatePicker(BuildContext context) {
    DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime toDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: TextBold(
                'Filter by Date Range',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSemiBold('From Date',
                      fontSize: 14, color: AppColors.primaryGrey2),
                  const Gap(8),
                  InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: fromDate,
                        firstDate: DateTime(2020),
                        lastDate: toDate,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primaryColor,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (selectedDate != null) {
                        setState(() => fromDate = selectedDate);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryGrey2.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 14, fontFamily: AppFonts.manRope),
                          ),
                          const Icon(Icons.calendar_today,
                              size: 20, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  TextSemiBold('To Date',
                      fontSize: 14, color: AppColors.primaryGrey2),
                  const Gap(8),
                  InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: toDate,
                        firstDate: fromDate,
                        lastDate: DateTime.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primaryColor,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (selectedDate != null) {
                        setState(() => toDate = selectedDate);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryGrey2.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 14, fontFamily: AppFonts.manRope),
                          ),
                          const Icon(Icons.calendar_today,
                              size: 20, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    controller.clearDateFilter();
                    Navigator.pop(context);
                  },
                  child: TextSemiBold('Clear', color: AppColors.primaryGrey2),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: TextSemiBold('Cancel', color: AppColors.primaryGrey2),
                ),
                ElevatedButton(
                  onPressed: () {
                    final fromStr =
                        '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';
                    final toStr =
                        '${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}';
                    Navigator.pop(context);
                    controller.setDateRange(fromStr, toStr);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  child: TextSemiBold('Apply', color: AppColors.white),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDownloadDialog(BuildContext context) {
    DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime toDate = DateTime.now();
    String selectedFormat = 'pdf';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: TextBold(
                'Download Statement',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSemiBold(
                    'From Date',
                    fontSize: 14,
                    color: AppColors.primaryGrey2,
                  ),
                  const Gap(8),
                  InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: fromDate,
                        firstDate: DateTime(2020),
                        lastDate: toDate,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (selectedDate != null) {
                        setState(() {
                          fromDate = selectedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryGrey2.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 14, fontFamily: AppFonts.manRope),
                          ),
                          const Icon(Icons.calendar_today,
                              size: 20, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  TextSemiBold(
                    'To Date',
                    fontSize: 14,
                    color: AppColors.primaryGrey2,
                  ),
                  const Gap(8),
                  InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: toDate,
                        firstDate: fromDate,
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (selectedDate != null) {
                        setState(() {
                          toDate = selectedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryGrey2.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 14, fontFamily: AppFonts.manRope),
                          ),
                          const Icon(Icons.calendar_today,
                              size: 20, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  TextSemiBold(
                    'Format',
                    fontSize: 14,
                    color: AppColors.primaryGrey2,
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: TextSemiBold('PDF'),
                          value: 'pdf',
                          groupValue: selectedFormat,
                          activeColor: AppColors.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              selectedFormat = value!;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: TextSemiBold('Excel'),
                          value: 'excel',
                          groupValue: selectedFormat,
                          activeColor: AppColors.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              selectedFormat = value!;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: TextSemiBold('Cancel', color: AppColors.primaryGrey2),
                ),
                ElevatedButton(
                  onPressed: () {
                    final fromDateStr =
                        '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';
                    final toDateStr =
                        '${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}';

                    Navigator.pop(context);
                    controller.downloadStatement(
                      fromDateStr,
                      toDateStr,
                      selectedFormat,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: TextSemiBold('Download', color: AppColors.white),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _transactionCard(
    BuildContext context,
    String title,
    String image,
    double amount,
    String time,
    dynamic transaction,
  ) {
    // get status from transaction
    String status = 'pending';
    Color statusColor = Colors.orange;
    try {
      status = (transaction.status ?? 'pending').toString().toLowerCase();
      if (status == 'delivered' ||
          status == 'successful' ||
          status == 'success') {
        statusColor = Colors.green;
      } else if (status == 'failed' || status == 'error') {
        statusColor = Colors.red;
      } else {
        statusColor = Colors.orange;
      }
    } catch (_) {}

    return ListTile(
      onTap: () {
        try {
          dev.log('Transaction selected: ${transaction.ref}',
              name: 'HistoryScreen');
        } catch (e) {
          dev.log('Transaction selected (error): $transaction',
              name: 'HistoryScreen');
        }

        // Pass complete transaction data to details screen
        Get.toNamed(
          Routes.TRANSACTION_DETAIL_MODULE,
          arguments: {
            'transaction': transaction, // Pass entire transaction object
          },
        );
      },
      contentPadding: EdgeInsets.zero,
      leading: Image.asset(
        image,
        width: 40,
        height: 40,
      ),
      title: TextSemiBold(_toTitleCase(title)),
      subtitle: TextSemiBold(time),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "₦",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: Functions.money(amount, "").trim(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: AppFonts.manRope),
                ),
              ],
            ),
          ),
          const Gap(4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
                fontFamily: AppFonts.manRope,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: TextSemiBold('Exit App'),
        content: TextSemiBold('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: TextSemiBold('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: TextSemiBold('Yes'),
          ),
        ],
      ),
    );
  }

  // convert string to title case, preserve all-caps words like MTN, GLO
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      // preserve all-uppercase words (e.g. MTN, GLO, DSTV)
      if (word == word.toUpperCase() && word.length > 1) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
