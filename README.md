# locationpicker

The missing location picker made in Flutter for Flutter.
<p float="left">
  <img src="https://i.ibb.co/MNKDmJ4/sc1.png" width=400 />
  <img src="https://i.ibb.co/Ry7396K/sc2.png" width=400 />
</p>


⚠️ Please note: This library will <b>NOT</b> be affected by the deprecation of Place Picker as [indicated here](https://developers.google.com/places/android-sdk/placepicker).

## Usage

To use this plugin, add `locationpicker` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).


## Getting Started

This package relies on [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter) to display the map. Follow these guidelines to add your API key to the Android and iOS packages.

Get an API key at <https://cloud.google.com/maps-platform/> if you haven't already.

### Android

Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
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


## Sample Usage
Import the package into your code 

```dart
import 'package:locationpicker/locationpicker.dart';
```

Create a method like below, and call it in `onTap` of a button or InkWell. A `LocationResult` will be returned
with the name and lat/lng of the selected place. You can then handle the result in any way you want.

```dart
void showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("YOUR API KEY")));
    
    // Handle the result in your way
    print(result);
}
```
