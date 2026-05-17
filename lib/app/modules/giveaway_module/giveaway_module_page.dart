import 'package:google_fonts/google_fonts.dart';
import 'widgets/giveaway_detail_sheet.dart';
import 'package:mcd/core/import/imports.dart';
import './giveaway_module_controller.dart';

class GiveawayModulePage extends GetView<GiveawayModuleController> {
  const GiveawayModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaylonyAppBarTwo(
        title: "Giveaway",
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => Get.toNamed(Routes.HISTORY_SCREEN),
              child: TextSemiBold(
                "History",
                fontWeight: FontWeight.w700,
                fontSize: 18,
                style: const TextStyle(fontFamily: AppFonts.manRope),
              ),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          backgroundColor: AppColors.white,
          onRefresh: controller.fetchGiveaways,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.background,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextSemiBold(
                              "You have ${controller.myGiveawayCount} giveaways",
                              style:
                                  const TextStyle(fontFamily: AppFonts.manRope),
                            ),
                            InkWell(
                              onTap: () => Get.toNamed(Routes.CREATE_GIVEAWAY),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(5)),
                                child: TextSemiBold(
                                  "Create giveaway",
                                  color: AppColors.white,
                                  style: const TextStyle(
                                      fontFamily: AppFonts.manRope),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Gap(5),
                      controller.adsService.showBannerAdWidget(),
                      Obx(() => AnimatedCrossFade(
                            duration: const Duration(milliseconds: 500),
                            crossFadeState: controller.isNotificationEnabled
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Column(
                              children: [
                                const Gap(20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primaryColor
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.notifications_active_outlined,
                                          color: AppColors.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextSemiBold(
                                              "Enable Notifications",
                                              fontSize: 14,
                                              color: AppColors.textPrimaryColor,
                                            ),
                                            const Gap(2),
                                            GestureDetector(
                                              onTap: () => controller
                                                  .enableNotifications(),
                                              child: Text(
                                                "Get notified when new giveaways are posted. Click here to enable.",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: AppFonts.manRope,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Gap(30),
                      TextSemiBold(
                        "All Giveaways",
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(19),
                    ],
                  ),
                ),
              ),
              ..._buildGiveawayGridWithBanners(context),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildGiveawayGridWithBanners(BuildContext context) {
    if (controller.giveaways.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text(
              "No giveaways available",
              style: const TextStyle(
                fontFamily: AppFonts.manRope,
                fontSize: 16,
              ),
            ),
          ),
        )
      ];
    }

    List<Widget> slivers = [];
    final items = controller.giveaways;
    const chunkSize = 6;
    final currentUsername =
        controller.box.read('biometric_username_real') ?? '';

    for (int i = 0; i < items.length; i += chunkSize) {
      final end = (i + chunkSize < items.length) ? i + chunkSize : items.length;
      final chunk = items.sublist(i, end);

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: i + chunkSize < items.length ? 0 : 30),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final giveaway = chunk[index];
                final isOwnGiveaway = giveaway.userName.toLowerCase() ==
                    currentUsername.toLowerCase();
                return _boxCard(
                  giveaway.userName,
                  'N${giveaway.amount} • ${giveaway.quantity} Qty • ${giveaway.views} Seen \n${giveaway.type.toUpperCase()} • ${giveaway.typeCode.toUpperCase()}',
                  () => Get.bottomSheet(
                    GiveawayDetailSheet(giveawayId: giveaway.id),
                    isScrollControlled: true,
                    ignoreSafeArea: false,
                  ),
                  giveaway.image,
                  isOwnGiveaway: isOwnGiveaway,
                  giveawayId: giveaway.id,
                );
              },
              childCount: chunk.length,
            ),
          ),
        ),
      );

      // Add banner after each chunk except the last one
      if (end < items.length) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
              child: controller.adsService.showBannerAdWidget(),
            ),
          ),
        );
      }
    }

    return slivers;
  }

  Widget _boxCard(
      String title, String text, VoidCallback onTap, String imageUrl,
      {bool isOwnGiveaway = false, int? giveawayId}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image with flexible height
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xffF3FFF7),
                              child: const Center(
                                child: Icon(Icons.image,
                                    color: AppColors.primaryGrey2),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xffF3FFF7),
                            child: const Center(
                              child: Icon(Icons.image,
                                  color: AppColors.primaryGrey2),
                            ),
                          ),
                  ),
                  if (isOwnGiveaway && giveawayId != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => controller.shareGiveaway(giveawayId),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.share,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Gap(6),
            // title
            TextSemiBold(
              title,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              style: const TextStyle(fontFamily: AppFonts.manRope),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(2),
            // subtitle
            Text(
              text,
              style: const TextStyle(
                fontFamily: AppFonts.manRope,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: AppColors.primaryGrey2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(6),
            // claim button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isOwnGiveaway
                    ? AppColors.primaryGrey2.withOpacity(0.3)
                    : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: TextSemiBold(
                  isOwnGiveaway ? "Your Giveaway" : "Claim",
                  color: isOwnGiveaway ? AppColors.primaryGrey2 : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showCreateGiveawayDialog(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: AppColors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) => Padding(
  //       padding: EdgeInsets.only(
  //         bottom: MediaQuery.of(context).viewInsets.bottom,
  //         left: 20,
  //         right: 20,
  //         top: 20,
  //       ),
  //       child: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             TextBold(
  //               "Create Giveaway",
  //               fontSize: 22,
  //               fontWeight: FontWeight.w700,
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(24),

  //             // Short Note / Description field
  //             TextSemiBold(
  //               'Short Note',
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(8),
  //             TextFormField(
  //               controller: controller.descriptionController,
  //               maxLines: 3,
  //               decoration: InputDecoration(
  //                 hintText: 'Enter a brief description',
  //                 hintStyle: const TextStyle(
  //                   color: AppColors.primaryGrey2,
  //                   fontFamily: AppFonts.manRope,
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(color: Color(0xffE5E5E5)),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(color: Color(0xffE5E5E5)),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(
  //                       color: AppColors.primaryColor, width: 2),
  //                 ),
  //                 contentPadding:
  //                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //               ),
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(16),

  //             // Type dropdown
  //             TextSemiBold(
  //               'Type',
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(8),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 12),
  //               decoration: BoxDecoration(
  //                 color: AppColors.primaryGrey.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: const Color(0xffE5E5E5)),
  //               ),
  //               child: DropdownButtonHideUnderline(
  //                   child: Obx(
  //                 () => DropdownButton<String>(
  //                   dropdownColor: AppColors.white,
  //                   icon: Icon(Icons.keyboard_arrow_down_rounded),
  //                   borderRadius: BorderRadius.circular(8),
  //                   isExpanded: true,
  //                   value: controller.selectedType,
  //                   hint: Text('Type',
  //                       style: TextStyle(
  //                           fontFamily: AppFonts.manRope, color: Colors.grey)),
  //                   items: [
  //                     'airtime',
  //                     'data',
  //                     'electricity',
  //                     'tv',
  //                     'betting_topup'
  //                   ]
  //                       .map((type) => DropdownMenuItem(
  //                             value: type,
  //                             child: Text(
  //                               type.toUpperCase().replaceAll('_', ' '),
  //                               style: const TextStyle(
  //                                   fontFamily: AppFonts.manRope),
  //                             ),
  //                           ))
  //                       .toList(),
  //                   onChanged: (value) {
  //                     if (value != null) controller.setType(value);
  //                   },
  //                 ),
  //               )),
  //             ),
  //             const Gap(16),

  //             // Network Selection (Airtime & Data)
  //             Obx(() => Visibility(
  //                   visible: controller.selectedType == 'airtime' ||
  //                       controller.selectedType == 'data',
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       TextSemiBold(
  //                         'Network',
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                         style: const TextStyle(fontFamily: AppFonts.manRope),
  //                       ),
  //                       const Gap(8),
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(horizontal: 12),
  //                         decoration: BoxDecoration(
  //                           color: AppColors.primaryGrey.withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(8),
  //                           border: Border.all(color: const Color(0xffE5E5E5)),
  //                         ),
  //                         child: DropdownButtonHideUnderline(
  //                           child: DropdownButton<String>(
  //                             dropdownColor: AppColors.white,
  //                             icon: Icon(Icons.keyboard_arrow_down_rounded),
  //                             borderRadius: BorderRadius.circular(8),
  //                             isExpanded: true,
  //                             value: controller.selectedTypeCode,
  //                             hint: Text('Select Network',
  //                                 style: TextStyle(
  //                                     fontFamily: AppFonts.manRope,
  //                                     color: Colors.grey)),
  //                             items: ['mtn', 'glo', 'airtel', '9mobile']
  //                                 .map((code) => DropdownMenuItem(
  //                                       value: code,
  //                                       child: Text(
  //                                         code.toUpperCase(),
  //                                         style: const TextStyle(
  //                                             fontFamily: AppFonts.manRope),
  //                                       ),
  //                                     ))
  //                                 .toList(),
  //                             onChanged: (value) {
  //                               if (value != null)
  //                                 controller.setTypeCode(value);
  //                             },
  //                           ),
  //                         ),
  //                       ),
  //                       const Gap(16),
  //                     ],
  //                   ),
  //                 )),

  //             // Data Plan Selection (Data Only)
  //             Obx(() => Visibility(
  //                   visible: controller.selectedType == 'data' &&
  //                       controller.selectedTypeCode != null,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       TextSemiBold(
  //                         'Data Plan',
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                         style: const TextStyle(fontFamily: AppFonts.manRope),
  //                       ),
  //                       const Gap(8),
  //                       controller.isFetchingDataPlans.value
  //                           ? const Center(
  //                               child: Padding(
  //                               padding: EdgeInsets.all(8.0),
  //                               child: CircularProgressIndicator(
  //                                   color: AppColors.primaryColor),
  //                             ))
  //                           : Container(
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 12),
  //                               decoration: BoxDecoration(
  //                                 color: AppColors.primaryGrey.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 border: Border.all(
  //                                     color: const Color(0xffE5E5E5)),
  //                               ),
  //                               child: DropdownButtonHideUnderline(
  //                                 child: DropdownButton<String>(
  //                                   dropdownColor: AppColors.white,
  //                                   icon:
  //                                       Icon(Icons.keyboard_arrow_down_rounded),
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   isExpanded: true,
  //                                   value: controller.selectedDataPlanCode,
  //                                   hint: Text('Select Plan',
  //                                       style: TextStyle(
  //                                           fontFamily: AppFonts.manRope,
  //                                           color: Colors.grey)),
  //                                   items: controller.dataPlans
  //                                       .map((plan) => DropdownMenuItem(
  //                                             value: plan['coded'] as String?,
  //                                             child: Text(
  //                                               "${plan['name']} - ₦${plan['price']}",
  //                                               style:
  //                                                   GoogleFonts.plusJakartaSans(
  //                                                       fontSize: 12),
  //                                               overflow: TextOverflow.ellipsis,
  //                                             ),
  //                                           ))
  //                                       .toList(),
  //                                   onChanged: (value) =>
  //                                       controller.setDataPlan(value),
  //                                 ),
  //                               ),
  //                             ),
  //                       const Gap(16),
  //                     ],
  //                   ),
  //                 )),

  //             // Electricity Provider Selection
  //             Obx(() => Visibility(
  //                   visible: controller.selectedType == 'electricity',
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       TextSemiBold(
  //                         'Provider',
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                         style: const TextStyle(fontFamily: AppFonts.manRope),
  //                       ),
  //                       const Gap(8),
  //                       controller.isFetchingElectricityProviders.value
  //                           ? const Center(
  //                               child: Padding(
  //                               padding: EdgeInsets.all(8.0),
  //                               child: CircularProgressIndicator(
  //                                   color: AppColors.primaryColor),
  //                             ))
  //                           : Container(
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 12),
  //                               decoration: BoxDecoration(
  //                                 color: AppColors.primaryGrey.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 border: Border.all(
  //                                     color: const Color(0xffE5E5E5)),
  //                               ),
  //                               child: DropdownButtonHideUnderline(
  //                                 child: DropdownButton<String>(
  //                                   dropdownColor: AppColors.white,
  //                                   icon:
  //                                       Icon(Icons.keyboard_arrow_down_rounded),
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   isExpanded: true,
  //                                   value: controller
  //                                       .selectedElectricityProviderCode,
  //                                   hint: Text('Select Provider',
  //                                       style: TextStyle(
  //                                           fontFamily: AppFonts.manRope,
  //                                           color: Colors.grey)),
  //                                   items: controller.electricityProviders
  //                                       .map((provider) => DropdownMenuItem(
  //                                             value:
  //                                                 provider['code'] as String?,
  //                                             child: Text(
  //                                               provider['name'] ?? '',
  //                                               style: const TextStyle(
  //                                                   fontFamily:
  //                                                       AppFonts.manRope),
  //                                             ),
  //                                           ))
  //                                       .toList(),
  //                                   onChanged: (value) => controller
  //                                       .setElectricityProvider(value),
  //                                 ),
  //                               ),
  //                             ),
  //                       const Gap(16),
  //                     ],
  //                   ),
  //                 )),

  //             // Cable TV Provider Selection
  //             Obx(() => Visibility(
  //                   visible: controller.selectedType == 'tv',
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       TextSemiBold(
  //                         'Provider',
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                         style: const TextStyle(fontFamily: AppFonts.manRope),
  //                       ),
  //                       const Gap(8),
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(horizontal: 12),
  //                         decoration: BoxDecoration(
  //                           color: AppColors.primaryGrey.withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(8),
  //                           border: Border.all(color: const Color(0xffE5E5E5)),
  //                         ),
  //                         child: DropdownButtonHideUnderline(
  //                           child: Obx(() {
  //                             final providers =
  //                                 controller.cableProviders.toList();
  //                             final items = providers.map((provider) {
  //                               final code = provider['code'] as String?;
  //                               return DropdownMenuItem<String>(
  //                                 value: code,
  //                                 child: Text(
  //                                   provider['name'] ?? '',
  //                                   style: const TextStyle(
  //                                       fontFamily: AppFonts.manRope),
  //                                 ),
  //                               );
  //                             }).toList();

  //                             return DropdownButton<String>(
  //                               dropdownColor: AppColors.white,
  //                               icon: Icon(Icons.keyboard_arrow_down_rounded),
  //                               borderRadius: BorderRadius.circular(8),
  //                               isExpanded: true,
  //                               value: controller.selectedCableProviderCode,
  //                               hint: Text('Select Provider',
  //                                   style: TextStyle(
  //                                       fontFamily: AppFonts.manRope,
  //                                       color: Colors.grey)),
  //                               items: items,
  //                               onChanged: (value) =>
  //                                   controller.setCableProvider(value),
  //                             );
  //                           }),
  //                         ),
  //                       ),
  //                       const Gap(16),
  //                     ],
  //                   ),
  //                 )),

  //             // Cable Package Selection
  //             Obx(() => Visibility(
  //                   visible: controller.selectedType == 'tv' &&
  //                       controller.selectedCableProvider.value != null,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       TextSemiBold(
  //                         'Package',
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                         style: const TextStyle(fontFamily: AppFonts.manRope),
  //                       ),
  //                       const Gap(8),
  //                       controller.isFetchingCablePackages.value
  //                           ? const Center(
  //                               child: Padding(
  //                               padding: EdgeInsets.all(8.0),
  //                               child: CircularProgressIndicator(
  //                                   color: AppColors.primaryColor),
  //                             ))
  //                           : Container(
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 12),
  //                               decoration: BoxDecoration(
  //                                 color: AppColors.primaryGrey.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 border: Border.all(
  //                                     color: const Color(0xffE5E5E5)),
  //                               ),
  //                               child: DropdownButtonHideUnderline(
  //                                 child: DropdownButton<String>(
  //                                   dropdownColor: AppColors.white,
  //                                   icon:
  //                                       Icon(Icons.keyboard_arrow_down_rounded),
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   isExpanded: true,
  //                                   value: controller.selectedCablePackageCode,
  //                                   hint: Text('Select Package',
  //                                       style: TextStyle(
  //                                           fontFamily: AppFonts.manRope,
  //                                           color: Colors.grey)),
  //                                   items: controller.cablePackages
  //                                       .map((pkg) => DropdownMenuItem(
  //                                             value: pkg['coded'] as String?,
  //                                             child: Text(
  //                                               "${pkg['name']}",
  //                                               style: const TextStyle(
  //                                                   fontFamily:
  //                                                       AppFonts.manRope,
  //                                                   fontSize: 12),
  //                                               overflow: TextOverflow.ellipsis,
  //                                             ),
  //                                           ))
  //                                       .toList(),
  //                                   onChanged: (value) =>
  //                                       controller.setCablePackage(value),
  //                                 ),
  //                               ),
  //                             ),
  //                       const Gap(16),
  //                     ],
  //                   ),
  //                 )),

  //             // Betting Provider Selection
  //             Obx(() => Visibility(
  //                   visible: controller.selectedType == 'betting_topup',
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       TextSemiBold(
  //                         'Provider',
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                         style: const TextStyle(fontFamily: AppFonts.manRope),
  //                       ),
  //                       const Gap(8),
  //                       controller.isFetchingBettingProviders.value
  //                           ? const Center(
  //                               child: Padding(
  //                               padding: EdgeInsets.all(8.0),
  //                               child: CircularProgressIndicator(
  //                                   color: AppColors.primaryColor),
  //                             ))
  //                           : Container(
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 12),
  //                               decoration: BoxDecoration(
  //                                 color: AppColors.primaryGrey.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 border: Border.all(
  //                                     color: const Color(0xffE5E5E5)),
  //                               ),
  //                               child: DropdownButtonHideUnderline(
  //                                 child: Obx(() {
  //                                   final providers =
  //                                       controller.bettingProviders.toList();
  //                                   final items = providers
  //                                       .map((provider) => DropdownMenuItem(
  //                                             value:
  //                                                 provider['code'] as String?,
  //                                             child: Text(
  //                                               provider['name'] ?? '',
  //                                               style: const TextStyle(
  //                                                   fontFamily:
  //                                                       AppFonts.manRope),
  //                                             ),
  //                                           ))
  //                                       .toList();

  //                                   return DropdownButton<String>(
  //                                     dropdownColor: AppColors.white,
  //                                     icon: Icon(
  //                                         Icons.keyboard_arrow_down_rounded),
  //                                     borderRadius: BorderRadius.circular(8),
  //                                     isExpanded: true,
  //                                     value: controller
  //                                         .selectedBettingProviderCode,
  //                                     hint: Text('Select Provider',
  //                                         style: TextStyle(
  //                                             fontFamily: AppFonts.manRope,
  //                                             color: Colors.grey)),
  //                                     items: items,
  //                                     onChanged: (value) =>
  //                                         controller.setBettingProvider(value),
  //                                   );
  //                                 }),
  //                               ),
  //                             ),
  //                       const Gap(16),
  //                     ],
  //                   ),
  //                 )),
  //             const Gap(16),

  //             // File upload area
  //             TextSemiBold(
  //               'Upload Image',
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(8),
  //             Obx(() => InkWell(
  //                   onTap: controller.pickImage,
  //                   child: Container(
  //                     width: double.infinity,
  //                     padding: const EdgeInsets.symmetric(
  //                         vertical: 40, horizontal: 20),
  //                     decoration: BoxDecoration(
  //                       border: Border.all(
  //                         color: const Color(0xffE5E5E5),
  //                         style: BorderStyle.solid,
  //                         width: 2,
  //                       ),
  //                       borderRadius: BorderRadius.circular(8),
  //                       color: const Color(0xffFAFAFA),
  //                     ),
  //                     child: controller.selectedImage != null
  //                         ? Column(
  //                             children: [
  //                               ClipRRect(
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 child: Image.file(
  //                                   controller.selectedImage!,
  //                                   height: 120,
  //                                   width: double.infinity,
  //                                   fit: BoxFit.cover,
  //                                 ),
  //                               ),
  //                               const Gap(12),
  //                               const Text(
  //                                 'Tap to change image',
  //                                 style: TextStyle(
  //                                   fontFamily: AppFonts.manRope,
  //                                   fontSize: 13,
  //                                   color: AppColors.primaryGrey2,
  //                                 ),
  //                               ),
  //                             ],
  //                           )
  //                         : Column(
  //                             children: [
  //                               const Icon(
  //                                 Icons.cloud_upload_outlined,
  //                                 size: 40,
  //                                 color: AppColors.primaryGrey2,
  //                               ),
  //                               const Gap(12),
  //                               RichText(
  //                                 textAlign: TextAlign.center,
  //                                 text: const TextSpan(
  //                                   children: [
  //                                     TextSpan(
  //                                       text: 'Click here to Upload Document\n',
  //                                       style: TextStyle(
  //                                         fontFamily: AppFonts.manRope,
  //                                         fontSize: 14,
  //                                         color: Colors.black87,
  //                                         fontWeight: FontWeight.w500,
  //                                       ),
  //                                     ),
  //                                     TextSpan(
  //                                       text: '(5MB max)',
  //                                       style: TextStyle(
  //                                         fontFamily: AppFonts.manRope,
  //                                         fontSize: 12,
  //                                         color: AppColors.primaryGrey2,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                   ),
  //                 )),
  //             const Gap(16),

  //             // Amount field
  //             TextSemiBold(
  //               'Amount',
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(8),
  //             Obx(() => TextFormField(
  //                   controller: controller.selectedType == 'data' ||
  //                           controller.selectedType == 'tv'
  //                       ? controller.selectedType == 'data'
  //                           ? controller.selectedDataPlan.value != null
  //                               ? TextEditingController(
  //                                   text: controller
  //                                       .selectedDataPlan.value!['price']
  //                                       .toString())
  //                               : controller.amountController
  //                           : controller.selectedCablePackage.value != null
  //                               ? TextEditingController(
  //                                   text: controller
  //                                       .selectedCablePackage.value!['price']
  //                                       .toString())
  //                               : controller.amountController
  //                       : controller.amountController,
  //                   keyboardType: TextInputType.number,
  //                   readOnly: controller.selectedType == 'data' ||
  //                       controller.selectedType == 'tv',
  //                   decoration: InputDecoration(
  //                     hintText: 'Enter amount',
  //                     hintStyle: const TextStyle(
  //                       color: AppColors.primaryGrey2,
  //                       fontFamily: AppFonts.manRope,
  //                     ),
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: const BorderSide(color: Color(0xffE5E5E5)),
  //                     ),
  //                     enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: const BorderSide(color: Color(0xffE5E5E5)),
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: const BorderSide(
  //                           color: AppColors.primaryColor, width: 2),
  //                     ),
  //                     contentPadding: const EdgeInsets.symmetric(
  //                         horizontal: 16, vertical: 12),
  //                     filled: controller.selectedType == 'data' ||
  //                         controller.selectedType == 'tv',
  //                     fillColor: (controller.selectedType == 'data' ||
  //                             controller.selectedType == 'tv')
  //                         ? Colors.grey.shade100
  //                         : null,
  //                   ),
  //                   style: const TextStyle(fontFamily: AppFonts.manRope),
  //                 )),
  //             const Gap(16),

  //             // Number of Users field
  //             TextSemiBold(
  //               'Number of User',
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(8),
  //             TextFormField(
  //               controller: controller.quantityController,
  //               keyboardType: TextInputType.number,
  //               decoration: InputDecoration(
  //                 hintText: 'Enter number of users',
  //                 hintStyle: const TextStyle(
  //                   color: AppColors.primaryGrey2,
  //                   fontFamily: AppFonts.manRope,
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(color: Color(0xffE5E5E5)),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(color: Color(0xffE5E5E5)),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(
  //                       color: AppColors.primaryColor, width: 2),
  //                 ),
  //                 contentPadding:
  //                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //               ),
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),

  //             const Gap(28),
  //             Obx(() => SizedBox(
  //                   width: double.infinity,
  //                   child: BusyButton(
  //                     title: "Create",
  //                     isLoading: controller.isCreating,
  //                     onTap: () async {
  //                       final success = await controller.createGiveaway();
  //                       if (success) Get.back();
  //                     },
  //                   ),
  //                 )),
  //             const Gap(20),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // // Show recipient input dialog
  // void _showRecipientDialog(
  //     BuildContext context, int giveawayId, String giveawayType) {
  //   // Determine the appropriate label and hint based on giveaway type
  //   String inputLabel;
  //   String inputHint;
  //   TextInputType keyboardType;

  //   switch (giveawayType) {
  //     case 'airtime':
  //     case 'data':
  //       inputLabel = 'Phone Number';
  //       inputHint = 'Enter phone number (e.g., 08012345678)';
  //       keyboardType = TextInputType.phone;
  //       break;
  //     case 'electricity':
  //       inputLabel = 'Meter Number';
  //       inputHint = 'Enter meter number';
  //       keyboardType = TextInputType.number;
  //       break;
  //     case 'tv':
  //       inputLabel = 'Smart Card Number';
  //       inputHint = 'Enter smart card number';
  //       keyboardType = TextInputType.number;
  //       break;
  //     case 'betting_topup':
  //       inputLabel = 'Customer ID';
  //       inputHint = 'Enter betting account ID';
  //       keyboardType = TextInputType.text;
  //       break;
  //     default:
  //       inputLabel = 'Recipient';
  //       inputHint = 'Enter recipient details';
  //       keyboardType = TextInputType.text;
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             TextBold(
  //               inputLabel,
  //               fontSize: 18,
  //               fontWeight: FontWeight.w700,
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(8),
  //             Text(
  //               'Enter the $inputLabel for the giveaway recipient',
  //               style: const TextStyle(
  //                 fontSize: 14,
  //                 color: AppColors.primaryGrey2,
  //                 fontFamily: AppFonts.manRope,
  //               ),
  //             ),
  //             const Gap(16),
  //             TextFormField(
  //               controller: controller.receiverController,
  //               keyboardType: keyboardType,
  //               decoration: InputDecoration(
  //                 hintText: inputHint,
  //                 hintStyle: const TextStyle(
  //                   color: AppColors.primaryGrey2,
  //                   fontFamily: AppFonts.manRope,
  //                 ),
  //                 filled: true,
  //                 fillColor: AppColors.filledInputColor,
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(color: Color(0xffE5E5E5)),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(color: Color(0xffE5E5E5)),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: const BorderSide(
  //                       color: AppColors.primaryColor, width: 2),
  //                 ),
  //                 contentPadding:
  //                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //               ),
  //               style: const TextStyle(fontFamily: AppFonts.manRope),
  //             ),
  //             const Gap(20),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: OutlinedButton(
  //                     onPressed: () {
  //                       controller.receiverController.clear();
  //                       Get.back();
  //                     },
  //                     style: OutlinedButton.styleFrom(
  //                       padding: const EdgeInsets.symmetric(vertical: 14),
  //                       side: const BorderSide(color: AppColors.primaryColor),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                     child: TextSemiBold(
  //                       "Cancel",
  //                       color: AppColors.primaryColor,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //                 const Gap(12),
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       controller.showAdClaimDialog(
  //                         giveawayId,
  //                         controller.receiverController.text,
  //                       );
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppColors.primaryColor,
  //                       padding: const EdgeInsets.symmetric(vertical: 14),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                     child: TextSemiBold(
  //                       "Continue",
  //                       color: Colors.white,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //   Get.toNamed(Routes.GIVEAWAY_DETAIL, arguments: {'id': giveawayId});
  // }


  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextSemiBold(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryGrey2,
          style: const TextStyle(fontFamily: AppFonts.manRope),
        ),
        TextSemiBold(
          value,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          style: const TextStyle(fontFamily: AppFonts.manRope),
        ),
      ],
    );
  }

  Widget _detailRowAmount(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextSemiBold(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryGrey2,
          style: const TextStyle(fontFamily: AppFonts.manRope),
        ),
        TextSemiBold(value,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            style: GoogleFonts.plusJakartaSans()),
      ],
    );
  }
}
