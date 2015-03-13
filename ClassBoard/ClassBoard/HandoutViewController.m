//
//  HandoutViewController.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/29/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//
//

#import "HandoutViewController.h"
#import "SplashPageViewController.h"
#import "ClassViewController.h"
#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "DrEditUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "SaveLocationViewController.h"

@interface HandoutViewController ()
@property (weak, nonatomic) IBOutlet UIView *availableHandouts;
@property (weak, nonatomic) IBOutlet UIButton *blankHandouts;
@property (weak, nonatomic) IBOutlet UIView *handoutView;
@property (weak, nonatomic) GTLServiceDrive *ourDrive;
@property (retain) NSMutableArray *driveFiles;
@property (nonatomic) BOOL withHandout;
@property NSDictionary* jsonResp;
@property (weak, nonatomic) IBOutlet UIButton *blankHandoutButton;
@property (weak, nonatomic) GTLDriveFile *selectedFile;
//These are the 3 buttons you use
@property (weak, nonatomic) UIButton *button1;
@property (weak, nonatomic) UIButton *button2;
@property (weak, nonatomic) UIButton *button3;
//The title labels
@property (weak, nonatomic) UILabel *title_lab1;
@property (weak, nonatomic) UILabel *title_lab2;
@property (weak, nonatomic) UILabel *title_lab3;
//The due date label
@property (weak, nonatomic) UILabel *due_lab1;
@property (weak, nonatomic) UILabel *due_lab2;
@property (weak, nonatomic) UILabel *due_lab3;
//The image for the file
@property (weak, nonatomic) UIImageView *back_image1;
@property (weak, nonatomic) UIImageView *back_image2;
@property (weak, nonatomic) UIImageView *back_image3;

@end

@implementation HandoutViewController

/*
 
 FEATURES WE STILL NEED TO IMPLEMENT:
 
 -Reaction when a button is being clicked
 -http://stackoverflow.com/questions/19666368/reproduce-ios7-buttons-color-effect-when-pressed
 
 -Pull information from the db to populate the list of handouts
 -Pull out JSON objects
 
 BUG: The right hand sidebar will show too!
 
 Logic: Just hide that toolbar and make the visibility 0. Then save and then bring it back!
 
 Note: we need to make sure that the image reacts when we click on it
 
 Note: when we are retriving a specific file, we need to specify this in our method and just return one, should be a design decision.
 
 Note: Loading Many files is just to populate the initial list (there should be a load Files and a getFile). we can encapsulate repeated code in a subroutine
 */

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//SAVEPOINT: You get the handout files, now they just need to be inserted correctly
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.blankHandoutButton.titleLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:75]];
    [self drawHandouts];
}

-(void)viewDidAppear:(BOOL)animated{
    self.withHandout = NO;
    const NSString *rU = rootURL;
    NSString *handoutURL = [rU stringByAppendingString:@"get_handout/"];
    //Note: For now, we will be sending just the first period and the first teacher (later we will look at timestamp to determine this
    NSString *teacher = [[self.userData objectForKey:@"teacher"] objectAtIndex:1];
    NSLog(@"Userdata: %@",self.userData);
    NSNumber* period = (NSNumber*) [[self.userData objectForKey:@"period"] objectAtIndex:1];
    [self getDataFrom:handoutURL withKeys:@[@"teacher",@"period"] withValues:@[teacher,period] responseKey:@[@"errcode",@"file_name",@"google_id"] ];
}

