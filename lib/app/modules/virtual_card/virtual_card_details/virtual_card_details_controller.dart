import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/app/modules/virtual_card/models/virtual_card_model.dart';
import 'dart:developer' as dev;

class VirtualCardDetailsController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final pageController = PageController();
  final isCardDetailsHidden = true.obs;
  final cardBalances = <int, double>{}.obs;
  final cardBalanceLoading = <int, bool>{}.obs;
  final cards = <VirtualCardModel>[].obs;
  final isFetchingCards = false.obs;
  final isFreezing = false.obs;
  final isUnfreezing = false.obs;
  final isDeleting = false.obs;
  final currentCardIndex = 0.obs;

  VirtualCardModel? get currentCard =>
      cards.isNotEmpty ? cards[currentCardIndex.value] : null;
  double get currentBalance =>
      currentCard != null ? (cardBalances[currentCard!.id] ?? 0.0) : 0.0;
  bool get isCurrentBalanceLoading => currentCard != null
      ? (cardBalanceLoading[currentCard!.id] ?? false)
      : false;

  @override
  void onInit() {
    super.onInit();
    fetchAllCards();

    // re-fetch balance when swiping to a different card
    ever(currentCardIndex, (index) {
      if (currentCard != null) {
        fetchCardBalance(currentCard!.id);
      }
    });
  }

  // call this whenever returning to this screen from a sub-screen
  void refreshAllBalances() {
    for (final card in cards) {
      fetchCardBalance(card.id);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> fetchAllCards() async {
    try {
      isFetchingCards.value = true;
      dev.log('Fetching all virtual cards');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        return;
      }

      final result =
          await apiService.getrequest('${transactionUrl}virtual-card/list');

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
            final response = VirtualCardListResponse.fromJson(data);
            cards.value = response.data;
            dev.log('Success: ${cards.length} cards loaded');

            // Navigate to home screen if no cards exist
            if (cards.isEmpty) {
              Get.offNamed('/virtual_card_home');
              return;
            }

            // Fetch balance for all cards
            for (var card in cards) {
              fetchCardBalance(card.id);
            }
          } else {
            dev.log('Error: ${data['message']}');
          }
        },
      );
    } catch (e) {
      dev.log('Error: $e');
    } finally {
      isFetchingCards.value = false;
    }
  }

  Future<void> fetchCardBalance(int cardId) async {
    try {
      cardBalanceLoading[cardId] = true;
      cardBalanceLoading.refresh();
      dev.log('Fetching balance for card $cardId');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        return;
      }

      final result = await apiService
          .getrequest('${transactionUrl}virtual-card/balance/$cardId');

      result.fold(
        (failure) {
          dev.log('Error: ${failure.message}');
        },
        (data) {
          if (data['success'] == 1) {
            String balanceString = data['data']?.toString() ?? '0';
            String numericBalance =
                balanceString.replaceAll(RegExp(r'[^0-9.]'), '').trim();
            cardBalances[cardId] = double.tryParse(numericBalance) ?? 0.0;
            cardBalances.refresh();
            dev.log(
                'Success: Balance for card $cardId - \$${cardBalances[cardId]}');
          } else {
            dev.log('Error: ${data['message']}');
          }
        },
      );
    } catch (e) {
      dev.log('Error: $e');
    } finally {
      cardBalanceLoading[cardId] = false;
      cardBalanceLoading.refresh();
    }
  }

  Future<void> freezeCard(int cardId) async {
    try {
      isFreezing.value = true;
      dev.log('Freezing card $cardId');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        return;
      }

      final result = await apiService
          .patchrequest('${transactionUrl}virtual-card/freeze/$cardId', {});

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
            // Update card status locally
            final cardIndex = cards.indexWhere((c) => c.id == cardId);
            if (cardIndex != -1) {
              cards[cardIndex] = VirtualCardModel(
                id: cards[cardIndex].id,
                userName: cards[cardIndex].userName,
                cardId: cards[cardIndex].cardId,
                cardType: cards[cardIndex].cardType,
                customerId: cards[cardIndex].customerId,
                brand: cards[cardIndex].brand,
                name: cards[cardIndex].name,
                cardNumber: cards[cardIndex].cardNumber,
                masked: cards[cardIndex].masked,
                expiryDate: cards[cardIndex].expiryDate,
                cvv: cards[cardIndex].cvv,
                currency: cards[cardIndex].currency,
                address: cards[cardIndex].address,
                status: 0, // frozen
                createdAt: cards[cardIndex].createdAt,
                updatedAt: DateTime.now(),
              );
              cards.refresh();
            }
            Get.snackbar(
              'Success',
              data['message']?.toString() ?? 'Card frozen successfully',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          } else {
            dev.log('Error: ${data['message']}');
            Get.snackbar(
              'Error',
              data['message']?.toString() ?? 'Failed to freeze card',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error: $e');
    } finally {
      isFreezing.value = false;
    }
  }

  Future<void> unfreezeCard(int cardId) async {
    try {
      isUnfreezing.value = true;
      dev.log('Unfreezing card $cardId');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        return;
      }

      final result = await apiService
          .patchrequest('${transactionUrl}virtual-card/unfreeze/$cardId', {});

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
            // Update card status locally
            final cardIndex = cards.indexWhere((c) => c.id == cardId);
            if (cardIndex != -1) {
              cards[cardIndex] = VirtualCardModel(
                id: cards[cardIndex].id,
                userName: cards[cardIndex].userName,
                cardId: cards[cardIndex].cardId,
                cardType: cards[cardIndex].cardType,
                customerId: cards[cardIndex].customerId,
                brand: cards[cardIndex].brand,
                name: cards[cardIndex].name,
                cardNumber: cards[cardIndex].cardNumber,
                masked: cards[cardIndex].masked,
                expiryDate: cards[cardIndex].expiryDate,
                cvv: cards[cardIndex].cvv,
                currency: cards[cardIndex].currency,
                address: cards[cardIndex].address,
                status: 1, // active
                createdAt: cards[cardIndex].createdAt,
                updatedAt: DateTime.now(),
              );
              cards.refresh();
            }
            Get.snackbar(
              'Success',
              data['message']?.toString() ?? 'Card unfrozen successfully',
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          } else {
            dev.log('Error: ${data['message']}');
            Get.snackbar(
              'Error',
              data['message']?.toString() ?? 'Failed to unfreeze card',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error: $e');
    } finally {
      isUnfreezing.value = false;
    }
  }

  Future<void> deleteCard(int cardId) async {
    try {
      isDeleting.value = true;
      dev.log('Deleting card $cardId');

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Error: Transaction URL not found');
        return;
      }

      final result = await apiService
          .deleterequest('${transactionUrl}virtual-card/delete/$cardId');

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
            Get.back();
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
