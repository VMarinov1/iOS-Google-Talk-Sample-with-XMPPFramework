//
//  ContactsTableViewController.m
//  UppTalkAssignment
//
//  Created by Vladimir Marinov on 28.02.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "XMPPCommunicationController.h"
#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "DDLog.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "ChatViewController.h"

@interface ContactsTableViewController ()

@property (nonatomic, weak) XMPPUserCoreDataStorageObject *receiverUser;
@end

static const int ddLogLevel = LOG_LEVEL_INFO;

#define kShowChatSeque @"ShowSingleChat"
#define kAvailable @"Available"
#define kAway @"Away"
#define kOffline @"Offline"

@implementation ContactsTableViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[AppDelegate getInstance].communication managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1, sd2];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] reloadData];
}

#pragma mark-
- (void)viewDidLoad {
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [super viewDidLoad];
    self.title = @"Contacts";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kShowChatSeque])
    {
        ChatViewController *vc = [segue destinationViewController];
        [vc setReceiverUser:self.receiverUser];
    }
}
/*! @brief move to parent and unload curret */
- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController]) {
        [[AppDelegate getInstance].communication disconnect];

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    NSArray *sections = [[self fetchedResultsController] sections];
    if (sectionIndex < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
        return sectionInfo.numberOfObjects;
    }
    
    return 0;

}
- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex {
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (sectionIndex < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
        
        int section = [sectionInfo.name intValue];
        switch (section)
        {
            case 0  : return kAvailable;
            case 1  : return kAway;
            default : return kOffline;
        }
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"XMPPUserCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    cell.textLabel.text = user.displayName;
    [self configurePhotoForCell:cell user:user];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.receiverUser = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:kShowChatSeque sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark UITableViewCell helpers

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user {
    if (user.photo != nil)
    {
        cell.imageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[[AppDelegate getInstance].communication xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil){
            cell.imageView.image = [UIImage imageWithData:photoData];
        }
        else {
            cell.imageView.image = nil;
        }
    }
}

@end