-(void)viewWillDisappear:(BOOL)animated{
    self.button1.hidden = YES;
    self.button2.hidden = YES;
    self.button3.hidden = YES;
    self.title_lab1.hidden = YES;
    self.title_lab2.hidden = YES;
    self.title_lab3.hidden = YES;
    self.due_lab1.hidden = YES;
    self.due_lab2.hidden = YES;
    self.due_lab3.hidden = YES;
    self.back_image1.hidden = YES;
    self.back_image2.hidden = YES;
    self.back_image3.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark REST call
- (NSData *) getDataFrom:(NSString *)url withKeys:(NSArray *)keys withValues:(NSArray *)values responseKey:(NSArray *)respKeys{
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
    [self groupsFromJSON:oResponseData forKeys:respKeys error:&error];
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
    [self afterGetRequest];
    
}

//Note: We cannot make a POST request here. We need to know the handout as well. We need to push this method to the next View
-(void)makePostRequestwithKeys:(NSArray *)keys withValues:(NSArray *)values{
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    int i = 0;
    for (NSString *x in keys){
        [dict setObject:[values objectAtIndex:i] forKey:x];
        i++;
    }
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    const NSString *rU = rootURL;
    NSString *postURL = [rU stringByAppendingString:@"send_invites/"];
    [request setURL:[NSURL URLWithString:postURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //we can maybe take this line out
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    //We don't need to call the segue because it already happends
    //[self performSegueWithIdentifier:@"groupsToHandout" sender:self];
    NSLog(@"Reply: %@", theReply);
}

#pragma mark GoogleDrive
- (void)loadDriveFiles {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    //This block of code will be used to check to see if
    
    NSArray *file_names = [self.jsonResp objectForKey:@"file_name"];
    NSMutableArray *query_ready_fn = [[NSMutableArray alloc] init];
    NSString *y = @"";
    for (NSString *x in file_names){
        y = [NSString stringWithFormat:@"title ='%@'",x];
        [query_ready_fn addObject:y];
    }
    NSString *temp =[[query_ready_fn valueForKey:@"description"] componentsJoinedByString:@" or "];
    query.q = temp;
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
            [self updateButtons];
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
    }];
}


//This is the method that is clicked when you choose to have a handout
-(void) clickButton:(id) sender{
    self.withHandout = YES;
    UIButton *clicked = (UIButton* ) sender;
    NSString *fileTitle = ((GTLDriveFile *)[self.driveFiles objectAtIndex:clicked.tag]).title;
    [self loadHandoutFiles:fileTitle];
    /*
    NSLog(@"username in Handount: %@",[self.userData objectForKey:@"username"]);
    NSLog(@"selectedmates were: %@",self.selectedMates);
     NSLog(@"file title were: %@",fileTitle);
     */
    if (self.groupInvite){
        [self makePostRequestwithKeys:@[@"inviter",@"invitee",@"file_name"] withValues:@[[self.userData objectForKey:@"user_id"],self.selectedMates,fileTitle ] ];
    }
}

-(void)afterGetRequest {
    NSLog(@"The JSON Response that we get is: %@",self.jsonResp);
    NSLog(@"The Error Code is: %@",[self.jsonResp objectForKey:@"errcode"]);
    //NSLog(@"Is it an int:%hhd",[[self.jsonResp objectForKey:@"errcode"] isKindOfClass:[)
    if ([[self.jsonResp objectForKey:@"errcode"] intValue]==1){
        [self loadDriveFiles];
    }
    else{
        [DrEditUtilities showErrorMessageWithTitle:@"Unable to Retrieve Files" message:@"There was an error trying retreive your files." delegate:self];
    }
}

-(void)loadHandoutFiles:(NSString *) file_title {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    //query.q = @"mimeType = 'text/plain'";
    NSString *search = [NSString stringWithFormat:@"title ='%@'",file_title];
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
            //[];
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
        [self performSegueWithIdentifier:@"HandoutToSave" sender:self];
    }];
}

