//
//  XMPPCommunicationController.h
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 28.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPvCardAvatarModule.h"

@protocol XMPPCommunicationProtocol <NSObject>

- (void)didLogin:(BOOL)success withError:(NSError*)error;

@end

@interface XMPPCommunicationController : NSObject

@property (nonatomic, weak) id<XMPPCommunicationProtocol> delegate;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;

- (BOOL)connectWithUser:(NSString*)username andPassword:(NSString*)password;
- (void)terminate;
- (void)disconnect;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

@end
