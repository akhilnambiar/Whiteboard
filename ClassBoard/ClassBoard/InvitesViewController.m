//
//  InvitesViewController.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 7/20/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "InvitesViewController.h"
#import "ClassViewController.h"
#import "BoardViewController.h"
#import "DrEditUtilities.h"

@interface InvitesViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *InviteButtons;
@property (strong, nonatomic) GTLDriveFile *driveFile;
@property (weak, nonatomic) IBOutlet UILabel *InviteTitle;
@property NSDictionary* jsonResp;
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
    [self.InviteTitle setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:55]];
    for (UIButton* b in self.InviteButtons){
        [b.titleLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:35]];
    }
    //NSError *error = [[NSError alloc] init];
    const NSString *rU = rootURL;
    NSString *handoutURL = [rU stringByAppendingString:@"get_invites/"];
    
    [self getDataFrom:handoutURL withKeys:@[@"user_id",@"teacher",@"period"] withValues:@[self.userId,[self.userData objectForKey:@"teacher"],[self.userData objectForKey:@"period"] ] ];
    // Do any additional setup after loading the view.
}

-(void) drawInvites{
    //We will eventually use math to draw the views, right now we will use static buttons
    
    //We have a tagCount to have a range of how many buttons we have (tagCount,maxInvites)
    int tagCount = 0;
    NSInteger maxInvites = [[self.jsonResp objectForKey:@"file_name"] count];
    NSArray *handouts = [self.jsonResp objectForKey:@"file_name"];

    //We iterate through each of the invites and we enable the ones that have a corresponding handout
    for (int i = 0; i < self.InviteButtons.count; i++) {
        UIButton* button = self.InviteButtons[i];
        if (button.tag>=tagCount && button.tag<maxInvites){
            button.enabled = YES;
            [button setTitle:[NSString stringWithFormat:@"%@",handouts[button.tag]] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithRed:179.0/255.0 green:187.0/255.0 blue:225.0/255.0 alpha:1];
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
    //we know the sender is a UIButton
    UIButton* s = (UIButton *) sender;
    NSString *query =[NSString stringWithFormat:@"title = '%@'",s.titleLabel.text] ;
    [self getOneDriveFilewithQuery:query];
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

- (NSData *) getDataFrom:(NSString *)url withKeys:(NSArray *)keys withValues:(NSArray *)values{
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    int i = 0;
    for (NSString *x in keys){
        [dict setObject:[values objectAtIndex:i] forKey:x];
        i++;
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!data) {
        return NO;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    [self groupsFromJSON:oResponseData forKeys:@[@"file_name",@"errcode",@"date"] error:&error];
    return oResponseData;
}


- (void)groupsFromJSON:(NSData *)objectNotation forKeys:(NSArray *)keys error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    
    if (localError != nil) {
        *error = localError;
    }
    //FIX
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSString *key in keys){
        NSArray *group = [parsedObject objectForKey:key];
        [result addObject:group];
    }
    self.jsonResp =  parsedObject;
    NSLog(@"The JSON Object %@",self.jsonResp);
    [self drawInvites];
}

@end
