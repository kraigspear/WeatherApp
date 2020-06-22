# WeatherApp

![](images/hero.png)

Demonstration of a simple iOS app that shows the weather for the current location

### Notes
This App follows the MVVM pattern using Combine (new to iOS 13); however, it still uses UIKit.
The idea is that the same ViewModels could be used with SwiftUI, but this was not attempted. 

- On App Startup / Foregrounded 
  - Checks if locations permissions are on
    - If location permissions are not on show embedded ViewController with a button to go to settings to turn them on
  - Checks if location permissions are restricted or denied
    - Shows same embedded ViewController allowing to change in settings
  


  
