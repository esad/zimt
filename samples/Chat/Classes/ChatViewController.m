//
//  ChatViewController.m
//  Chat
//
//  Created by Esad Hajdarevic on 2/16/10.
//  Copyright OpenResearch Software Development OG 2010. All rights reserved.
//

#import "ChatViewController.h"

@implementation ChatViewController

-(void)write:(NSString*)text {
    NSMutableString* newText = [NSMutableString stringWithString:textView.text];
    [newText appendString:text];
    [newText appendString:@"\n"];
    textView.text = newText;
    [textView scrollRangeToVisible:NSMakeRange([textView.text length]-1, 1)];
}

-(void)viewDidLoad {
    webSocket = [[ZTWebSocket alloc] initWithURLString:@"ws://localhost:10000/" delegate:self];
    [webSocket open];	
    [textField becomeFirstResponder];
}

-(void)webSocketDidClose:(ZTWebSocket *)webSocket {
    [self write:@"Connection closed"];
    reconnectButton.hidden = NO;
}

-(void)webSocket:(ZTWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (error.code == ZTWebSocketErrorConnectionFailed) {
        [self write:@"Connection failed"];
    } else if (error.code == ZTWebSocketErrorHandshakeFailed) {
        [self write:@"Handshake failed"];
    } else {
        [self write:@"Error"];
    }
    reconnectButton.hidden = NO;
}

-(void)webSocket:(ZTWebSocket *)webSocket didReceiveMessage:(NSString*)message {
    [self write:message];
}

-(void)webSocketDidOpen:(ZTWebSocket *)aWebSocket {
    [self write:@"Connected"];
    reconnectButton.hidden = YES;
}

-(void)webSocketDidSendMessage:(ZTWebSocket *)webSocket {
    messages--;
    if (messages == 0) {
        [activityIndicator stopAnimating];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    if (webSocket.connected) {
        messages++;
        [activityIndicator startAnimating];
        [webSocket send:aTextField.text];
    } else {
        [self write:@"Cannot send message, not connected"];
    }   
    [textField setText:@""];
    return NO;
}

-(IBAction)reconnect:(id)sender {
    if (!webSocket.connected) {
        [webSocket open];
    }
}

-(void)dealloc {
    [webSocket release];
    [super dealloc];
}
@end
