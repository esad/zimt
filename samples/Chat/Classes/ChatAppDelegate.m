//
//  ChatAppDelegate.m
//  Chat
//
//  Created by Esad Hajdarevic on 2/16/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
//

#import "ChatAppDelegate.h"
#import "ChatViewController.h"

@implementation ChatAppDelegate

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
