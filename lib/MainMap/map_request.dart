import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const apiKey = "AIzaSyApMbLB6PtNjANdl0eaSWfEdQ8zmDFyEDw";

class GoogleMapsServices{
  Future<String> getRouteCoordinates(double origin_lattitude, double origin_longitude,double destination_lattitude,double destination_longitude)async{
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=$origin_lattitude,$origin_longitude&destination=$destination_lattitude,$destination_longitude&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    print("!!!!!!!!!!!!!!!!");
    print(values);
   

    return values["routes"][0]["overview_polyline"]["points"];
   
  }
}