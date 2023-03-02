import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/////////////////////////////

DirectionResponse directionResponseFromJson(String str) =>
    DirectionResponse.fromJson(json.decode(str));

String directionResponseToJson(DirectionResponse data) =>
    json.encode(data.toJson());

class DirectionResponse {
  LatLngBounds? get bounds {
    try {
      var route = routes.first;
      return LatLngBounds(
          southwest:
              LatLng(route.bounds.southwest.lat, route.bounds.southwest.lng),
          northeast:
              LatLng(route.bounds.northeast.lat, route.bounds.northeast.lng));
    } catch (e) {
      return null;
    }
  }

  int get distance {
    try {
      return routes.first.legs.fold(0,
          (previousValue, element) => previousValue + element.distance.value);
    } catch (e) {
      return -1;
    }
  }

  int get duration {
    try {
      return routes.first.legs.fold(0,
          (previousValue, element) => previousValue + element.duration.value);
    } catch (e) {
      return -1;
    }
  }

  String? get polyline {
    try {
      return routes.first.overviewPolyline.points;
    } catch (e) {
      return null;
    }
  }

  List<LatLng>? get polylineDecoded {
    try {
      return _decode(routes.first.overviewPolyline.points);
    } catch (e) {
      return null;
    }
  }

  List<LatLng> _decode(String input) {
    var list = input.codeUnits;
    List lList = [];
    int index = 0;
    int len = input.length;
    int c = 0;
    List<LatLng> positions = [];
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (int i = 2; i < lList.length; i++) {
      lList[i] += lList[i - 2];
    }

    for (int i = 0; i < lList.length; i += 2) {
      positions.add(LatLng(lList[i], lList[i + 1]));
    }

    return positions;
  }

  //////////////////////////////
  DirectionResponse({
    required this.geocodedWaypoints,
    required this.routes,
    required this.status,
  });

  final List<GeocodedWaypoint> geocodedWaypoints;
  final List<Route> routes;
  final String status;

