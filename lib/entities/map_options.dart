import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapOptions {
  ///this will override the displyLocation of google maps.
  final CameraPosition? initialCameraPosition;
  final bool? compassEnabled;
  final bool? mapToolbarEnabled;
  final bool? scrollGestureEnabled;
  final bool? myLocationEnabled;
  final bool? myLocationButtonEnabled;
  final bool? zoomControllEnabled;
  final bool? zoomGestureEnabled;
  final bool? rotateGestureEnabled;
  final BitmapDescriptor? markerIcon;
  final MapType? mapType;
  MapOptions({
    this.initialCameraPosition,
    this.compassEnabled,
    this.mapToolbarEnabled,
    this.scrollGestureEnabled,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
    this.zoomControllEnabled,
    this.markerIcon,
    this.mapType,
    this.rotateGestureEnabled,
    this.zoomGestureEnabled,
  });
}
