import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:place_picker/entities/entities.dart';
import 'package:place_picker/entities/localization_item.dart';
import 'package:place_picker/widgets/widgets.dart';

import '../uuid.dart';

/// Place picker widget made with map widget from
/// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
/// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
///
/// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
/// and `Places API`  enabled for it
class PlacePicker extends StatefulWidget {
  /// API key generated from Google Cloud Console. You can get an API key
  /// [here](https://cloud.google.com/maps-platform/)
  final String apiKey;

  /// Location to be displayed when screen is showed. If this is set or not null, the
  /// map does not pan to the user's current location.
  final LatLng? displayLocation;
  LocalizationItem? localizationItem;
  LatLng defaultLocation = LatLng(10.5381264, 73.8827201);

  PlacePicker(this.apiKey,
      {this.displayLocation, this.localizationItem, LatLng? defaultLocation}) {
    if (this.localizationItem == null) {
      this.localizationItem = new LocalizationItem();
    }
    if (defaultLocation != null) {
      this.defaultLocation = defaultLocation;
    }
  }

  @override
  State<StatefulWidget> createState() => PlacePickerState();
}

/// Place picker state
class PlacePickerState extends State<PlacePicker> {
  final Completer<GoogleMapController> mapController = Completer();
  LatLng? _currentLocation;
  bool _loadMap = false;

  /// Indicator for the selected location
  final Set<Marker> markers = Set();

  /// Result returned after user completes selection
  LocationResult? locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry? overlayEntry;

  List<NearbyPlace> nearbyPlaces = [];

  /// Session token required for autocomplete API call
  String sessionToken = Uuid().generateV4();

  GlobalKey appBarKey = GlobalKey();

  bool hasSearchTerm = false;

  String previousSearchTerm = '';

