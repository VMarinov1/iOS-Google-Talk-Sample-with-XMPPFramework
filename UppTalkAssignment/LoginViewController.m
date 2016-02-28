//
//  LoginViewController.m
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 27.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"


#define kContactsSeque @"ShowContacts"

@interface LoginViewController ()

@property (nonatomic) IBOutlet UITextField *usernameField;
@property (nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
}

- (void)viewDidAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [super viewDidAppear:animated];
    [AppDelegate getInstance].communication.delegate = self;
}
     
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (IBAction)doLogin:(id)sender {
    
    [[AppDelegate getInstance].communication connectWithUser:self.usernameField.text andPassword:self.passwordField.text];
    
}
#pragma mark XMPPCommunicationProtocol
     
- (void)didLogin:(BOOL)success withError:(NSError*)error {
    if(success == YES){
        [self performSegueWithIdentifier:kContactsSeque sender:self];
    }
    else if(error != nil){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
