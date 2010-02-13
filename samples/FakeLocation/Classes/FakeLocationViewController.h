//
//  FakeLocationViewController.h
//  FakeLocation
//
//  Created by Esad Hajdarevic on 2/13/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface FakeLocationViewController : UIViewController<MKAnnotation,MKMapViewDelegate,CLLocationManagerDelegate> {
    IBOutlet MKMapView* mapView;
    CLLocationManager* locationManager;
    CLLocation* location;
}

@property(readwrite,retain) CLLocation* location;

@end

