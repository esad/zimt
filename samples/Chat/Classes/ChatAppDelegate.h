//
//  ChatAppDelegate.h
//  Chat
//
//  Created by Esad Hajdarevic on 2/16/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatViewController;

@interface ChatAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ChatViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ChatViewController *viewController;

@end

