//
//  DrEditFilesListViewController.m
//  GoogleLogin
//
//  Created by Akhil Nambiar on 6/22/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "DrEditFilesListViewController.h"

#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"

#import "DrEditFileEditViewController.h"
#import "DrEditUtilities.h"

// Constants used for OAuth 2.0 authorization.
static NSString *const kKeychainItemName = @"iOSDriveSample: Google Drive";
static NSString *const kClientId = @"919063903792-mq1o9pmi47qdbe2ar1rv72fhohta9unf.apps.googleusercontent.com";
static NSString *const kClientSecret = @"_4RSLRU9KjLFjZZiVXgEpFT5";


@interface DrEditFilesListViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *authButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;




@property (weak, readonly) GTLServiceDrive *driveService;
@property (retain) NSMutableArray *driveFiles;
@property BOOL isAuthorized;

- (IBAction)authButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;


- (void)toggleActionButtons:(BOOL)enabled;
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth;
- (void)loadDriveFiles;
@end


@implementation DrEditFilesListViewController
@synthesize addButton = _addButton;
@synthesize authButton = _authButton;
@synthesize refreshButton = _refreshButton;
@synthesize driveFiles = _driveFiles;
@synthesize isAuthorized = _isAuthorized;


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:NO];
    
    // Check for authorization.
    GTMOAuth2Authentication *auth =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientId
                                                      clientSecret:kClientSecret];
    if ([auth canAuthorize]) {
        [self isAuthorizedWithAuthentication:auth];
    }
}

- (void)viewDidUnload
{
    [self setAddButton:nil];
    [self setRefreshButton:nil];
    [self setAuthButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Sort Drive Files by modified date (descending order).
    [self.driveFiles sortUsingComparator:^NSComparisonResult(GTLDriveFile *lhs,
                                                             GTLDriveFile *rhs) {
        return [rhs.modifiedDate.date compare:lhs.modifiedDate.date];
    }];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.driveFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    GTLDriveFile *file = [self.driveFiles objectAtIndex:indexPath.row];
    cell.textLabel.text = file.title;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DrEditFileEditViewController *viewController = [segue destinationViewController];
    NSString *segueIdentifier = segue.identifier;
    viewController.driveService = [self driveService];
    viewController.delegate = self;
    
    if ([segueIdentifier isEqualToString:@"editFile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GTLDriveFile *file = [self.driveFiles objectAtIndex:indexPath.row];
        viewController.driveFile = file;
        viewController.fileIndex = indexPath.row;
    } else if ([segueIdentifier isEqualToString:@"addFile"]) {
        viewController.driveFile = [GTLDriveFile object];
        viewController.fileIndex = -1;
    }
}

- (NSInteger)didUpdateFileWithIndex:(NSInteger)index
                          driveFile:(GTLDriveFile *)driveFile {
    if (index == -1) {
        if (driveFile != nil) {
            // New file inserted.
            [self.driveFiles insertObject:driveFile atIndex:0];
            index = 0;
        }
    } else {
        if (driveFile != nil) {
            // File has been updated.
            [self.driveFiles replaceObjectAtIndex:index withObject:driveFile];
        } else {
            // File has been deleted.
            [self.driveFiles removeObjectAtIndex:index];
            index = -1;
        }
    }
    return index;
}

- (GTLServiceDrive *)driveService {
    static GTLServiceDrive *service = nil;
    
    if (!service) {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}

- (IBAction)authButtonClicked:(id)sender {
    if (!self.isAuthorized) {
        // Sign in.
        SEL finishedSelector = @selector(viewController:finishedWithAuth:error:);
        GTMOAuth2ViewControllerTouch *authViewController =
        [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
                                                   clientID:kClientId
                                               clientSecret:kClientSecret
                                           keychainItemName:kKeychainItemName
                                                   delegate:self
                                           finishedSelector:finishedSelector];
        [self presentModalViewController:authViewController
                                animated:YES];
    } else {
        // Sign out
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        [[self driveService] setAuthorizer:nil];
        self.authButton.title = @"Sign in";
        self.isAuthorized = NO;
        [self toggleActionButtons:NO];
        [self.driveFiles removeAllObjects];
        [self.tableView reloadData];
    }
}

- (IBAction)refreshButtonClicked:(id)sender {
    [self loadDriveFiles];
}

- (void)toggleActionButtons:(BOOL)enabled {
    self.addButton.enabled = enabled;
    self.refreshButton.enabled = enabled;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
    if (error == nil) {
        [self isAuthorizedWithAuthentication:auth];
    }
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [[self driveService] setAuthorizer:auth];
    self.authButton.title = @"Sign out";
    self.isAuthorized = YES;
    [self toggleActionButtons:YES];
    [self loadDriveFiles];
}

- (void)loadDriveFiles {
    //GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    GTLQueryDrive *query2 = [GTLQueryDrive queryForAboutGet];
    GTLQueryDrive *query3 = [GTLQueryDrive queryForChildrenListWithFolderId:@"0AKqTjm5nG9baUk9PVA"];
    //query.q = @"mimeType = 'text/plain'";
    
    //UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading files" delegate:self];
    /*
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFileList *files,
                                                              NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil) {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
            }
            //NSLog(@"%@",files.ETag);
            //NSLog(@"%@",files.items);
            //NSLog(@"%@",files.nextLink);
            [self.driveFiles removeAllObjects];
            [self.driveFiles addObjectsFromArray:files.items];
            [self.tableView reloadData];
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
    }];
    */
    //Another Query to Execute, based on getting the information about their googledrive account
    
    [self.driveService executeQuery:query2 completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveAbout *about,
                                                              NSError *error) {
        //[alert dismissWithClickedButtonIndex:0 animated:YES];
        
        if (error == nil) {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
                NSLog(@"Their name is, %@",about.name);
                NSLog(@"The root forlder is %@",about.rootFolderId);
                
            }
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
    }];
    
    [self.driveService executeQuery:query3 completionHandler:^(GTLServiceTicket *ticket,
                                                               GTLDriveChildList *child,
                                                               NSError *error) {
        //[alert dismissWithClickedButtonIndex:0 animated:YES];
        
        if (error == nil) {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
                NSLog(@"The items in the folder are %@",child.items);
                
            }
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
    }];
    
}
@end