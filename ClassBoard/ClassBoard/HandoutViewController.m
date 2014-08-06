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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.withHandout = NO;
    const NSString *rU = rootURL;
    NSError *error = [[NSError alloc] init];
    NSString *handoutURL = [rU stringByAppendingString:@"get_handout/"];
    [self getDataFrom:handoutURL withKeys:@[@"teacher",@"period"] withValues:@[[self.userData objectForKey:@"teacher"],[self.userData objectForKey:@"period"]] ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self groupsFromJSON:oResponseData forKeys:@[@"file_name",@"errcode"] error:&error];
    return oResponseData;
}

-(void) drawHandouts:(NSMutableArray*) handouts{
    GTLDriveFile* testFile = [self.driveFiles objectAtIndex:0];
    NSString* t1 = testFile.title;
    NSString* t2 = nil;
    NSString* t3 = nil;
    NSString* thumbnail = testFile.thumbnailLink;
    NSURL *url = [NSURL URLWithString: thumbnail];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIImageView *imageView2 = nil;
    UIImageView *imageView3 = nil;
    
    if ([self.driveFiles count]>1){
        GTLDriveFile* testFile2 = [self.driveFiles objectAtIndex:1];
        NSString* thumbnail2 = testFile2.thumbnailLink;
        NSURL *url2 = [NSURL URLWithString: thumbnail2];
        NSData *data2 = [NSData dataWithContentsOfURL:url2];
        UIImage *image2 = [UIImage imageWithData:data2];
        imageView2 = [[UIImageView alloc] initWithImage:image2];
        t2 = testFile2.title;
    }
    
    if ([self.driveFiles count]>2){
        GTLDriveFile* testFile3 = [self.driveFiles objectAtIndex:2];
        NSString* thumbnail3 = testFile3.thumbnailLink;
        NSURL *url3 = [NSURL URLWithString: thumbnail3];
        NSData *data3 = [NSData dataWithContentsOfURL:url3];
        UIImage *image3 = [UIImage imageWithData:data3];
        imageView3 = [[UIImageView alloc] initWithImage:image3];
        t3 = testFile3.title;
    }

    CGFloat height = [self.handoutView bounds].size.height;
    CGFloat width = [self.handoutView bounds].size.width;
    CGFloat cellHeight = height/7;
    CGFloat cellWidth = width*0.8;

    
    //Add a UIButton
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(aMethod)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight);
    button.backgroundColor = [UIColor grayColor];
    [button setAlpha:0.66];
    [[button layer] setBorderWidth:2.0f];
    [[button layer] setBorderColor:[UIColor blackColor].CGColor];
    button.tintColor = [UIColor blackColor];
    imageView.frame = CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight);
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.handoutView addSubview:imageView];
    [self.handoutView addSubview:button];
    button.tag=0;
    
    UILabel  *label1a = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight/3)];
    label1a.textColor=[UIColor whiteColor];
    label1a.adjustsFontSizeToFitWidth=YES;
    label1a.textAlignment = NSTextAlignmentCenter;
    label1a.text = @"Multiplication Worksheet";
    [self.handoutView addSubview:label1a];
    
    UILabel  *label1b = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight/3*2)];
    label1b.textColor=[UIColor whiteColor];
    label1b.textAlignment = NSTextAlignmentCenter;
    label1b.text = @"Due 7/11/1992";
    [self.handoutView addSubview:label1b];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setTitle:@"Show View" forState:UIControlStateNormal];
    button2.frame = CGRectMake(width*.1, cellHeight, cellWidth, cellHeight);
    button2.backgroundColor = [UIColor greenColor];
    [self.handoutView addSubview:button2];
    if (imageView2!=nil){
        imageView2.frame = CGRectMake(width*.1, cellHeight, cellWidth, cellHeight);
        [self.handoutView addSubview:imageView2];
        [button2 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button2.tag=1;
    }
    
    
    
    
    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b3 setTitle:@"Show View" forState:UIControlStateNormal];
    b3.frame = CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight);
    b3.backgroundColor = [UIColor redColor];
    [self.handoutView addSubview:b3];
    if (imageView3!=nil){
        imageView3.frame = CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight);
        [self.handoutView addSubview:imageView3];
        [b3 addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        b3.tag=1;
    }
    
    
}

-(void) aMethod{
    
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
    }
}



- (void)loadDriveFiles {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    //query.q = @"mimeType = 'text/plain'";
    //query.q = @"";
    //FOR HANDOUTS WE WILL ADD A SPECIFIC QUERY LATER
    
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
    //query.q = @"title = 'englishworksheet.png' or title = 'mathworksheet.jpg'";
    BOOL notNull = self.driveService==NULL;
    UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading files"
                                                             delegate:self];
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFileList *files,
                                                              NSError *error) {
        NSLog(@"I end the query");
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil) {
            if (self.driveFiles == nil) {
                self.driveFiles = [[NSMutableArray alloc] init];
            }
            [self.driveFiles removeAllObjects];
            [self.driveFiles addObjectsFromArray:files.items];
            [self drawHandouts:(NSMutableArray *)@[]];
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load files"
                                               message:[error description]
                                              delegate:self];
        }
    }];
}
/*
 LOGIC:go through and get the thumbnails
 
 */
-(void) getThumbnails:(NSMutableArray *)picArray {
    //Since we're in objective C, we don't have to do null checks, we can just check to see what we have and go from
    NSMutableArray* contents = @[];
    [contents addObjectsFromArray:picArray];
    for (GTLDriveFile* file in picArray){
        [contents addObject:file.thumbnail];
    }
    [self drawHandouts:contents];
}

-(void) clickButton:(id) sender{
    self.withHandout = YES;
    UIButton *clicked = (UIButton* ) sender;
    NSString *fileTitle = ((GTLDriveFile *)[self.driveFiles objectAtIndex:clicked.tag]).title;
    [self loadHandoutFiles:fileTitle];
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
    [self loadDriveFiles];
    
}

@end
