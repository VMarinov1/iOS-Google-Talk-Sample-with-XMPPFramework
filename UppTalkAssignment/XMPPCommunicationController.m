//
//  XMPPCommunicationController.m
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 28.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "XMPPCommunicationController.h"
#import "XMPPStream.h"
#import "XMPPJID.h"
#import "XMPPLogging.h"
#import "XMPP.h"
#import "XMPPLogging.h"

#import "DDLog.h"
#import "DDTTYLogger.h"


#define kGoogleHostName @"talk.google.com"
static const int ddLogLevel = LOG_LEVEL_INFO;

@interface XMPPCommunicationController ()

@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) NSString *password;

@end

@implementation XMPPCommunicationController


- (id)init{
    if(self = [super init]){
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
        if(self.xmppStream == nil){
            self.xmppStream = [[XMPPStream alloc]init];
            [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        }
        return self;
    }
    return nil;
}

#pragma mark-
/*! @brief login user with password in GTalk */
- (BOOL)connectWithUser:(NSString*)username andPassword:(NSString*)password
{
    if ([self.xmppStream isConnected] == YES) {
        return YES;
    }
    self.password = password;
    self.xmppStream.myJID = [XMPPJID jidWithString:username];
    self.xmppStream.hostName = kGoogleHostName;
    
    if (self.xmppStream.myJID  == nil || password == nil) {
        return NO;
    }
    
    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        if([self.delegate respondsToSelector:@selector(didLogin:withError:)]){
            [self.delegate didLogin:NO withError:error];
        }
        return NO;
    }
    
    return YES;
}
- (void)disconnect
{
    [self.xmppStream disconnect];
}

/*! @brief set user's status to online */
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence];
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
    [presence addChild:priority];
    [[self xmppStream] sendElement:presence];
}

#pragma mark XMPPStream Delegate
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:self.password error:&error])
    {
        if([self.delegate respondsToSelector:@selector(didLogin:withError:)]){
            [self.delegate didLogin:NO withError:error];
        }
        NSLog(@"Error authenticating: %@", error);
    }
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    if([self.delegate respondsToSelector:@selector(didLogin:withError:)]){
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Error authenticating" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"info" code:200 userInfo:details];
        [self.delegate didLogin:NO withError:error];
    }
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    if([self.delegate respondsToSelector:@selector(didLogin:withError:)]){
        [self.delegate didLogin:YES withError:nil];
    }
    [self goOnline];
}

- (void)terminate{
    [self.xmppStream removeDelegate:self];
    [self disconnect];
}

@end
