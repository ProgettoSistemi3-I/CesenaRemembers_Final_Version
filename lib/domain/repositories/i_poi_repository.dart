import '../entities/poi.dart';

abstract class IPoiRepository {
  Future<List<Poi>> getPois();
}