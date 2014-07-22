//
//  InvitesViewController.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 7/20/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "InvitesViewController.h"
#import "SplashPageViewController.h"
#import "BoardViewController.h"
#import "DrEditUtilities.h"

@interface InvitesViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *InviteButtons;
@property (strong, nonatomic) GTLDriveFile *driveFile;

@end
/*
 Features to add
 
 1) Message if you have no invites
 2) More information for each of the invites
 
 
 
 */

@implementation InvitesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    //[self loadDriveFiles];
    //self.driveFile = [DrEditUtilities getOneDriveFile:self.driveService withQuery:@"title = 'mathworksheet.jpg'"];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSError *error = [[NSError alloc] init];
    const NSString *rU = rootURL;
    NSString *handoutURL = [rU stringByAppendingString:@"/class/getInvites"];
    NSData* jsonData = [DrEditUtilities getDataFrom:handoutURL];
    NSMutableArray *json = [DrEditUtilities groupsFromJSON:jsonData forKeys:@[@"groups",@"handout"] error:&error];
    [self drawInvites:json];
    // Do any additional setup after loading the view.
}

-(void) drawInvites:(NSMutableArray *)jsonInput{
    //We will eventually use math to draw the views, right now we will use static buttons
    
    //We have a tagCount to have a range of how many buttons we have (tagCount,maxInvites)
    int tagCount = 0;
    int maxInvites = ((NSArray *)jsonInput[0]).count;
    NSArray *handouts = jsonInput[1];

    //We iterate through each of the invites and we enable the ones that have a corresponding handout
    for (int i = 0; i < self.InviteButtons.count; i++) {
        UIButton* button = self.InviteButtons[i];
        if (button.tag>=tagCount && button.tag<maxInvites){
            button.enabled = YES;
            [button setTitle:[NSString stringWithFormat:@"%@",handouts[button.tag]] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor greenColor];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark custom methods

- (IBAction)acceptInvite:(id)sender {
    //we will get the file once we accept the invite. Then we can go ahead and call the perform from segue as a callback
    [self getOneDriveFilewithQuery:@"title = 'mathworksheet.jpg'"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"acceptInvite"]){
        BoardViewController *viewController = [segue destinationViewController];
        viewController.driveService = self.driveService;
        viewController.withHandout = YES;
        //The first item should be the only one!
        viewController.driveFile = self.driveFile;
        NSLog(@"the drive file in the view controller is: %@",viewController.driveFile);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)getOneDriveFilewithQuery:(NSString *)search; {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    //query.q = @"mimeType = 'text/plain'";
    //NSString *search = @"title = 'mathworksheet.jpg'";
    query.q = search;
    UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading files"
                                                             delegate:self];
    [self.driveService executeQuery:query completionHandler: ^(GTLServiceTicket *ticket,
                                                               GTLDriveFileList *files,
                                                               NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil) {
            //Here we will assume that there is only one file with that Given Name
            if (files.items.count>0){
                
                self.driveFile = [files.items objectAtIndex:0];
            }
            else{
                self.driveFile = nil;
            }
            [self performSegueWithIdentifier:@"acceptInvite" sender:self];
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
    }];
    
    //We need to use NStimer and fire nil if the item times out after querying for 60 seconds.
    //We can create an error boolean and set it to True if nothing works out
}



@end
