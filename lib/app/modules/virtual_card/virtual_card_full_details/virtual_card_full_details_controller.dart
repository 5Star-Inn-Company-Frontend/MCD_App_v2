import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/virtual_card/models/virtual_card_model.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_details/virtual_card_details_controller.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'dart:developer' as dev;

class VirtualCardFullDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final apiService = DioApiService();
  final box = GetStorage();

  final isDetailsVisible = false.obs;
  final card = Rxn<VirtualCardModel>();
  final isDeleting = false.obs;
  final isFetching = false.obs;

  late final AnimationController flipController;
  late final Animation<double> flipAnimation;

  int? cardId;

  @override
  void onInit() {
    super.onInit();

    flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    flipAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: flipController, curve: Curves.easeInOut),
    );

    final args = Get.arguments;
    if (args != null && args['cardModel'] != null) {
      card.value = args['cardModel'];
      cardId = card.value!.id;
      fetchCardDetails(cardId!);
    } else if (args != null && args['cardId'] != null) {
      cardId = args['cardId'];
      fetchCardDetails(cardId!);
    }
  }

  Future<void> fetchCardDetails(int id) async {
    try {
      isFetching.value = true;
      dev.log('Fetching card details for card $id');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        return;
      }

      final result = await apiService
          .getrequest('${transactionUrl}virtual-card/fetch/$id');

      result.fold(
        (failure) {
          dev.log('Error: ${failure.message}');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1) {
            card.value = VirtualCardModel.fromJson(data['data']);
            dev.log('Success: Card details loaded');
            dev.log('Card details: ${card.value!.toJson()}');
          } else {
            dev.log('Error: ${data['message']}');
            Get.snackbar(
              'Error',
              data['message']?.toString() ?? 'Failed to fetch card details',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error: $e');
    } finally {
      isFetching.value = false;
    }
  }

  void toggleDetails() {
    if (flipController.isCompleted) {
      flipController.reverse();
      isDetailsVisible.value = false;
    } else {
      flipController.forward();
      isDetailsVisible.value = true;
    }
  }

  Future<void> deleteCard() async {
    if (card.value == null) return;

    try {
      isDeleting.value = true;
      dev.log('Deleting card ${card.value!.id}');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        return;
      }

      final result = await apiService.deleterequest(
          '${transactionUrl}virtual-card/delete/${card.value!.id}');

      result.fold(
        (failure) {
          dev.log('Error: ${failure.message}');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          if (data['success'] == 1) {
            dev.log('Success: ${data['message']}');
            Get.snackbar(
              'Success',
              data['message']?.toString() ?? 'Card deleted successfully',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );

            // Refresh home list
            if (Get.isRegistered<VirtualCardDetailsController>()) {
              Get.find<VirtualCardDetailsController>().fetchAllCards();
            }

            Get.until(
                (route) => route.settings.name == Routes.VIRTUAL_CARD_DETAILS);
            // Or just close enough
            // Get.close(2);
          } else {
            dev.log('Error: ${data['message']}');
            Get.snackbar(
              'Error',
              data['message']?.toString() ?? 'Failed to delete card',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error: $e');
    } finally {
      isDeleting.value = false;
    }
  }
}
