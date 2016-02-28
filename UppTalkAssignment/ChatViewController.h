//
//  ChatViewController.h
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 28.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPCommunicationController.h"

@class XMPPUserCoreDataStorageObject;

@interface ChatViewController : UIViewController<XMPPCommunicationProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) XMPPUserCoreDataStorageObject *receiverUser;

@end
