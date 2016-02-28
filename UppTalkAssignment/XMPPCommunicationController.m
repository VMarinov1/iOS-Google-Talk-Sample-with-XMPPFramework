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
#import "XMPPReconnect.h"
#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardTempModule.h"
#import "XMPPCapabilities.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPvCardCoreDataStorage.h"


#define kGoogleHostName @"talk.google.com"
static const int ddLogLevel = LOG_LEVEL_INFO;

@interface XMPPCommunicationController (){
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
}

- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket;
- (void)xmppStreamDidConnect:(XMPPStream *)sender;
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error;
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender;
- (void)terminate;

@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;
@property (strong, nonatomic) XMPPRoster *xmppRoster;
@property (strong, nonatomic) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (strong, nonatomic) XMPPvCardTempModule *xmppvCardTempModule;
@property (strong, nonatomic) XMPPCapabilities *xmppCapabilities;
@property (strong, nonatomic) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (assign, nonatomic) BOOL isAuthenticated;

@end

@implementation XMPPCommunicationController

@synthesize xmppvCardAvatarModule;

- (id)init{
    if(self = [super init]){
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
        [self setupStream];
        return self;
    }
    return nil;
}

- (void)setupStream
{
    NSAssert(self.xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _isAuthenticated = NO;
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
                _xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    _xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
    
    _xmppRoster.autoFetchRoster = YES;
    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
    
    _xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesStorage];
    
    _xmppCapabilities.autoFetchHashedCapabilities = YES;
    _xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    [_xmppReconnect         activate:_xmppStream];
    [_xmppRoster            activate:_xmppStream];
    [_xmppvCardTempModule   activate:_xmppStream];
    [xmppvCardAvatarModule activate:_xmppStream];
    [_xmppCapabilities      activate:_xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [self.xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [self.xmppCapabilitiesStorage mainThreadManagedObjectContext];
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
/*! @brief disconnect user and set status to offline */
- (void)disconnect
{
    [self goOffline];
    [self.xmppStream disconnect];
    _isAuthenticated = NO;
}

/*! @brief set user's status to online */
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence];
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
    [presence addChild:priority];
    [[self xmppStream] sendElement:presence];
}
- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
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
    
    if(self.isAuthenticated == NO && [self.delegate respondsToSelector:@selector(didLogin:withError:)]){
        [self.delegate didLogin:YES withError:nil];
    }
    [self goOnline];
    self.isAuthenticated = YES;
}

- (void)terminate{
    [self disconnect];
    [self.xmppStream removeDelegate:self];
    [self.xmppRoster removeDelegate:self];
    
    [self.xmppReconnect         deactivate];
    [self.xmppRoster            deactivate];
    [self.xmppvCardTempModule   deactivate];
    [self.xmppvCardAvatarModule deactivate];
    [self.xmppCapabilities      deactivate];
    
    [self.xmppStream disconnect];
    
    self.xmppStream = nil;
    self.xmppReconnect = nil;
    self.xmppRoster = nil;
    self.xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    self.xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    self.xmppCapabilities = nil;
    self.xmppCapabilitiesStorage = nil;

}

@end