#pragma mark - Buttons
//This method lays out the buttons
-(void) drawHandouts{
    CGFloat height = [self.handoutView bounds].size.height;
    CGFloat width = [self.handoutView bounds].size.width;
    CGFloat cellHeight = height/7;
    CGFloat cellWidth = width*0.8;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button1 = button;
    button.frame = CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight);
    button.backgroundColor = [UIColor grayColor];
    [button setAlpha:0.66];
    [[button layer] setBorderWidth:2.0f];
    [[button layer] setBorderColor:[UIColor blackColor].CGColor];
    button.tintColor = [UIColor blackColor];
    [self.handoutView addSubview:button];
    button.tag=0;
    
    UILabel  *label1a = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight/3)];
    self.title_lab1 = label1a;
    label1a.textColor=[UIColor whiteColor];
    label1a.adjustsFontSizeToFitWidth=YES;
    label1a.textAlignment = NSTextAlignmentCenter;
    label1a.text = @"NULL";
    [self.handoutView addSubview:label1a];
    [label1a setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    
    UILabel  *label1b = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight/3*2)];
    self.due_lab1 = label1b;
    label1b.textColor=[UIColor whiteColor];
    label1b.textAlignment = NSTextAlignmentCenter;
    // We need to pull the due dates as well
    label1b.text = @"NULL";
    [self.handoutView addSubview:label1b];
    [label1b setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight);
    self.back_image1 = imageView;
    [self.handoutView addSubview:self.back_image1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(width*.1, cellHeight, cellWidth, cellHeight);
    button2.backgroundColor = [UIColor grayColor];
    [button2 setAlpha:0.66];
    [[button2 layer] setBorderWidth:2.0f];
    [[button2 layer] setBorderColor:[UIColor blackColor].CGColor];
    button2.tintColor = [UIColor blackColor];
    [self.handoutView addSubview:button2];
    self.button2 = button2;
    //[self.handoutView addSubview:button2];
    
    UILabel  *label2a = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight, cellWidth, cellHeight/3)];
    self.title_lab2 = label2a;
    label2a.textColor=[UIColor whiteColor];
    label2a.adjustsFontSizeToFitWidth=YES;
    label2a.textAlignment = NSTextAlignmentCenter;
    label2a.text = @"";
    [self.handoutView addSubview:label2a];
    [label2a setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    
    UILabel  *label2b = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight, cellWidth, cellHeight/3*2)];
    self.due_lab2 = label2b;
    label2b.textColor=[UIColor whiteColor];
    label2b.textAlignment = NSTextAlignmentCenter;
    label2b.text = @"Due 8/13/2015";
    [self.handoutView addSubview:label2b];
    [label2b setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    
    UIImageView *imageView2 = nil;
    imageView2 = [[UIImageView alloc] init];
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    imageView2.frame = CGRectMake(width*.1, cellHeight, cellWidth, cellHeight);
    self.back_image2 = imageView2;
    [self.handoutView addSubview:imageView2];
    
    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b3.frame = CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight);
    b3.backgroundColor = [UIColor grayColor];
    [b3 setAlpha:0.66];
    [[b3 layer] setBorderWidth:2.0f];
    [[b3 layer] setBorderColor:[UIColor blackColor].CGColor];
    b3.tintColor = [UIColor blackColor];
    self.button3 = b3;
    [self.handoutView addSubview:b3];
    
    UILabel  *label3a = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight/3)];
    self.title_lab3 = label3a;
    label3a.textColor=[UIColor whiteColor];
    label3a.adjustsFontSizeToFitWidth=YES;
    label3a.textAlignment = NSTextAlignmentCenter;
    label3a.text = @"";
    [self.handoutView addSubview:label3a];
    [label3a setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    
    UILabel  *label3b = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight/3*2)];
    self.due_lab3 = label3b;
    label3b.textColor=[UIColor whiteColor];
    label3b.textAlignment = NSTextAlignmentCenter;
    label3b.text = @"Due 8/15/15";
    [self.handoutView addSubview:label3b];
    [label3b setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    
    UIImageView *imageView3 = [[UIImageView alloc] init];
    imageView3.contentMode = UIViewContentModeScaleAspectFit;
    imageView3.frame = CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight);
    self.back_image3 = imageView3;
    [self.handoutView addSubview:imageView3];
    
    //Now we need to set everything to hidden
    self.button1.hidden=YES;
    self.button2.hidden=YES;
    self.button3.hidden=YES;
    self.title_lab1.hidden=YES;
    self.title_lab2.hidden=YES;
    self.title_lab3.hidden=YES;
    self.due_lab1.hidden=YES;
    self.due_lab2.hidden=YES;
    self.due_lab3.hidden=YES;
    
}


