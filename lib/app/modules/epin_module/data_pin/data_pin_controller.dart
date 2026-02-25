import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class DataPinController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();
  
  final _selectedNetwork = ''.obs;
  String get selectedNetwork => _selectedNetwork.value;

  final _selectedType = ''.obs;
  String get selectedType => _selectedType.value;

  final _selectedDenomination = ''.obs;
  String get selectedDenomination => _selectedDenomination.value;

  final selectedDesign = 1.obs; // Default to design 1

  final TextEditingController quantityController = TextEditingController();
  
  final formKey = GlobalKey<FormState>();
  
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  final _dataPins = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get dataPins => _dataPins;
  
  final _dataPinPlans = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get dataPinPlans => _dataPinPlans;
  
  // Get available plans for selected network
  List<Map<String, dynamic>> get availablePlans {
    if (_selectedNetwork.value.isEmpty) return [];
    return _dataPinPlans.where((plan) => 
      plan['network']?.toString().toUpperCase() == _selectedNetwork.value.toUpperCase()
    ).toList();
  }

  final networks = [
    {'code': 'MTN', 'name': 'MTN', 'image': 'assets/images/mtn.png'},
    {'code': 'AIRTEL', 'name': 'Airtel', 'image': 'assets/images/airtel.png'},
    {'code': '9MOBILE', 'name': '9mobile', 'image': 'assets/images/etisalat.png'},
    {'code': 'GLO', 'name': 'Glo', 'image': 'assets/images/glo.png'},
  ];

  final types = ['Type A', 'Type B', 'Type C', 'Type D'];
  final denominations = ['100', '200', '500'];
  
  // Available designs
  final designs = [
    {'id': 1, 'name': 'Design 1', 'image': 'assets/images/epin/design-1.png'},
    {'id': 2, 'name': 'Design 2', 'image': 'assets/images/epin/design-2.png'},
    {'id': 3, 'name': 'Design 3', 'image': 'assets/images/epin/design-3.png'},
    {'id': 4, 'name': 'Design 4', 'image': 'assets/images/epin/design-4.png'},
    {'id': 5, 'name': 'Design 5', 'image': 'assets/images/epin/design-5.png'},
    {'id': 6, 'name': 'Design 6', 'image': 'assets/images/epin/design-6.png'},
  ];
  
  @override
  void onInit() {
    super.onInit();
    dev.log('DataPinController initialized', name: 'DataPin');
    fetchDataPins();
  }
  
  Future<void> fetchDataPins() async {
    try {
      _isLoading.value = true;
      dev.log('Fetching data pin plans...', name: 'DataPin');
      
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        dev.log('Transaction URL not found', name: 'DataPin', error: 'URL missing');
        return;
      }
      
      final url = '${transactionUrl}datapins';
      dev.log('Request URL: $url', name: 'DataPin');
      
      final result = await apiService.getrequest(url);
      
      result.fold(
        (failure) {
          dev.log('Failed to fetch data pin plans', name: 'DataPin', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          dev.log('Data pin plans response: $data', name: 'DataPin');
          if (data['success'] == 1) {
            final pinsData = data['data'] as List?;
            if (pinsData != null) {
              _dataPinPlans.value = pinsData.map((item) => item as Map<String, dynamic>).toList();
              dev.log('Fetched ${_dataPinPlans.length} data pin plans', name: 'DataPin');
            }
          } else {
            dev.log('Fetch unsuccessful', name: 'DataPin', error: data['message']);
          }
        },
      );
    } catch (e) {
      dev.log('Exception while fetching data pin plans', name: 'DataPin', error: e);
    } finally {
      _isLoading.value = false;
    }
  }

  void selectNetwork(String code) {
    _selectedNetwork.value = code;
  }

  void selectType(String? type) {
    if (type != null) {
      _selectedType.value = type;
      final selectedPlan = _dataPinPlans.firstWhere(
        (plan) => plan['name'] == type,
        orElse: () => {},
      );
      if (selectedPlan.isNotEmpty) {
        _selectedDenomination.value = selectedPlan['amount']?.toString() ?? '';
        dev.log('Selected plan: ${selectedPlan['name']}, Amount: ₦${selectedPlan['price']}', name: 'DataPin');
      }
    }
  }

  void selectDenomination(String? denomination) {
    if (denomination != null) {
      _selectedDenomination.value = denomination;
    }
  }

  void selectDesign(int designId) {
    selectedDesign.value = designId;
    dev.log('Design selected: $designId', name: 'DataPin');
  }

  Map<String, dynamic> get currentDesign {
    return designs.firstWhere(
      (design) => design['id'] == selectedDesign.value,
      orElse: () => designs[0],
    );
  }

  String get username {
    return box.read('biometric_username_real') ?? 'User';
  }

  void incrementQuantity() {
    int current = int.tryParse(quantityController.text) ?? 1;
    if (current < 10) {
      quantityController.text = (current + 1).toString();
    }
  }

  void decrementQuantity() {
    int current = int.tryParse(quantityController.text) ?? 1;
    if (current > 1) {
      quantityController.text = (current - 1).toString();
    }
  }

  void showPlanSelectionBottomSheet(BuildContext context) {
    if (availablePlans.isEmpty) {
      Get.snackbar(
        'No Plans Available',
        'Please select a network first or check your connection',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPlanSelectionSheet(),
    );
  }

  Widget _buildPlanSelectionSheet() {
    return Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Data Pin Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final plans = availablePlans;
              
              if (plans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No plans available for ${_selectedNetwork.value}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final name = plan['name']?.toString() ?? 'Unknown Plan';
                  final network = plan['network']?.toString() ?? '';
                  final amount = plan['amount']?.toString() ?? '0';
                  final price = plan['price']?.toString() ?? '0';
                  
                  return GestureDetector(
                    onTap: () {
                      selectType(name);
                      Get.back();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _selectedType.value == name 
                            ? AppColors.primaryColor 
                            : Colors.grey.shade200,
                          width: _selectedType.value == name ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.background,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  network.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₦$price',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              Text(
                                amount,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void showCardsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCardsSheet(),
    );
  }

  Widget _buildCardsSheet() {
    return Container(
      height: Get.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Purchased Data PINs',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              // _dataPins is for purchased PINs (not the same as plans)
              // This would need a different API endpoint to fetch purchased PINs
              if (_dataPins.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No purchased data pins yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your purchased data PINs will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _dataPins.length,
                itemBuilder: (context, index) {
                  final card = _dataPins[index];
                  return _buildCard(card);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> card) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5ABB7B), Color(0xFF4A9B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.sim_card,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    card['username']?.toString() ?? card['user_name']?.toString() ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    card['amount']?.toString() ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _buildCardRow('Ref No.', card['refNo']?.toString() ?? card['ref']?.toString() ?? card['ref_no']?.toString() ?? 'N/A'),
          _buildCardRow('PIN:', card['pin']?.toString() ?? 'N/A'),
          _buildCardRow('Expiry Date', card['expiryDate']?.toString() ?? card['expiry_date']?.toString() ?? card['expiry']?.toString() ?? 'N/A'),
          _buildCardRow('Serial No.', card['serialNo']?.toString() ?? card['serial_no']?.toString() ?? card['serial']?.toString() ?? 'N/A'),
          const SizedBox(height: 4),
          Text(
            'To load dial *311*PIN#',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 8,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> proceedToPurchase(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (_selectedNetwork.value.isEmpty) {
        Get.snackbar("Error", "Please select a network provider.");
        return;
      }

      if (selectedDesign.value == 0) {
        Get.snackbar("Error", "Please select a design type.");
        return;
      }

      // Navigate to data pin payout page (using special route for data pin API)
      final selectedNetworkData = networks.firstWhere(
        (network) => network['code'] == _selectedNetwork.value,
        orElse: () => networks[0],
      );

      // For data pin, we need to determine the coded value based on type/denomination
      String codedValue = '1'; // Default
      if (_selectedDenomination.isNotEmpty) {
        // Map denomination to coded value if needed
        codedValue = _selectedDenomination.value;
      } else if (_selectedType.isNotEmpty) {
        codedValue = (types.indexOf(_selectedType.value) + 1).toString();
      }

      Get.toNamed(
        Routes.GENERAL_PAYOUT,
        arguments: {
          'paymentType': PaymentType.dataPin,
          'paymentData': {
            'networkName': selectedNetworkData['name'] ?? '',
            'networkCode': selectedNetworkData['code'] ?? '',
            'networkImage': selectedNetworkData['image'] ?? '',
            'designId': selectedDesign.value,
            'designName': currentDesign['name'] ?? '',
            'designType': currentDesign['name'] ?? '',
            'quantity': quantityController.text.isNotEmpty ? quantityController.text : '1',
            'amount': _selectedDenomination.value.isNotEmpty ? _selectedDenomination.value : '100',
            'coded': codedValue,
          },
        },
      );
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    super.onClose();
  }
}
