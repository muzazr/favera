import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/api_error_decoder.dart';
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
      throw ApiErrorDecoder.decode(e);
    }
  }
}
