//
//  LoginViewController.m
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 27.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (nonatomic) IBOutlet UITextField* username;
@property (nonatomic) IBOutlet UITextField* password;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.title = @"Login";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (IBAction)doLogin:(id)sender {
    
}


@end
