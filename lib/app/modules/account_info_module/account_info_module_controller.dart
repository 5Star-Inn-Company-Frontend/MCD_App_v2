import 'package:mcd/core/import/imports.dart';
import 'package:mcd/app/modules/account_info_module/model/profile_model.dart';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../../../core/network/dio_api_service.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/network/api_constants.dart';

class AccountInfoModuleController extends GetxController {
  bool _hasFetchedThisSession = false;
  final _profileData = Rxn<ProfileModel>();
  set profileData(value) => _profileData.value = value;
  get profileData => _profileData.value;

  final _isLoading = false.obs;
  set isLoading(value) => _isLoading.value = value;
  get isLoading => _isLoading.value;

  final _errorMessage = ''.obs;
  set errorMessage(value) => _errorMessage.value = value;
  get errorMessage => _errorMessage.value;

  final _isUploading = false.obs;
  set isUploading(value) => _isUploading.value = value;
  get isUploading => _isUploading.value;

  final apiService = DioApiService();
  final box = GetStorage();

  @override
  void onInit() {
    dev.log("AccountInfoModuleController: onInit called");
    _loadCachedProfile();
    fetchProfile();
    super.onInit();
  }

  void _loadCachedProfile() {
    final cached = box.read('cached_profile');
    if (cached != null && cached is Map<String, dynamic>) {
      profileData = ProfileModel.fromCache(cached);
      dev.log(
          "AccountInfoModuleController: Loaded cached profile - ${profileData?.fullName}");
    }
  }

  @override
  void onReady() {
    dev.log(
        "AccountInfoModuleController: onReady - profileData: ${profileData != null}");
    super.onReady();
  }

  @override
  void onClose() {
    dev.log("AccountInfoModuleController: onClose called");
  }

  Future<void> fetchProfile({bool force = false}) async {
    dev.log(
        "AccountInfoModuleController: fetchProfile called - force: $force, existing data: ${profileData != null}");

    if (_hasFetchedThisSession && !force) {
      dev.log(
          "AccountInfoModuleController: Profile already fetched this session, skipping");
      return;
    }

    isLoading = true;
    errorMessage = "";
    final result =
        await apiService.getrequest("${ApiConstants.authUrlV2}/dashboard");

    result.fold(
      (failure) {
        errorMessage = failure.message;
        dev.log(
            "AccountInfoModuleController: Profile fetch failed - ${failure.message}");
        Get.snackbar("Error", failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
      },
      (data) {
        profileData = ProfileModel.fromJson(data);
        _hasFetchedThisSession = true;
        // cache profile
        box.write('cached_profile', profileData.toJson());
        dev.log(
            "AccountInfoModuleController: Profile model created - Name: ${profileData?.fullName}, Email: ${profileData?.email}");
        if (force) {
          Get.snackbar("Updated", "Profile refreshed",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor);
        }
      },
    );

    isLoading = false;
    dev.log(
        "AccountInfoModuleController: fetchProfile completed - isLoading: $isLoading");
  }

  Future<void> refreshProfile() async {
    await fetchProfile(force: true);
  }

  Future<void> uploadProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        dev.log("AccountInfoModuleController: No image selected");
        Get.snackbar("Info", "No image selected",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }

      dev.log("AccountInfoModuleController: Image selected: ${image.path}");

      isUploading = true;
      dev.log("AccountInfoModuleController: Converting image to base64");

      // Read image as bytes
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      dev.log(
          "Base64 first 20 chars: ${base64Image.substring(0, base64Image.length < 20 ? base64Image.length : 20)}");

      final url = '${ApiConstants.authUrlV2}/uploaddp';

      final result = await apiService.postrequest(url, {"dp": base64Image});

      result.fold(
        (failure) {
          dev.log(
              "AccountInfoModuleController: Upload failed - ${failure.message}");
          Get.snackbar("Error", failure.message,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        },
        (data) {
          dev.log(
              "AccountInfoModuleController: Upload success - ${data.toString()}");
          Get.snackbar("Success", "Profile picture updated successfully",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor);
          // refresh profile to show new picture
          fetchProfile(force: true);
        },
      );
    } catch (e) {
      dev.log("AccountInfoModuleController: Upload exception - $e");
      Get.snackbar("Error", "Failed to upload image",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
    } finally {
      isUploading = false;
      dev.log(
          "AccountInfoModuleController: Upload completed - isUploading: $isUploading");
    }
  }
}
