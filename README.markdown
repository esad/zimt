# Intro

Zimt is a collection of various utilities that should help you with iPhone Objective-C development. Pretty much like Facebook's Three20, but less UI-Oriented

# Adding Zimt to your project

1. Drag and drop Zimt.xcodeproj to your project's "Groups & Files" sidebar. Make sure "Copy items" is unchecked and "Reference Type" is set to "Relative to Project"

2. From newly added Zimt.xcodeproj, drag and drop libZimt.a to "Targets" > Your application target > "Link binaries with Library"

3. Under "Targets", right click your Application target, choose "Get Info" and under "General" tab add direct dependency to "Zimt"

5. Include Zimt headers in your project: Under "Project" > "Edit Project Settings", go to "Build" tab. Search for "Header Search Paths" and double-click
   it. Add the relative path from your project's directory to the "zimt/src" directory

6. Setup the debug macro: in "Projects" > "Edit Project Settings", under "Build tab", choose "Debug Configuration". Search for "Preprocessor macros", add DEBUG=1

7. If you're using ZTWebSocket, you need to add the CFNetwork to your project.  Right click on the "Frameworks" group in your project (or equivalent) and 
   select "Add" > "Existing Frameworks". Locate CFNetwork.framework and add it to the project.

# What's inside

## ZTFakeLocationManager

CLLocationManager subclass that can read a list of waypoints from a file and simulate location updates. Meant to be used on simulator for testing. See samples/FakeLocation

## ZTWebSocket

Objective-C websocket implementation (based on AsyncSocket)