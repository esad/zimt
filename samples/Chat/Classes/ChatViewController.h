//
//  ChatViewController.h
//  Chat
//
//  Created by Esad Hajdarevic on 2/16/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Zimt/Zimt.h"

@interface ChatViewController : UIViewController<ZTWebSocketDelegate,UITextFieldDelegate> {
    ZTWebSocket* webSocket;
    IBOutlet UITextField* textField;
    IBOutlet UITextView* textView;
    IBOutlet UIActivityIndicatorView* activityIndicator;
    int messages;
    
    IBOutlet UIButton* reconnectButton;
}

-(IBAction)reconnect:(id)sender;
@end