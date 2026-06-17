import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/ads_service.dart';
import 'package:mcd/core/services/deep_link_service.dart';
import 'package:share_plus/share_plus.dart';
import '../models/giveaway_model.dart';

class GiveawayDetailController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();
  final adsService = AdsService();

  final detail = Rxn<GiveawayDetailModel>();
  final isLoading = false.obs;
  final receiverController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final dynamic rawId = Get.arguments?['id'] ?? Get.arguments?['giveaway_id'];
    final int? id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');
    final autoClaim = Get.arguments?['auto_claim'] ?? false;

    if (id != null) {
      fetchDetail(id).then((_) {
        if (autoClaim) {
          claimGiveaway();
        }
      });
    } else {
      Get.back();
      Get.snackbar('Error', 'Invalid giveaway ID');
    }
  }

  @override
  void onClose() {
    receiverController.dispose();
    super.onClose();
  }

  Future<void> fetchDetail(int id) async {
    try {
      isLoading.value = true;
      final utilityUrl = box.read('utility_service_url') ?? '';
      final url = '${utilityUrl}fetch-giveaway/$id';

      final response = await apiService.getrequest(url);

      response.fold(
        (failure) {
          dev.log('Fetch giveaway detail failed: ${failure.message}',
              name: 'GiveawayDetail');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1) {
            detail.value = GiveawayDetailModel.fromJson(data['data']);
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching details: $e', name: 'GiveawayDetail');
    } finally {
      isLoading.value = false;
    }
  }

  void shareGiveaway(int id) {
    final link = DeepLinkService.buildClaimLink(id);
    Share.share(
      'Claim my giveaway on MEGA Cheap Data!\n\n$link\n\n(If it opens in browser, look for an "Open in App" option.)',
    );
  }

  void claimGiveaway() async {
    if (detail.value == null) return;

    final giveawayId = detail.value!.giveaway.id;
    final giveawayType = detail.value!.giveaway.type;

    final currentUsername = box.read('biometric_username_real') ?? '';
    final isOwnGiveaway =
        detail.value!.giveaway.userName.trim().toLowerCase() ==
            currentUsername.trim().toLowerCase();
    if (isOwnGiveaway) {
      Get.snackbar('Not allowed', "You can't claim your own giveaway");
      return;
    }

    // SECURITY: Double check status before showing ad
    if (detail.value!.completed || detail.value!.giveaway.status != 1) {
      Get.snackbar(
        'Expired',
        'Sorry, this giveaway has just been fully claimed.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.white,
      );
      return;
    }

    _showAdClaimDialog(giveawayId, giveawayType);
  }

  void _showAdClaimDialog(int giveawayId, String giveawayType) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Watch Ad to Claim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'To claim this giveaway, please watch some ads.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGrey2,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primaryGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close ad dialog
                        _showRewardedAdThenRecipient(giveawayId, giveawayType);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Watch Ad',
                          style: TextStyle(color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showRewardedAdThenRecipient(
      int giveawayId, String giveawayType) async {
    Get.dialog(
      const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor)),
      barrierDismissible: false,
    );

    try {
      final success = await adsService.showRewardedAd(
        onRewarded: () {},
      );

      Get.back(); // Close loading indicator

      if (success) {
        _showRecipientDialog(giveawayId, giveawayType);
      } else {
        Get.snackbar(
          'Ad Failed',
          'Failed to load ad. Please try again later.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void _showRecipientDialog(int giveawayId, String giveawayType) {
    String inputLabel = 'Phone Number';
    String inputHint = 'Enter phone number';
    TextInputType keyboardType = TextInputType.phone;

    switch (giveawayType.toLowerCase()) {
      case 'electricity':
        inputLabel = 'Meter Number';
        inputHint = 'Enter meter number';
        keyboardType = TextInputType.number;
        break;
      case 'tv':
        inputLabel = 'Smart Card Number';
        inputHint = 'Enter smart card number';
        keyboardType = TextInputType.number;
        break;
      case 'betting_topup':
        inputLabel = 'Customer ID';
        inputHint = 'Enter betting account ID';
        keyboardType = TextInputType.text;
        break;
    }

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                inputLabel,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the $inputLabel for the giveaway recipient',
                style: const TextStyle(fontSize: 14, color: AppColors.primaryGrey2),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: receiverController,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: inputHint,
                  hintStyle: const TextStyle(color: AppColors.primaryGrey2),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        receiverController.clear();
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final receiver = receiverController.text.trim();
                        if (receiver.isEmpty) {
                          Get.snackbar('Error', 'Please enter $inputLabel');
                          return;
                        }
                        Get.back(); // Close dialog
                        _performClaim(giveawayId, receiver);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor),
                      child: const Text('Claim',
                          style: TextStyle(color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performClaim(int giveawayId, String receiver) async {
    try {
      final body = {
        'giveaway_id': giveawayId,
        'receiver': receiver,
      };

      final utilityUrl = box.read('utility_service_url') ?? '';
      final url = '${utilityUrl}request-giveaway';
      final response = await apiService.postrequest(url, body);

      response.fold(
        (failure) {
          Get.snackbar('Error', failure.message,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        },
        (data) {
          if (data['success'] == 1) {
            Get.snackbar('Success', data['message'] ?? 'Claimed successfully',
                backgroundColor: AppColors.successBgColor,
                colorText: AppColors.textSnackbarColor);
            fetchDetail(giveawayId); // Refresh
          } else {
            Get.snackbar('Error', data['message'] ?? 'Failed to claim');
          }
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim giveaway: $e');
    }
  }
}