  // constructor
  // PlacePickerState();

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.displayLocation == null) {
      _getCurrentLocation().then((value) {
        if (value != null) {
          setState(() {
            _currentLocation = value;
          });
        } else {
          //Navigator.of(context).pop(null);
          print("getting current location null");
        }
        setState(() {
          _loadMap = true;
        });
      }).catchError((e) {
        if (e is LocationServiceDisabledException) {
          Navigator.of(context).pop(null);
        } else {
          setState(() {
            _loadMap = true;
          });
        }
        print(e);
        //Navigator.of(context).pop(null);
      });
    } else {
      setState(() {
        markers.add(Marker(
          position: widget.displayLocation!,
          markerId: MarkerId("selected-location"),
        ));
        _loadMap = true;
      });
    }
  }

  @override
  void dispose() {
    this.overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (Platform.isAndroid) {
          locationResult = null;
          _delayedPop();
          return Future.value(false);
        }  else  {
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          key: this.appBarKey,
          title: SearchInput(searchPlace),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: !_loadMap
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: widget.displayLocation ??
                            _currentLocation ??
                            widget.defaultLocation,
                        zoom: _currentLocation == null &&
                                widget.displayLocation == null
                            ? 5
                            : 15,
                      ),
                      minMaxZoomPreference: MinMaxZoomPreference(0, 16),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      buildingsEnabled: false,
                      onMapCreated: onMapCreated,
                      onTap: (latLng) {
                        clearOverlay();
                        moveToLocation(latLng);
                      },
                      markers: markers,
                    ),
            ),
            if (!this.hasSearchTerm)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SelectPlaceAction(getLocationName(), () {
                      if (Platform.isAndroid) {
                        _delayedPop();
                      } else {
                        Navigator.of(context).pop(this.locationResult);
                      }
                    }, widget.localizationItem!.tapToSelectLocation),
                    Divider(height: 8),
                    Padding(
                      child: Text(widget.localizationItem!.nearBy,
                          style: TextStyle(fontSize: 16)),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    ),
                    Expanded(
                      child: ListView(
                        children: nearbyPlaces
                            .map((it) => NearbyPlaceItem(it, () {
                                  if (it.latLng != null) {
                                    moveToLocation(it.latLng!);
                                  }
                                }))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (this.overlayEntry != null) {
      this.overlayEntry?.remove();
      this.overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    // on keyboard dismissal, the search was being triggered again
    // this is to cap that.
    if (place == this.previousSearchTerm) {
      return;
    }

    previousSearchTerm = place;

    if (context == null) {
      return;
    }

    clearOverlay();

    setState(() {
      hasSearchTerm = place.length > 0;
    });

    if (place.length < 1) {
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;

    final RenderBox? appBarBox =
        this.appBarKey.currentContext?.findRenderObject() as RenderBox?;

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarBox?.size.height,
        width: size?.width,
        child: Material(
          elevation: 1,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: <Widget>[
                SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3)),
                SizedBox(width: 24),
                Expanded(
                    child: Text(widget.localizationItem!.findingPlace,
                        style: TextStyle(fontSize: 16)))
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(this.overlayEntry!);

    autoCompleteSearch(place);
  }

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place) async {
    try {
      place = place.replaceAll(" ", "+");

      var endpoint =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
          "key=${widget.apiKey}&"
          "language=${widget.localizationItem!.languageCode}&"
          "input={$place}&sessiontoken=${this.sessionToken}";

      if (this.locationResult != null) {
        endpoint += "&location=${this.locationResult!.latLng?.latitude}," +
            "${this.locationResult!.latLng?.longitude}";
      }

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['predictions'] == null) {
        throw Error();
      }

      List<dynamic> predictions = responseJson['predictions'];

      List<RichSuggestion> suggestions = [];

      if (predictions.isEmpty) {
        AutoCompleteItem aci = AutoCompleteItem();
        aci.text = widget.localizationItem!.noResultsFound;
        aci.offset = 0;
        aci.length = 0;

        suggestions.add(RichSuggestion(aci, () {}));
      } else {
        for (dynamic t in predictions) {
          final aci = AutoCompleteItem()
            ..id = t['place_id']
            ..text = t['description']
            ..offset = t['matched_substrings'][0]['offset']
            ..length = t['matched_substrings'][0]['length'];

          suggestions.add(RichSuggestion(aci, () {
            FocusScope.of(context).requestFocus(FocusNode());
            decodeAndSelectPlace(aci.id!);
          }));
        }
      }

      displayAutoCompleteSuggestions(suggestions);
    } catch (e) {
      print(e);
    }
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(String placeId) async {
    clearOverlay();

    try {
      final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/details/json?key=${widget.apiKey}&" +
              "language=${widget.localizationItem!.languageCode}&" +
              "placeid=$placeId");

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['result'] == null) {
        throw Error();
      }

      final location = responseJson['result']['geometry']['location'];
      if (mapController.isCompleted) {
        moveToLocation(LatLng(location['lat'], location['lng']));
      }
    } catch (e) {
      print(e);
    }
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    Size? size = renderBox?.size;

    final RenderBox? appBarBox =
        this.appBarKey.currentContext?.findRenderObject() as RenderBox?;

    clearOverlay();

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size?.width,
        top: appBarBox?.size.height,
        child: Material(elevation: 1, child: Column(children: suggestions)),
      ),
    );

    Overlay.of(context)?.insert(this.overlayEntry!);
  }

  /// Utility function to get clean readable name of a location. First checks
  /// for a human-readable name from the nearby list. This helps in the cases
  /// that the user selects from the nearby list (and expects to see that as a
  /// result, instead of road name). If no name is found from the nearby list,
  /// then the road name returned is used instead.
  String getLocationName() {
    if (this.locationResult == null) {
      return widget.localizationItem!.unnamedLocation;
    }

    for (NearbyPlace np in this.nearbyPlaces) {
      if (np.latLng == this.locationResult?.latLng &&
          np.name != this.locationResult?.locality) {
        this.locationResult?.name = np.name;
        return "${np.name}, ${this.locationResult?.locality}";
      }
    }

    return "${this.locationResult?.name}, ${this.locationResult?.locality}";
  }

  /// Moves the marker to the indicated lat,lng
  void setMarker(LatLng latLng) {
    // markers.clear();
    setState(() {
      markers.clear();
      markers.add(
          Marker(markerId: MarkerId("selected-location"), position: latLng));
    });
  }

  /// Fetches and updates the nearby places to the provided lat,lng
  void getNearbyPlaces(LatLng latLng) async {
    try {
      final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
          "key=${widget.apiKey}&location=${latLng.latitude},${latLng.longitude}"
          "&radius=150&language=${widget.localizationItem!.languageCode}");

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['results'] == null) {
        throw Error();
      }

      this.nearbyPlaces.clear();

      for (Map<String, dynamic> item in responseJson['results']) {
        final nearbyPlace = NearbyPlace()
          ..name = item['name']
          ..icon = item['icon']
          ..latLng = LatLng(item['geometry']['location']['lat'],
              item['geometry']['location']['lng']);

        this.nearbyPlaces.add(nearbyPlace);
      }

      // to update the nearby places
      setState(() {
        // this is to require the result to show
        this.hasSearchTerm = false;
      });
    } catch (e) {
      //
    }
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  void reverseGeocodeLatLng(LatLng latLng) async {
    try {
      final url = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?"
          "latlng=${latLng.latitude},${latLng.longitude}&"
          "language=${widget.localizationItem!.languageCode}&"
          "key=${widget.apiKey}");

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['results'] == null) {
        throw Error();
      }

      final result = responseJson['results'][0];

      setState(() {
        String name = "";
        String? locality,
            postalCode,
            country,
            administrativeAreaLevel1,
            administrativeAreaLevel2,
            city,
            subLocalityLevel1,
            subLocalityLevel2;
        bool isOnStreet = false;
        if (result['address_components'] is List<dynamic> &&
            result['address_components'].length != null &&
            result['address_components'].length > 0) {
          for (var i = 0; i < result['address_components'].length; i++) {
            var tmp = result['address_components'][i];
            var types = tmp["types"] as List<dynamic>;
            var shortName = tmp['short_name'];
            if (types == null) {
              continue;
            }
            if (i == 0) {
              // [street_number]
              name = shortName;
              isOnStreet = types.contains('street_number');
              // other index 0 types
              // [establishment, point_of_interest, subway_station, transit_station]
              // [premise]
              // [route]
            } else if (i == 1 && isOnStreet) {
              if (types.contains('route')) {
                name += ", $shortName";
              }
            } else {
              if (types.contains("sublocality_level_1")) {
                subLocalityLevel1 = shortName;
              } else if (types.contains("sublocality_level_2")) {
                subLocalityLevel2 = shortName;
              } else if (types.contains("locality")) {
                locality = shortName;
              } else if (types.contains("administrative_area_level_2")) {
                administrativeAreaLevel2 = shortName;
              } else if (types.contains("administrative_area_level_1")) {
                administrativeAreaLevel1 = shortName;
              } else if (types.contains("country")) {
                country = shortName;
              } else if (types.contains('postal_code')) {
                postalCode = shortName;
              }
            }
          }
        }
        locality = locality ?? administrativeAreaLevel1;
        city = locality;
        this.locationResult = LocationResult()
          ..name = name
          ..locality = locality
          ..latLng = latLng
          ..formattedAddress = result['formatted_address']
          ..placeId = result['place_id']
          ..postalCode = postalCode
          ..country = AddressComponent(name: country, shortName: country)
          ..administrativeAreaLevel1 = AddressComponent(
              name: administrativeAreaLevel1,
              shortName: administrativeAreaLevel1)
          ..administrativeAreaLevel2 = AddressComponent(
              name: administrativeAreaLevel2,
              shortName: administrativeAreaLevel2)
          ..city = AddressComponent(name: city, shortName: city)
          ..subLocalityLevel1 = AddressComponent(
              name: subLocalityLevel1, shortName: subLocalityLevel1)
          ..subLocalityLevel2 = AddressComponent(
              name: subLocalityLevel2, shortName: subLocalityLevel2);
      });
    } catch (e) {
      print(e);
    }
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(LatLng latLng) {
    this.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15.0)),
      );
    });

    setMarker(latLng);

    reverseGeocodeLatLng(latLng);

    getNearbyPlaces(latLng);
  }

  void moveToCurrentUserLocation() async {
    if (widget.displayLocation != null) {
      moveToLocation(widget.displayLocation!);
      return;
    }
    if (_currentLocation != null) {
      moveToLocation(_currentLocation!);
    } else {
      moveToLocation(widget.defaultLocation);
    }
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      bool? isOk = await _showLocationDisabledAlertDialog(context);
      if (isOk ?? false) {
        return Future.error(LocationServiceDisabledException());
      } else {
        return Future.error('Location Services is not enabled');
      }
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      //return widget.defaultLocation;
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    try {
      final locationData =
          await Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 30));
      LatLng target = LatLng(locationData.latitude, locationData.longitude);
      //moveToLocation(target);
      print('target:$target');
      return target;
    } on TimeoutException catch (e) {
      final locationData = await Geolocator.getLastKnownPosition();
      if (locationData != null) {
        return LatLng(locationData.latitude, locationData.longitude);
      } else {
        return widget.defaultLocation;
      }
    }
  }

  Future<dynamic> _showLocationDisabledAlertDialog(BuildContext context) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
          context: context,
          builder: (BuildContext ctx) {
            return CupertinoAlertDialog(
              title: Text("Location is disabled"),
              content: Text(
                  "To use location, go to your Settings App > Privacy > Location Services."),
              actions: [
                CupertinoDialogAction(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                CupertinoDialogAction(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ],
            );
          });
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text("Location is disabled"),
              content: Text(
                  "The app needs to access your location. Please enable location service."),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text("OK"),
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          });
    }
  }

  // add delay to the map pop to avoid `Fatal Exception: java.lang.NullPointerException` error on Android
  Future<bool> _delayedPop() async {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        ),
        transitionDuration: Duration.zero,
        barrierDismissible: false,
        barrierColor: Colors.black45,
        opaque: false,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.of(context)
      ..pop()
      ..pop(this.locationResult);
    return Future.value(false);
  }
}
