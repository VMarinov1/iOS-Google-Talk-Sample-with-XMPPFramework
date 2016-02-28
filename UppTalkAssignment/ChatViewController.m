//
//  ChatViewController.m
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 28.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "XMPPUserCoreDataStorageObject.h"

@interface ChatViewController ()

- (IBAction)doSendMessage:(id)sender;

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UITextField *messageField;
@property (nonatomic, strong) NSMutableArray *messages;

@end

@implementation ChatViewController

#pragma mark- XMPPCommunicationProtocol

- (void)didReceiveMessage:(NSString *)message{
    [self.messages addObject:message];
    [self.tableView reloadData];
}

#pragma mark-
- (IBAction)doSendMessage:(id)sender{
    [[AppDelegate getInstance].communication sendMessage:self.messageField.text toJid:[self.receiverUser.jid full]];
    [self.messages addObject:self.messageField.text];
    [self.tableView reloadData];
    self.messageField.text = @"";
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.messages = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppDelegate getInstance].communication.delegate = self;
    self.title = self.receiverUser.nickname;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"XMPPUserCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSString *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = message;
    return cell;
}


@end
