#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ZTFakeLocationManager : CLLocationManager {
    int _currentWaypoint;
	NSMutableArray *_waypoints;
    
	NSTimer* _clock;
	CLLocation* _lastLocation;
}

+(id)fakeLocationManagerWithContentsOfFile:(NSString*)path;

@end
