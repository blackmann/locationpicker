# Flutter Place Picker [![Pub](https://img.shields.io/pub/v/place_picker.svg)](https://pub.dev/packages/place_picker)

The missing location picker made in Flutter for Flutter. With dark theme and custom localization support.

<p float="left">
  <img src="https://i.ibb.co/yyQRzPx/dark.jpg" width=400 />
  <img src="https://i.ibb.co/Ry7396K/sc2.png" width=400 />
</p>

⚠️ Please note: This library will <b>NOT</b> be affected by the deprecation of Place Picker as [indicated here](https://developers.google.com/places/android-sdk/placepicker).

🍭 Remember to enable `Places API`, `Maps SDK for Android`, `Maps SDK for iOS` and `Geocoding API` for your API key.

## Usage

To use this plugin, add `place_picker` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started

This package relies on [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter) to display the map. Follow these guidelines to add your API key to the Android and iOS packages.

Get an API key at <https://cloud.google.com/maps-platform/> if you haven't already.

### Android

Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml` and add `ACCESS_FINE_LOCATION` permission:

```xml
<manifest ...

  <!-- Add this permission -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

  <application ...
    <!-- Add your api key here -->
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
    <activity ..../>
  </application>
</manifest>
```

Update your gradle.properties file with this:

```groovy
android.enableJetifier=true
android.useAndroidX=true
org.gradle.jvmargs=-Xmx1536M
```

Please also make sure that you have those dependencies in your build.gradle:

```groovy
  // parent level build.gradle (android/build.gradle)
  dependencies {
      classpath 'com.android.tools.build:gradle:3.3.0'
      classpath 'com.google.gms:google-services:4.2.0'
  }
  ...

  // app level build.gradle (android/app/build.gradle)
  compileSdkVersion 28
```

### iOS

Specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

Opt-in to the embedded views preview by adding a boolean property to the app's `Info.plist` file
with the key `io.flutter.embedded_views_preview` and the value `YES`.

![info.plist](https://i.ibb.co/hWN3Y75/plist.png "Place inside the dict values")

Also add these to the dict values in `Info.plist` for location request to work on iOS
![info.plist](https://i.ibb.co/2Y3X2jY/locationperm.png)

## Sample Usage

Import the package into your code

```dart
import 'package:place_picker/place_picker.dart';
```

Create a method like below, and call it in `onTap` of a button or InkWell. A `LocationResult` will be returned
with the name and lat/lng of the selected place. You can then handle the result in any way you want.
Pass in an optional `LatLng displayLocation` to display that location instead. This is useful when you want the map
to display the previously selected location.

```dart
void showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("YOUR API KEY",
                        displayLocation: customLocation,
                        )));

    // Handle the result in your way
    print(result);
}
```