  factory DirectionResponse.fromJson(Map<String, dynamic> json) =>
      DirectionResponse(
        geocodedWaypoints: List<GeocodedWaypoint>.from(
            json["geocoded_waypoints"]
                .map((x) => GeocodedWaypoint.fromJson(x))),
        routes: List<Route>.from(json["routes"].map((x) => Route.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "geocoded_waypoints":
            List<dynamic>.from(geocodedWaypoints.map((x) => x.toJson())),
        "routes": List<dynamic>.from(routes.map((x) => x.toJson())),
        "status": status,
      };
}

class GeocodedWaypoint {
  GeocodedWaypoint({
    required this.geocoderStatus,
    required this.placeId,
    required this.types,
  });

  final String geocoderStatus;
  final String placeId;
  final List<String> types;

  factory GeocodedWaypoint.fromJson(Map<String, dynamic> json) =>
      GeocodedWaypoint(
        geocoderStatus: json["geocoder_status"],
        placeId: json["place_id"],
        types: List<String>.from(json["types"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "geocoder_status": geocoderStatus,
        "place_id": placeId,
        "types": List<dynamic>.from(types.map((x) => x)),
      };
}

class Route {
  Route({
    required this.bounds,
    required this.copyrights,
    required this.legs,
    required this.overviewPolyline,
    required this.summary,
    required this.warnings,
    required this.waypointOrder,
  });

  final Bounds bounds;
  final String copyrights;
  final List<Leg> legs;
  final PolylineModel overviewPolyline;
  final String summary;
  final List<dynamic> warnings;
  final List<dynamic> waypointOrder;

  factory Route.fromJson(Map<String, dynamic> json) => Route(
        bounds: Bounds.fromJson(json["bounds"]),
        copyrights: json["copyrights"],
        legs: List<Leg>.from(json["legs"].map((x) => Leg.fromJson(x))),
        overviewPolyline: PolylineModel.fromJson(json["overview_polyline"]),
        summary: json["summary"],
        warnings: List<dynamic>.from(json["warnings"].map((x) => x)),
        waypointOrder: List<dynamic>.from(json["waypoint_order"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "bounds": bounds.toJson(),
        "copyrights": copyrights,
        "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
        "overview_polyline": overviewPolyline.toJson(),
        "summary": summary,
        "warnings": List<dynamic>.from(warnings.map((x) => x)),
        "waypoint_order": List<dynamic>.from(waypointOrder.map((x) => x)),
      };
}

class Bounds {
  Bounds({
    required this.northeast,
    required this.southwest,
  });

  final Northeast northeast;
  final Northeast southwest;

  factory Bounds.fromJson(Map<String, dynamic> json) => Bounds(
        northeast: Northeast.fromJson(json["northeast"]),
        southwest: Northeast.fromJson(json["southwest"]),
      );

  Map<String, dynamic> toJson() => {
        "northeast": northeast.toJson(),
        "southwest": southwest.toJson(),
      };
}

class Northeast {
  Northeast({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  factory Northeast.fromJson(Map<String, dynamic> json) => Northeast(
        lat: json["lat"].toDouble(),
        lng: json["lng"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Leg {
  Leg({
    required this.distance,
    required this.duration,
    required this.endAddress,
    required this.endLocation,
    required this.startAddress,
    required this.startLocation,
    required this.steps,
    required this.trafficSpeedEntry,
    required this.viaWaypoint,
  });

  final Distance distance;
  final Distance duration;
  final String endAddress;
  final Northeast endLocation;
  final String startAddress;
  final Northeast startLocation;
  final List<Step> steps;
  final List<dynamic> trafficSpeedEntry;
  final List<dynamic> viaWaypoint;

  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        distance: Distance.fromJson(json["distance"]),
        duration: Distance.fromJson(json["duration"]),
        endAddress: json["end_address"],
        endLocation: Northeast.fromJson(json["end_location"]),
        startAddress: json["start_address"],
        startLocation: Northeast.fromJson(json["start_location"]),
        steps: List<Step>.from(json["steps"].map((x) => Step.fromJson(x))),
        trafficSpeedEntry:
            List<dynamic>.from(json["traffic_speed_entry"].map((x) => x)),
        viaWaypoint: List<dynamic>.from(json["via_waypoint"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "distance": distance.toJson(),
        "duration": duration.toJson(),
        "end_address": endAddress,
        "end_location": endLocation.toJson(),
        "start_address": startAddress,
        "start_location": startLocation.toJson(),
        "steps": List<dynamic>.from(steps.map((x) => x.toJson())),
        "traffic_speed_entry":
            List<dynamic>.from(trafficSpeedEntry.map((x) => x)),
        "via_waypoint": List<dynamic>.from(viaWaypoint.map((x) => x)),
      };
}

class Distance {
  Distance({
    required this.text,
    required this.value,
  });

  final String text;
  final int value;

  factory Distance.fromJson(Map<String, dynamic> json) => Distance(
        text: json["text"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "value": value,
      };
}

class Step {
  Step({
    required this.distance,
    required this.duration,
    required this.endLocation,
    required this.htmlInstructions,
    required this.polyline,
    required this.startLocation,
    required this.travelMode,
    required this.maneuver,
  });

  final Distance distance;
  final Distance duration;
  final Northeast endLocation;
  final String htmlInstructions;
  final PolylineModel polyline;
  final Northeast startLocation;
  final String travelMode;
  final String? maneuver;

  factory Step.fromJson(Map<String, dynamic> json) => Step(
        distance: Distance.fromJson(json["distance"]),
        duration: Distance.fromJson(json["duration"]),
        endLocation: Northeast.fromJson(json["end_location"]),
        htmlInstructions: json["html_instructions"],
        polyline: PolylineModel.fromJson(json["polyline"]),
        startLocation: Northeast.fromJson(json["start_location"]),
        travelMode: json["travel_mode"],
        maneuver: json["maneuver"] == null ? null : json["maneuver"],
      );

  Map<String, dynamic> toJson() => {
        "distance": distance.toJson(),
        "duration": duration.toJson(),
        "end_location": endLocation.toJson(),
        "html_instructions": htmlInstructions,
        "polyline": polyline.toJson(),
        "start_location": startLocation.toJson(),
        "travel_mode": travelMode,
        "maneuver": maneuver == null ? null : maneuver,
      };
}

class PolylineModel {
  PolylineModel({
    required this.points,
  });

  final String points;

  factory PolylineModel.fromJson(Map<String, dynamic> json) => PolylineModel(
        points: json["points"],
      );

  Map<String, dynamic> toJson() => {
        "points": points,
      };
}

/////////////////////////////

class Directions {
  static const _url = "https://maps.googleapis.com/maps/api/directions/json";
  final String _key;
  LatLng? _destination;
  LatLng? _origin;
  var _mode = "driving";
  //var _traffic_model = "best_guess";
  var _units = "metric";
  List<LatLng> _wayPoints = [];
  Directions(this._key);

  Directions destination(LatLng destination) {
    _destination = destination;
    return this;
  }

  Directions origin(LatLng origin) {
    _origin = origin;
    return this;
  }

  Directions addWaypoint(LatLng waypoint) {
    _wayPoints.add(waypoint);
    return this;
  }

  Directions addWaypoints(List<LatLng> waypoints) {
    _wayPoints.addAll(waypoints);
    return this;
  }

  String? _build() {
    var origin = _composeLocation(_origin);
    if (origin == null) {
      return null;
    }
    var destination = _composeLocation(_destination);
    if (destination == null) {
      return null;
    }
    var waypoints = _composeWaypoints();
    var waypointsText = waypoints.isEmpty ? "" : "&waypoints=$waypoints";
    var r =
        "$_url?origin=$origin&destination=$destination$waypointsText&mode=$_mode&units=$_units&key=$_key";
    debugPrint("direction response $r");
    return r;
  }

  Future<DirectionResponse?> request() async {
    var url = _build();
    if (url == null) {
      return null;
    }
    var uri = Uri.parse(url);
    debugPrint("directionURL $uri");
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var body = response.body;
      var map = json.decode(body);
      return DirectionResponse.fromJson(map);
    }
    return null;
  }

  String? _composeLocation(LatLng? value) {
    if (value == null) {
      return null;
    }
    return "${value.latitude},${value.longitude}";
  }

  String _composeWaypoints() {
    return _wayPoints.map((e) => _composeLocation(e)).join("|");
  }

  Future<DirectionResponse?> process(List<LatLng> locations) async {
    var size = locations.length;
    if (size < 2) {
      return null;
    }
    var origin = locations.first;
    var destination = locations.last;
    List<LatLng> waypoints = [];
    if (size > 2) {
      waypoints = locations.skip(1).take(size - 2).toList();
    }
    clear();
    return await this
        .origin(origin)
        .destination(destination)
        .addWaypoints(waypoints)
        .request();
  }

  clear() {
    _origin = null;
    _destination = null;
    _wayPoints.clear();
  }
}
