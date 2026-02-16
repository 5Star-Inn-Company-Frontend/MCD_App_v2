import 'package:mcd/core/import/imports.dart';
import './a2c_module_controller.dart';

class A2CModulePage extends GetView<A2CModuleController> {
  const A2CModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Airtime to cash',
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                'Fill out the form below and transfer the airtime to the shown phone number',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryColor,
                                  fontFamily: AppFonts.manRope
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(10),
                      Text(
                            '(MTN Charges: 20% AIRTEL Charges: 20%)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryGrey2,
                              fontFamily: AppFonts.manRope
                            ),
                          ),
                      const Gap(20),

                      // Network Selection
                      TextSemiBold(
                        'Select Network',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: controller.networks
                            .map((network) => _networkCard(network))
                            .toList(),
                      ),
                      const Gap(25),

                      // Amount Input
                      TextSemiBold(
                        'Enter amount to send',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(10),
                      TextFormField(
                        controller: controller.amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontFamily: AppFonts.manRope,
                        ),
                        decoration: InputDecoration(
                          hintText: 'NGR 50,000',
                          hintStyle: const TextStyle(
                            color: AppColors.placeholderColor,
                            fontFamily: AppFonts.manRope,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGrey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGrey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const Gap(25),

                      // Sender Phone Number
                      TextSemiBold(
                        'Enter sender phone number',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(10),
                      TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontFamily: AppFonts.manRope,
                        ),
                        decoration: InputDecoration(
                          hintText: '0124567890',
                          hintStyle: const TextStyle(
                            color: AppColors.placeholderColor,
                            fontFamily: AppFonts.manRope,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGrey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGrey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length != 11) {
                            return 'Please enter a valid 11-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const Gap(25),

                      // Payment Method Selection
                      TextSemiBold(
                        'Select where to receive payment',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryGrey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _paymentMethodCard('MCD Wallet', 'wallet'),
                            const Gap(8),
                            Divider(color: AppColors.primaryGrey),
                            const Gap(8),
                            _paymentMethodCard('Bank', 'bank'),
                          ],
                        ),
                      ),
                      const Gap(20),

                      // Bank Details (shown when bank is selected)
                      Obx(() => controller.selectedPaymentMethod == 'bank'
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextSemiBold(
                                  'Select bank',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  style: const TextStyle(fontFamily: AppFonts.manRope),
                                ),
                                const Gap(10),
                                Obx(() {
                                  if (controller.isLoadingBanks) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primaryGrey,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                return InkWell(
                                  onTap: () {
                                    if (controller.banks.isEmpty) {
                                      controller.fetchBanks();
                                    }
                                    _showBankSelector(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primaryGrey,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Obx(() => Text(
                                              controller.selectedBank.value
                                                      ?.name ??
                                                  'Choose bank',
                                              style: TextStyle(
                                                color: controller.selectedBank
                                                            .value !=
                                                        null
                                                    ? Colors.black
                                                    : AppColors
                                                        .placeholderColor,
                                                fontFamily: AppFonts.manRope,
                                                fontSize: 15,
                                              ),
                                            )),
                                        const Icon(
                                          Icons.keyboard_arrow_right,
                                          color: AppColors.primaryGrey2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const Gap(20),
                              TextSemiBold(
                                'Enter Account Number',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                style: const TextStyle(fontFamily: AppFonts.manRope),
                              ),
                              const Gap(10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          controller.accountNumberController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontFamily: AppFonts.manRope,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0000000000',
                                        hintStyle: const TextStyle(
                                          color: AppColors.placeholderColor,
                                          fontFamily: AppFonts.manRope,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryGrey,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryGrey,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (controller.selectedPaymentMethod ==
                                            'bank') {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter account number';
                                          }
                                          if (value.length != 10) {
                                            return 'Account number must be 10 digits';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const Gap(8),
                                  InkWell(
                                    onTap: () {
                                      if (controller.accountNumberController.text.length == 10 && 
                                          controller.selectedBank.value != null) {
                                        controller.verifyBankAccount();
                                      } else {
                                        Get.snackbar(
                                          "Error", 
                                          controller.selectedBank.value == null 
                                              ? "Please select a bank first"
                                              : "Please enter a valid 10-digit account number", 
                                          backgroundColor: AppColors.errorBgColor, 
                                          colorText: AppColors.textSnackbarColor,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: AppColors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              Obx(() {
                                if (controller.isVerifyingAccount) {
                                  return Row(
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const Gap(8),
                                      Text(
                                        'Verifying account...',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primaryColor,
                                          fontFamily: AppFonts.manRope,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                if (controller.accountName != null) {
                                  return Text(
                                    '${controller.accountName}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primaryGrey2,
                                      fontFamily: AppFonts.manRope,
                                    ),
                                  );
                                }

                                return Text(
                                  '(validated name will appear here)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.placeholderColor,
                                    fontFamily: AppFonts.manRope,
                                  ),
                                );
                              }),
                              const Gap(20),
                            ],
                          )
                          : const SizedBox.shrink()),

                      const Spacer(),
                      const Gap(30),
                      Obx(() => BusyButton(
                            title: 'Continue',
                            isLoading: controller.isConverting,
                            onTap: controller.convertAirtime,
                          )),
                      const Gap(20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _networkCard(String network) {
    return Obx(() => TouchableOpacity(
          onTap: () => controller.selectedNetwork = network,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.selectedNetwork == network
                    ? AppColors.primaryColor
                    : Colors.transparent,
                width: controller.selectedNetwork == network ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              controller.networkImages[network] ?? AppAsset.mtn,
              width: 60,
              height: 60,
            ),
          ),
        ));
  }

  Widget _paymentMethodCard(String title, String value) {
    return Obx(() => TouchableOpacity(
          onTap: () {
            controller.selectedPaymentMethod = value;
            if (value == 'bank' && controller.banks.isEmpty) {
              controller.fetchBanks();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500, fontFamily: AppFonts.manRope,
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: controller.selectedPaymentMethod == value
                        ? AppColors.primaryColor
                        : AppColors.primaryGrey2,
                    width: 2,
                  ),
                ),
                child: controller.selectedPaymentMethod == value
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ));
  }

  void _showBankSelector(BuildContext context) {
    // Reset search when opening modal
    controller.bankSearchQuery = '';
    controller.bankSearchController.clear();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.primaryGrey),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextBold(
                        'Select Bank',
                        fontSize: 18,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: controller.bankSearchController,
                    onChanged: (value) {
                      controller.bankSearchQuery = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search bank...',
                      hintStyle: TextStyle(
                        color: AppColors.placeholderColor,
                        fontFamily: AppFonts.manRope,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primaryGrey2,
                      ),
                      filled: true,
                      fillColor: AppColors.filledInputColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingBanks) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    if (controller.banks.isEmpty) {
                      return Center(
                        child: TextSemiBold(
                          'No banks available',
                          style: const TextStyle(fontFamily: AppFonts.manRope),
                        ),
                      );
                    }

                    final filteredBanks = controller.filteredBanks;
                    
                    if (filteredBanks.isEmpty) {
                      return Center(
                        child: TextSemiBold(
                          'No banks found',
                          style: const TextStyle(fontFamily: AppFonts.manRope),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
                        return ListTile(
                          title: Text(
                            bank.name,
                            style: const TextStyle(
                              fontFamily: AppFonts.manRope,
                            ),
                          ),
                          onTap: () {
                            controller.selectedBank.value = bank;
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }
}