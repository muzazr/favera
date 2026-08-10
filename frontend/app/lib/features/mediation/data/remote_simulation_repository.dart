import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/models/simulation_model.dart';
import 'simulation_repository.dart';

class RemoteSimulationRepository implements SimulationRepository {
  final ApiClient apiClient;

  RemoteSimulationRepository({required this.apiClient});

  @override
  Future<ImpactSimulation> getImpactSimulation({
    int? monthlyLivingCost,
    int? childCount,
    int? debtAmount,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/simulations/impact',
        queryParameters: {
          if (monthlyLivingCost != null)
            'monthly_living_cost': monthlyLivingCost,
          if (childCount != null) 'child_count': childCount,
          if (debtAmount != null) 'debt_amount': debtAmount,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ImpactSimulation.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppFailure _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final msg = e.response?.data?['message'] as String? ??
        e.message ??
        'Terjadi kesalahan server';
    if (status == 401) return AuthFailure(message: msg);
    if (status == 404) return NotFoundFailure(message: msg);
    if (status == 400 || status == 422) return ValidationFailure(message: msg);
    return NetworkFailure(message: msg);
  }
}
