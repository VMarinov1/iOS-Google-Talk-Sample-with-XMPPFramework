//
//  XMPPCommunicationController.h
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 28.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMPPCommunicationProtocol <NSObject>


- (void)didLogin:(BOOL)success withError:(NSError*)error;


@end

@interface XMPPCommunicationController : NSObject

- (BOOL)connectWithUser:(NSString*)username andPassword:(NSString*)password;
- (void)terminate;

@property (nonatomic, weak) id<XMPPCommunicationProtocol> delegate;

@end
