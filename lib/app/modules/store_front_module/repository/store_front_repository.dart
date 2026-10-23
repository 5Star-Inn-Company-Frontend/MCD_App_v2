import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/network/errors.dart';
import 'package:mcd/core/services/storage_service.dart';
import '../models/storefront_dashboard_model.dart';
import '../models/storefront_plan_model.dart';
import '../models/storefront_provider_model.dart';
import '../models/storefront_usage_model.dart';

class StoreFrontRepository {
  final DioApiService _apiService = DioApiService();

  String get _baseUrl {
    String url = StorageService.to.transactionUrlV2.trim();
    while (url.contains('/api/v2/api/v2')) {
      url = url.replaceAll('/api/v2/api/v2', '/api/v2');
    }
    return url.endsWith('/') ? url : '$url/';
  }

  Future<Either<Failure, StorefrontDashboardModel>> getDashboard() async {
    final endpoint = '${_baseUrl}storefront';
    dev.log('[StoreFront] GET URL: $endpoint', name: 'StoreFront');
    final result = await _apiService.getrequest(endpoint);
    return result.fold(
      (failure) {
        dev.log('[StoreFront] getDashboard FAIL ($endpoint): ${failure.message}', name: 'StoreFront');
        return Left(failure);
      },
      (data) {
        dev.log('[StoreFront] getDashboard SUCCESS ($endpoint): ${jsonEncode(data)}', name: 'StoreFront');
        try {
          return Right(StorefrontDashboardModel.fromJson(data));
        } catch (e) {
          dev.log('[StoreFront] getDashboard Parsing ERROR: $e', name: 'StoreFront');
          return Left(ServerFailure(e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, StorefrontUsageModel>> getUsage() async {
    final endpoint = '${_baseUrl}storefront/usage';
    dev.log('[StoreFront] GET URL: $endpoint', name: 'StoreFront');
    final result = await _apiService.getrequest(endpoint);
    return result.fold(
      (failure) {
        dev.log('[StoreFront] getUsage FAIL ($endpoint): ${failure.message}', name: 'StoreFront');
        return Left(failure);
      },
      (data) {
        dev.log('[StoreFront] getUsage SUCCESS ($endpoint): ${jsonEncode(data)}', name: 'StoreFront');
        try {
          return Right(StorefrontUsageModel.fromJson(data));
        } catch (e) {
          dev.log('[StoreFront] getUsage Parsing ERROR: $e', name: 'StoreFront');
          return Left(ServerFailure(e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> updateProfile({
    required String storeName,
    required String welcomeMessage,
    required int status,
    String? storeCode,
  }) async {
    final endpoint = '${_baseUrl}storefront/profile';
    final body = <String, dynamic>{
      'store_name': storeName,
      'welcome_message': welcomeMessage,
      'status': status,
      if (storeCode != null && storeCode.trim().isNotEmpty) 'store_code': storeCode.trim(),
    };
    dev.log('[StoreFront] POST URL: $endpoint', name: 'StoreFront');
    dev.log('[StoreFront] POST Request Body: ${jsonEncode(body)}', name: 'StoreFront');
    final result = await _apiService.postrequest(endpoint, body);
    result.fold(
      (failure) => dev.log('[StoreFront] updateProfile FAIL ($endpoint): ${failure.message}', name: 'StoreFront'),
      (data) => dev.log('[StoreFront] updateProfile SUCCESS ($endpoint): ${jsonEncode(data)}', name: 'StoreFront'),
    );
    return result;
  }

  Future<Either<Failure, Map<String, dynamic>>> updatePaymentMethods({
    required bool acceptVirtualAccount,
    required bool acceptCard,
    required bool acceptMobileMoney,
  }) async {
    final endpoint = '${_baseUrl}storefront/payment-methods';
    final body = <String, dynamic>{
      'accept_virtual_account': acceptVirtualAccount,
      'accept_card': acceptCard,
      'accept_mobile_money': acceptMobileMoney,
    };
    dev.log('[StoreFront] PUT URL: $endpoint', name: 'StoreFront');
    dev.log('[StoreFront] PUT Request Body: ${jsonEncode(body)}', name: 'StoreFront');
    final result = await _apiService.putrequest(endpoint, body);
    result.fold(
      (failure) => dev.log('[StoreFront] updatePaymentMethods FAIL ($endpoint): ${failure.message}', name: 'StoreFront'),
      (data) => dev.log('[StoreFront] updatePaymentMethods SUCCESS ($endpoint): ${jsonEncode(data)}', name: 'StoreFront'),
    );
    return result;
  }

  Future<Either<Failure, List<StorefrontProviderModel>>> getCategoryProviders(String category) async {
    final endpoint = '${_baseUrl}storefront/services/$category';
    dev.log('[StoreFront] GET URL: $endpoint', name: 'StoreFront');
    final result = await _apiService.getrequest(endpoint);
    return result.fold(
      (failure) {
        dev.log('[StoreFront] getCategoryProviders("$category") FAIL ($endpoint): ${failure.message}', name: 'StoreFront');
        return Left(failure);
      },
      (data) {
        dev.log('[StoreFront] getCategoryProviders("$category") SUCCESS ($endpoint): ${jsonEncode(data)}', name: 'StoreFront');
        try {
          dynamic rawList;
          final dynamic dataField = data['data'];

          if (dataField is List) {
            rawList = dataField;
          } else if (dataField is Map) {
            rawList = dataField['providers'] ??
                dataField['services'] ??
                dataField['items'] ??
                dataField['data'];
            if (rawList is! List) {
              for (final val in dataField.values) {
                if (val is List) {
                  rawList = val;
                  break;
                }
              }
            }
          }

          if (rawList is! List) {
            rawList = data['providers'] ?? data['services'] ?? data['items'];
          }

          if (rawList is! List) {
            for (final val in data.values) {
              if (val is List) {
                rawList = val;
                break;
              }
            }
          }

          if (rawList is List) {
            final list = rawList
                .where((e) => e is Map)
                .map((e) => StorefrontProviderModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
            return Right(list);
          }
          return const Right([]);
        } catch (e) {
          dev.log('[StoreFront] getCategoryProviders("$category") Parsing ERROR: $e', name: 'StoreFront');
          return Left(ServerFailure(e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> updateProvider({
    required String category,
    required String provider,
    required bool isEnabled,
    required double discountPercent,
  }) async {
    final endpoint = '${_baseUrl}storefront/services/$category/provider';
    final body = <String, dynamic>{
      'provider': provider,
      'is_enabled': isEnabled,
      'discount_percent': discountPercent,
    };
    dev.log('[StoreFront] PUT URL: $endpoint', name: 'StoreFront');
    dev.log('[StoreFront] PUT Request Body: ${jsonEncode(body)}', name: 'StoreFront');
    final result = await _apiService.putrequest(endpoint, body);
    result.fold(
      (failure) => dev.log('[StoreFront] updateProvider FAIL ($endpoint): ${failure.message}', name: 'StoreFront'),
      (data) => dev.log('[StoreFront] updateProvider SUCCESS ($endpoint): ${jsonEncode(data)}', name: 'StoreFront'),
    );
    return result;
  }

  Future<Either<Failure, List<StorefrontPlanModel>>> getPlans({
    required String category,
    required String provider,
    String? type,
  }) async {
    final endpoint = '${_baseUrl}storefront/services/$category/plans';
    final query = <String, dynamic>{
      'provider': provider,
      if (type != null && type.isNotEmpty) 'type': type,
    };
    dev.log('[StoreFront] GET URL: $endpoint | Query: $query', name: 'StoreFront');
    final result = await _apiService.getrequest(endpoint, query: query);
    return result.fold(
      (failure) {
        dev.log('[StoreFront] getPlans("$category", "$provider") FAIL ($endpoint): ${failure.message}', name: 'StoreFront');
        return Left(failure);
      },
      (data) {
        dev.log('[StoreFront] getPlans("$category", "$provider") SUCCESS ($endpoint): ${jsonEncode(data)}', name: 'StoreFront');
        try {
          dynamic rawList;
          final dynamic dataField = data['data'];

          if (dataField is List) {
            rawList = dataField;
          } else if (dataField is Map) {
            rawList = dataField['plans'] ??
                dataField['items'] ??
                dataField['services'] ??
                dataField['data'];
            if (rawList is! List) {
              for (final val in dataField.values) {
                if (val is List) {
                  rawList = val;
                  break;
                }
              }
            }
          }

          if (rawList is! List) {
            rawList = data['plans'] ?? data['items'] ?? data['services'];
          }

          if (rawList is! List) {
            for (final val in data.values) {
              if (val is List) {
                rawList = val;
                break;
              }
            }
          }

          if (rawList is List) {
            final list = rawList
                .where((e) => e is Map)
                .map((e) => StorefrontPlanModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
            return Right(list);
          }
          return const Right([]);
        } catch (e) {
          dev.log('[StoreFront] getPlans("$category", "$provider") Parsing ERROR: $e', name: 'StoreFront');
          return Left(ServerFailure(e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> updatePlanPrice({
    required String category,
    required String itemCode,
    required double sellPrice,
    required bool isEnabled,
  }) async {
    final endpoint = '${_baseUrl}storefront/services/$category/plans';
    final body = <String, dynamic>{
      'item_code': itemCode,
      'sell_price': sellPrice,
      'is_enabled': isEnabled,
    };
    dev.log('[StoreFront] PUT URL: $endpoint', name: 'StoreFront');
    dev.log('[StoreFront] PUT Request Body: ${jsonEncode(body)}', name: 'StoreFront');
    final result = await _apiService.putrequest(endpoint, body);
    result.fold(
      (failure) => dev.log('[StoreFront] updatePlanPrice FAIL ($endpoint): ${failure.message}', name: 'StoreFront'),
      (data) => dev.log('[StoreFront] updatePlanPrice SUCCESS ($endpoint): ${jsonEncode(data)}', name: 'StoreFront'),
    );
    return result;
  }
}
