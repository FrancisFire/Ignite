import 'dart:convert';
import '../../apicontrollers/hydrants_apicontroller.dart';
import '../../models/hydrant.dart';
import '../hydrants_services.dart';

class BackendHydrantsServices implements HydrantsServices {
  HydrantsApiController _controller;

  BackendHydrantsServices(String ip) {
    _controller = new HydrantsApiController(ip);
  }

  @override
  Future<List<Hydrant>> getApprovedHydrants() async {
    String controllerJson = await _controller.getApprovedHydrants();
    var parsedJson = json.decode(controllerJson);
    List<Hydrant> hydrants = new List<Hydrant>();
    for (var hydrant in parsedJson) {
      hydrants.add(new Hydrant(
          hydrant["id"],
          hydrant["attacks"][0],
          hydrant["attacks"][1],
          hydrant["bar"],
          hydrant["cap"],
          hydrant["city"],
          hydrant["geopoint"]["latitude"],
          hydrant["geopoint"]["longitude"],
          hydrant["color"],
          DateTime.parse(hydrant["lastCheck"]),
          hydrant["notes"],
          hydrant["opening"],
          hydrant["streetName"],
          hydrant["streetNumber"],
          hydrant["type"],
          hydrant["vehicle"]));
    }
    return hydrants;
  }

  @override
  Future<Hydrant> getHydrantById(String id) async {
    String controllerJson = await _controller.getHydrantById(id);
    if (controllerJson == "") {
      return null;
    }
    var hydrant = json.decode(controllerJson);
    return new Hydrant(
        hydrant["id"],
        hydrant["attacks"][0],
        hydrant["attacks"][1],
        hydrant["bar"],
        hydrant["cap"],
        hydrant["city"],
        hydrant["geopoint"]["latitude"],
        hydrant["geopoint"]["longitude"],
        hydrant["color"],
        DateTime.parse(hydrant["lastCheck"]),
        hydrant["notes"],
        hydrant["opening"],
        hydrant["streetName"],
        hydrant["streetNumber"],
        hydrant["type"],
        hydrant["vehicle"]);
  }

  @override
  Future<Hydrant> addHydrant(Hydrant newHydrant) async {
    String controllerJson = await _controller.addHydrant(newHydrant);
    if (controllerJson == "") {
      return null;
    }
    var hydrant = json.decode(controllerJson);
    return new Hydrant(
        hydrant["id"],
        hydrant["attacks"][0],
        hydrant["attacks"][1],
        hydrant["bar"],
        hydrant["cap"],
        hydrant["city"],
        hydrant["geopoint"]["latitude"],
        hydrant["geopoint"]["longitude"],
        hydrant["color"],
        hydrant["lastCheck"],
        hydrant["notes"],
        hydrant["opening"],
        hydrant["streetName"],
        hydrant["streetNumber"],
        hydrant["type"],
        hydrant["vehicle"]);
  }

  @override
  Future<bool> deleteHydrant(String id) async {
    String controllerJson = await _controller.deleteHydrant(id);
    return controllerJson == "true";
  }

  @override
  Future<Hydrant> updateHydrant(Hydrant updatedHydrant) async {
    String controllerJson = await _controller.updateHydrant(updatedHydrant);
    if (controllerJson == "") {
      return null;
    }
    var hydrant = json.decode(controllerJson);
    return new Hydrant(
        hydrant["id"],
        hydrant["attacks"][0],
        hydrant["attacks"][1],
        hydrant["bar"],
        hydrant["cap"],
        hydrant["city"],
        hydrant["geopoint"]["latitude"],
        hydrant["geopoint"]["longitude"],
        hydrant["color"],
        hydrant["lastCheck"],
        hydrant["notes"],
        hydrant["opening"],
        hydrant["streetName"],
        hydrant["streetNumber"],
        hydrant["type"],
        hydrant["vehicle"]);
  }
}