//This method takes the driveFile info and updates the buttons with them
-(void)updateButtons {
    //This is declared twice, so we can clean up the code
    
    if ([self.driveFiles count]>0){
        GTLDriveFile* testFile = [self.driveFiles objectAtIndex:0];
        NSString* thumbnail = testFile.thumbnailLink;
        NSURL *url = [NSURL URLWithString: thumbnail];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        self.back_image1.image = image;
        [self.button1 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        //HOLD LINE
        self.button1.tag=0;
        self.title_lab1.text = testFile.title;
        //THIS NEEDS TO BE FIXED EVENTUALLY
        self.due_lab1.text = @"Due 7/11/2015";
        self.button1.hidden=NO;
        self.title_lab1.hidden=NO;
        self.due_lab1.hidden=NO;
        self.back_image1.hidden=NO;
        [self.handoutView addSubview:self.button1];
        [self.handoutView addSubview:self.title_lab1];
        [self.handoutView addSubview:self.due_lab1];
    }
    
    if ([self.driveFiles count]>1){
        GTLDriveFile* testFile2 = [self.driveFiles objectAtIndex:1];
        NSString* thumbnail2 = testFile2.thumbnailLink;
        NSURL *url2 = [NSURL URLWithString: thumbnail2];
        NSData *data2 = [NSData dataWithContentsOfURL:url2];
        UIImage *image2 = [UIImage imageWithData:data2];
        [self.button2 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        self.button2.tag=1;
        self.back_image2.image = image2;
        NSString* t2 = testFile2.title;
        self.title_lab2.text = t2;
        //This needs to be fixed
        self.due_lab2.text = @"Due 8/13/2015";
        self.button2.hidden=NO;
        self.title_lab2.hidden=NO;
        self.due_lab2.hidden=NO;
        self.back_image2.hidden=NO;
        [self.handoutView addSubview:self.button2];
        [self.handoutView addSubview:self.title_lab2];
        [self.handoutView addSubview:self.due_lab2];
        //[self.handoutView addSubview:self.button2];
    }
    
    if ([self.driveFiles count]>2){
        GTLDriveFile* testFile3 = [self.driveFiles objectAtIndex:2];
        NSString* thumbnail3 = testFile3.thumbnailLink;
        NSURL *url3 = [NSURL URLWithString: thumbnail3];
        NSData *data3 = [NSData dataWithContentsOfURL:url3];
        UIImage *image3 = [UIImage imageWithData:data3];
        [self.button3 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        self.button3.tag=2;
        self.back_image3.image = image3;
        NSString* t3 = testFile3.title;
        [self.handoutView addSubview:self.button3];
        self.title_lab3.text = t3;
        //This needs to be fixed
        self.due_lab3.text = @"Due 8/13/2015";
        self.button3.hidden=NO;
        self.title_lab3.hidden=NO;
        self.due_lab3.hidden=NO;
        self.back_image3.hidden=NO;
        [self.handoutView addSubview:self.button3];
        [self.handoutView addSubview:self.title_lab3];
        [self.handoutView addSubview:self.due_lab3];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //we need to switch statement based on the identifier of the thing
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"HandoutToSave"]){
        SaveLocationViewController *viewController = [segue destinationViewController];
        viewController.withHandout = self.withHandout;
        if(self.withHandout){
            viewController.driveFile = [self.driveFiles objectAtIndex:0];
        }
        else{
            viewController.driveFile = [GTLDriveFile object];
        }
        
        viewController.driveService = self.driveService;
        viewController.userData = self.userData;
    }
}

@end
