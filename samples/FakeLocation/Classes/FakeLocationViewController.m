//
//  FakeLocationViewController.m
//  FakeLocation
//
//  Created by Esad Hajdarevic on 2/13/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
//

#import "FakeLocationViewController.h"
#import "Zimt/Zimt.h"

@implementation FakeLocationViewController

@synthesize location;

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if	TARGET_IPHONE_SIMULATOR
	locationManager = [[ZTFakeLocationManager fakeLocationManagerWithContentsOfFile:@"vienna_ring.waypoints"] retain];
#else
	locationManager = [[CLLocationManager alloc] init];
#endif
    
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    

    mapView.delegate = self;
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView* marker = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"userLocation"];
    if (!marker) {
        marker = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userLocation"] autorelease];
        marker.image = [UIImage imageNamed:@"blue_dot.png"];
        marker.annotation = annotation;
        marker.canShowCallout = NO;
    }
    return marker;
}

- (CLLocationCoordinate2D)coordinate {
	return self.location.coordinate;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	self.location = newLocation;
    [mapView removeAnnotation:self];
    [mapView addAnnotation:self];
    
    
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000) animated:YES];
}


@end
