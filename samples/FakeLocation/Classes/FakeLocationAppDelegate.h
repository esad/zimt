//
//  FakeLocationAppDelegate.h
//  FakeLocation
//
//  Created by Esad Hajdarevic on 2/13/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FakeLocationViewController;

@interface FakeLocationAppDelegate : NSObject <UIApplicationDelegate,ZTWebSocketDelegate> {
    UIWindow *window;
    FakeLocationViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FakeLocationViewController *viewController;

@end

