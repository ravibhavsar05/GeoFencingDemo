# GeoFencingDemo

 ## Requirements

- iOS 11.0+
- Xcode 10.1+
- Swift 5

## Usage
- This Project simply uses the concept of  Geofencing. It is used for region monitoring to regulate when the user enters or leaves a geographic region. 
- The app wakes up whenever the user enters into selected `CLCircularRegion` nd throws notification to the user.
- At this point, the app is fully capable of registering new geofences for monitoring. There is, however, a limitation: As geofences are a shared system resource, Core Location restricts the number of registered geofences to a **maximum of 20 per app.**
- So there is applied strategy in the app that, the [app](https://www.youtube.com/watch?v=ybEIrTCf6yI) will monitor only those 20 locations which are near to the user location.

## Output
![Farmers Market Finder - Animated gif demo](GeoFencingDemo/GeoFencing.gif)
