//
//  UserSettings.h
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 28.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (assign, nonatomic) BOOL isAuthenticated;
@property (nonatomic, strong) NSString *jid;

@end
