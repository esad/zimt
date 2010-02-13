#import "ZTFakeLocationManager.h"

#define UPDATE_INTERVAL 1.0

@interface ZTFakeLocationManager(Private) 
-(void)_reachWaypoint;
@end

@implementation ZTFakeLocationManager

-(id)initWithWaypoints:(NSArray*)waypoints {
	if (self = [super init]) {
		NSAssert([waypoints count] > 0, @"Tried creating ZTFakeLocationManager with no waypoints");
        
        _currentWaypoint = 0;
		_waypoints = [waypoints retain];
	}
	return self;
}

+(id)fakeLocationManagerWithContentsOfFile:(NSString*)path {
	NSMutableArray* waypoints = [[[NSMutableArray alloc] init] autorelease];
	NSString *resource = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    
    NSAssert1(resource, @"Waypoints file %@ not found",path);
	
    NSString *contents = [NSString stringWithContentsOfFile:resource usedEncoding:NULL error:NULL];
	NSArray *lines = [contents componentsSeparatedByString:@"\n"];
	
	for (NSString* line in lines) {
		NSArray *latLong = [line componentsSeparatedByString:@","];
		
		if ([latLong count] != 2) break;
		
		CLLocationDegrees lat = [[latLong objectAtIndex:0] doubleValue];
        CLLocationDegrees lon = [[latLong objectAtIndex:1] doubleValue];
		
		CLLocation* location = [[[CLLocation alloc] initWithLatitude:lat longitude:lon] autorelease];
		[waypoints addObject:location];
	}
	return [[[ZTFakeLocationManager alloc] initWithWaypoints:waypoints] autorelease];
}

-(void)startUpdatingLocation {
    [self _reachWaypoint];
    if ([_waypoints count]>1) {
        _clock = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(_reachWaypoint) userInfo:nil repeats:YES];
    }
}

-(void)stopUpdatingLocation {
    if (_clock)	{
        [_clock invalidate];
        _clock = nil;
    }
}

-(void)_reachWaypoint {
	CLLocation* newLocation = [_waypoints objectAtIndex:_currentWaypoint];
	_currentWaypoint++;
	if (_currentWaypoint >= [_waypoints count]) _currentWaypoint = 0;
	[self.delegate locationManager:self didUpdateToLocation:newLocation fromLocation:_lastLocation];
	_lastLocation = newLocation;
}

-(void)dealloc {
    [self stopUpdatingLocation];
	[_waypoints release];
	[super dealloc];
}

@end
