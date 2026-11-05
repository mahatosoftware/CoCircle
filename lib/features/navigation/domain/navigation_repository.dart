import 'navigation_route_model.dart';

abstract class NavigationRepository {
  Future<NavigationRouteModel> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  });
}
