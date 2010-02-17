//
//  ZTWebSocket.m
//  Zimt
//
//  Created by Esad Hajdarevic on 2/14/10.
//  Copyright 2010 OpenResearch Software Development OG. All rights reserved.
//

#import "ZTLog.h"
#import "ZTWebSocket.h"
#import "AsyncSocket.h"

@interface ZTWebSocketWorker : NSObject {
    BOOL running;
    NSCondition* loopAvailableCondition;
    NSRunLoop* loop;
}
-(NSRunLoop*)start;
-(void)stop;
@end

@implementation ZTWebSocketWorker 

-(id)init {
    if (self=[super init]) {
        loopAvailableCondition = [[NSCondition alloc] init];
    }
    return self;
}

-(void)_loop {
    NSAutoreleasePool *outerPool = [[NSAutoreleasePool alloc] init];
    
    //ZTLog(@"worker run loop starting");
    
    loop = [[NSRunLoop currentRunLoop] retain];
    
    [loopAvailableCondition lock];
    [loopAvailableCondition signal];
    [loopAvailableCondition unlock];
    
    do {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0f]];
        //ZTLog(@"I'm in ur runloop doing some polling");
        [pool release];
        @synchronized(self) {
            if (!running) break;
        }
    } while(1);
    
    [loop release];
    loop = nil;
    
    //ZTLog(@"worker run loop finished");
    [outerPool release];
}

-(NSRunLoop*)start {
    @synchronized(self) { running = YES; }
    [NSThread detachNewThreadSelector:@selector(_loop) toTarget:self withObject:nil];
    [loopAvailableCondition lock];
    while (!loop) [loopAvailableCondition wait];
    [loopAvailableCondition unlock];
    return loop;
}

-(void)stop {
    @synchronized(self) { running = NO; }
}

-(void)dealloc {
    [loopAvailableCondition release];
    [super dealloc];
}

@end

NSString* const ZTWebSocketErrorDomain = @"ZTWebSocketErrorDomain";
NSString* const ZTWebSocketException = @"ZTWebSocketException";

enum {
    ZTWebSocketTagHandshake = 0,
    ZTWebSocketTagMessage = 1
};

@implementation ZTWebSocket

@synthesize delegate, url, origin, connected;

#pragma mark Initializers

+ (id)webSocketWithURLString:(NSString*)urlString delegate:(id<ZTWebSocketDelegate>)aDelegate {
    return [[[ZTWebSocket alloc] initWithURLString:urlString delegate:aDelegate] autorelease];
}

-(id)initWithURLString:(NSString *)urlString delegate:(id<ZTWebSocketDelegate>)aDelegate {
    if (self=[super init]) {
        self.delegate = aDelegate;
        url = [[NSURL URLWithString:urlString] retain];
        if (![url.scheme isEqualToString:@"ws"]) {
            [NSException raise:ZTWebSocketException format:[NSString stringWithFormat:@"Unsupported protocol %@",url.scheme]];
        }
        socket = [[AsyncSocket alloc] initWithDelegate:self];
        worker = [[ZTWebSocketWorker alloc] init];
    }
    return self;
}

#pragma mark Delegate dispatch methods

#define DISPATCH_FAILURE(code) [self performSelectorOnMainThread:@selector(_dispatchFailure:) withObject:[NSNumber numberWithInteger:code] waitUntilDone:NO]
-(void)_dispatchFailure:(NSNumber*)code {
    if(delegate && [delegate respondsToSelector:@selector(webSocket:didFailWithError:)]) {
        [delegate webSocket:self didFailWithError:[NSError errorWithDomain:ZTWebSocketErrorDomain code:[code intValue] userInfo:nil]];
    }
}

#define DISPATCH_CLOSED() [self performSelectorOnMainThread:@selector(_dispatchClosed) withObject:nil waitUntilDone:NO]
-(void)_dispatchClosed {
    if (delegate && [delegate respondsToSelector:@selector(webSocketDidClose:)]) {
        [delegate webSocketDidClose:self];
    }
}

#define DISPATCH_OPENED() [self performSelectorOnMainThread:@selector(_dispatchOpened) withObject:nil waitUntilDone:NO]
-(void)_dispatchOpened {
    if (delegate && [delegate respondsToSelector:@selector(webSocketDidOpen:)]) {
        [delegate webSocketDidOpen:self];
    }
}

