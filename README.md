# VisitTrackingDemo

<em>~~ A demo app for Core Location's CLVisit functionality ~~</em>

See [`CLVisit`](https://developer.apple.com/documentation/corelocation/clvisit) / [`CLLocationManager`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1618692-startmonitoringvisits) / [WWDC](https://developer.apple.com/videos/play/wwdc2014/706/) documentation for more info on this functionality.

To use this app, run it on your device, and accept the notification permission prompt. Tap the `Menu` button, and tap `Start Monitoring`. Make sure to choose `Always Allow` on the location permissions prompt.

The app will send you a local notification each time it receives a CLVisit object. You can then view a log of all visits in the app.

This demo app does not interact with any servers; all of your data stays on the device.
