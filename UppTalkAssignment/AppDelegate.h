//
//  AppDelegate.h
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 27.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPCommunicationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) XMPPCommunicationController *communication;

+ (AppDelegate *)getInstance;

@end