#define DISPATCH_MESSAGE_RECEIVED(msg) [self performSelectorOnMainThread:@selector(_dispatchMessageReceived:) withObject:msg waitUntilDone:NO]
-(void)_dispatchMessageReceived:(NSString*)message {
    if (delegate && [delegate respondsToSelector:@selector(webSocket:didReceiveMessage:)]) {
        [delegate webSocket:self didReceiveMessage:message];
    }
}

#define DISPATCH_MESSAGE_SENT() [self performSelectorOnMainThread:@selector(_dispatchMessageSent) withObject:nil waitUntilDone:NO]
-(void)_dispatchMessageSent {
    if (delegate && [delegate respondsToSelector:@selector(webSocketDidSendMessage:)]) {
        [delegate webSocketDidSendMessage:self];
    }
}

#pragma mark Private

-(void)_readNextMessage {
    [socket readDataToData:[NSData dataWithBytes:"\xFF" length:1] withTimeout:-1 tag:ZTWebSocketTagMessage];
}

#pragma mark Public interface

-(void)close {
    [socket disconnectAfterReadingAndWriting];
}

-(void)open {
    if (!connected) {
        [socket connectToHost:url.host onPort:[url.port intValue] withTimeout:5 error:nil];
        NSRunLoop* workerLoop = [worker start];
        [socket moveToRunLoop:workerLoop];
    }
}

-(void)send:(NSString*)message {
    NSMutableData* data = [NSMutableData data];
    [data appendBytes:"\x00" length:1];
    [data appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:"\xFF" length:1];
    [socket writeData:data withTimeout:-1 tag:ZTWebSocketTagMessage];
}

#pragma mark AsyncSocket delegate methods

-(void)onSocketDidDisconnect:(AsyncSocket *)sock {
    connected = NO;
    [worker stop];
}

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    if (!connected) {
        DISPATCH_FAILURE(ZTWebSocketErrorConnectionFailed);
        //[self _dispatchFailure:ZTWebSocketErrorConnectionFailed];
    } else {
        DISPATCH_CLOSED();
        //[self _dispatchClosed];
    }
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSString* requestOrigin = self.origin;
    if (!requestOrigin) requestOrigin = [NSString stringWithFormat:@"http://%@",url.host];
        
    NSString* getRequest = [NSString stringWithFormat:@"GET %@ HTTP/1.1\r\n"
                                                       "Upgrade: WebSocket\r\n"
                                                       "Connection: Upgrade\r\n"
                                                       "Host: %@\r\n"
                                                       "Origin: %@\r\n"
                                                       "\r\n",
                                                        url.path,url.host,requestOrigin];
    [socket writeData:[getRequest dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:ZTWebSocketTagHandshake];
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == ZTWebSocketTagHandshake) {
        [sock readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:ZTWebSocketTagHandshake];
    } else if (tag == ZTWebSocketTagMessage) {
        DISPATCH_MESSAGE_SENT();
        //[self _dispatchMessageSent];
    }
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == ZTWebSocketTagHandshake) {
        NSString* response = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
        if ([response hasPrefix:@"HTTP/1.1 101 Web Socket Protocol Handshake\r\nUpgrade: WebSocket\r\nConnection: Upgrade\r\n"]) {
            connected = YES;
            DISPATCH_OPENED();
            //[self _dispatchOpened];
            
            [self _readNextMessage];
        } else {
            DISPATCH_FAILURE(ZTWebSocketErrorHandshakeFailed);
            //[self _dispatchFailure:ZTWebSocketErrorHandshakeFailed];
        }
    } else if (tag == ZTWebSocketTagMessage) {
        char firstByte = 0xFF;
        [data getBytes:&firstByte length:1];
        if (firstByte != 0x00) return; // Discard message
        NSString* message = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(1, [data length]-2)] encoding:NSUTF8StringEncoding] autorelease];
    
        DISPATCH_MESSAGE_RECEIVED(message);
        //[self _dispatchMessageReceived:message];
        [self _readNextMessage];
    }
}

#pragma mark Destructor

-(void)dealloc {
    [worker stop];
    [worker release];
    socket.delegate = nil;
    [socket disconnect];
    [socket release];
    [url release];
    [super dealloc];
}

@end

