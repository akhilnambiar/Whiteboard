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
    NSString *handoutURL = [rU stringByAppendingString:@"/class/handouts"];
    NSString* json = [self getDataFrom:handoutURL];
    [self loadDriveFiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) getDataFrom:(NSString *)url{
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
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

-(void) drawHandouts:(NSMutableArray*) handouts{
    GTLDriveFile* testFile = [self.driveFiles objectAtIndex:2];
    NSString* thumbnail = testFile.thumbnailLink;
    NSURL *url = [NSURL URLWithString: thumbnail];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

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
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.handoutView addSubview:imageView];
    [self.handoutView addSubview:button];
    
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
    [button2 addTarget:self
               action:@selector(aMethod)
     forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"Show View" forState:UIControlStateNormal];
    button2.frame = CGRectMake(width*.1, cellHeight, cellWidth, cellHeight);
    button2.backgroundColor = [UIColor greenColor];
    [self.handoutView addSubview:button2];
    
    
    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b3 addTarget:self
                action:@selector(aMethod)
      forControlEvents:UIControlEventTouchUpInside];
    [b3 setTitle:@"Show View" forState:UIControlStateNormal];
    b3.frame = CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight);
    b3.backgroundColor = [UIColor redColor];
    [self.handoutView addSubview:b3];
    
}

-(void) aMethod{
    NSLog(@"poopie face tomatoe nose");
    
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
    BOOL notNull = self.driveService==NULL;
    NSLog(@"Is this eual to %@",self.driveService);
    UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading files"
                                                             delegate:self];
    
    NSLog(@"Is this eual to %hhd",notNull);
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
            //We will eventually send a file to the drawhandouts callback
            GTLDriveFile *file = [self.driveFiles objectAtIndex:0];
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

-(void) clickButton{
    self.withHandout = YES;
    [self loadHandoutFiles];
}

-(void)loadHandoutFiles {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    //query.q = @"mimeType = 'text/plain'";
    NSString *search = @"title = 'englishworksheet.png'";
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
        [self performSegueWithIdentifier:@"HandoutToSave" sender:self];
    }];
}

@end
