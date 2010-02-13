//
//  FakeLocationAppDelegate.m
//  FakeLocation
//
//  Created by Esad Hajdarevic on 2/13/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
//

#import "FakeLocationAppDelegate.h"
#import "FakeLocationViewController.h"

@implementation FakeLocationAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
