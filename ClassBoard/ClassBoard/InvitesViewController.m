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
@property (strong, nonatomic) NSMutableArray *driveFiles;

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
    [self loadDriveFiles];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    const NSString *rU = rootURL;
    NSString *handoutURL = [rU stringByAppendingString:@"/class/getInvites"];
    NSMutableArray* json = [self getDataFrom:handoutURL];
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
            NSLog(@"The title should be %@",[NSString stringWithFormat:@"%@",handouts[button.tag]]);
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

//FOR BETTER REFACTORING, WE CAN MAKE THIS A CLASS METHOD IN UTILITIES THAT YOU CAL JUST CALL!

//Moving this method to DrEditUtilities
- (NSMutableArray *) getDataFrom:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    NSMutableArray* json_array = [self groupsFromJSON:oResponseData error:&error];
    return json_array;
    //return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

- (NSMutableArray *)groupsFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
 
    NSArray *groups = [parsedObject objectForKey:@"groups"];
    NSLog(@"object one is %@",[groups objectAtIndex:0]);
    
    NSArray *handout = [parsedObject objectForKey:@"handout"];
    NSLog(@"object one is %@",[handout objectAtIndex:0]);
 
    //return class;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObject:groups];
    [result addObject:handout];
    return result;
}
- (IBAction)acceptInvite:(id)sender {
    NSLog(@"I'm abbout the segue");
    [self performSegueWithIdentifier:@"acceptInvite" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"acceptInvite"]){
        BoardViewController *viewController = [segue destinationViewController];
        viewController.driveService = self.driveService;
        viewController.withHandout = YES;
        //The first item should be the only one!
        viewController.driveFile = [self.driveFiles objectAtIndex:0];
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

//REWRITE THIS METHOD AND PUT IT IN UTILITIES

- (void)loadDriveFiles {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    //query.q = @"mimeType = 'text/plain'";
    NSString *search = @"title = 'mathworksheet.jpg'";
    query.q = search;
    
    UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading files"
                                                             delegate:self];
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFileList *files,
                                                              NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil) {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
            }
            [self.driveFiles removeAllObjects];
            [self.driveFiles addObjectsFromArray:files.items];
            NSLog(@"THe drive files are:%@",self.driveFiles);
            //[];
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
    }];
}

@end
