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
    const NSString *rU = rootURL;
    NSString *handoutURL = [rU stringByAppendingString:@"/class/handouts"];
    NSString* json = [self getDataFrom:handoutURL];
    //JSON LOGS
    //NSLog(@"%@",json);
    [self loadDriveFiles];
    //[self drawHandouts:@[]];
    // Do any additional setup after loading the view.
    //self.ourDrive = [ClassViewController getDrive];
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
    //REMOVE ALL OF THE WARNINGS!
    NSString *t1;
    NSString *t2;
    NSString *t3;
    int size = [self.driveFiles count];
    /*
    if (size >= 3){
        t1 = ((NSString*) ((GTLDriveFile *)[self.driveFiles objectAtIndex:0]).thumbnail);
        t2 = ((GTLDriveFile *)[self.driveFiles objectAtIndex:1]).thumbnail;
        t3 = ((GTLDriveFile *)[self.driveFiles objectAtIndex:2]).thumbnail;
    }
    else if (size==2){
        t1 = ((GTLDriveFile *)[self.driveFiles objectAtIndex:0]).thumbnail;
        t2 = ((GTLDriveFile *)[self.driveFiles objectAtIndex:1]).thumbnail;
    }
    else if (size==1){
        t1 = ((GTLDriveFile *)[self.driveFiles objectAtIndex:0]).thumbnail;
    }
    else{
        // where we have 0 pictures
    }
     
     */
    
    //TESTING CODE NOW
    //We need to create NSData out of the NSStrings we have just created
    //We don't do null checks because Objective C won't throw a null pointer exception
    //NSLog(@"LOC 1: DRIVE FILES ARE %@",self.driveFiles);
    GTLDriveFile* testFile = [self.driveFiles objectAtIndex:2];
    NSLog(@"the file is %@",testFile);
    GTLDriveFileThumbnail* thumbnail = testFile.thumbnailLink;
    //APPARENTLY THUMBNAIL IS NOT AVAILABLE, so
    /*
     
     We need to insert the below code
     
    NSURL *url = [NSURL URLWithString:@"http://img.abc.com/noPhoto4530.gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
     */
    NSURL *url = [NSURL URLWithString: thumbnail];
    NSLog(@"the thumbnail %@",thumbnail);
    //t1 = thumbnail.image;
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

    /*
    NSData *d1 = [[NSData alloc]initWithBase64EncodedString:t1 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage* h1 = [UIImage imageWithData:d1];
    */
    CGFloat height = [self.handoutView bounds].size.height;
    CGFloat width = [self.handoutView bounds].size.width;
    CGFloat cellHeight = height/7;
    CGFloat cellWidth = width*0.8;

    
    //Add a UIButton
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(aMethod)
     forControlEvents:UIControlEventTouchUpInside];
    //[button setTitle:@"Show View" forState:UIControlStateNormal];
    button.frame = CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight);
    button.backgroundColor = [UIColor grayColor];
    //[button setBackgroundImage:image forState:UIControlStateNormal];
    [button setAlpha:0.66];
    [[button layer] setBorderWidth:2.0f];
    [[button layer] setBorderColor:[UIColor blackColor].CGColor];
    /*
    button.layer.shadowColor = [UIColor grayColor].CGColor;
    button.layer.shadowOpacity = 0.99;
    button.layer.shadowRadius = 20;
    button.layer.shadowOffset = CGSizeMake(50.0f,50.0f);
     */
    button.tintColor = [UIColor blackColor];
    imageView.frame = CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight);
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
    
    /*
    UILabel  *label1c = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, cellHeight*3, cellWidth, cellHeight/3)];
    label1c.textColor=[UIColor whiteColor];
    label1c.textAlignment = NSTextAlignmentCenter;
    label1c.text = @"Multiplication Worksheet";
    [self.handoutView addSubview:label1c];
    */
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 addTarget:self
               action:@selector(aMethod)
     forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"Show View" forState:UIControlStateNormal];
    button2.frame = CGRectMake(width*.1, cellHeight, cellWidth, cellHeight);
    button2.backgroundColor = [UIColor greenColor];
    /*
    [button2 setBackgroundImage:[UIImage imageNamed:@"SignIn"]
                       forState:UIControlStateNormal];
     */
    [self.handoutView addSubview:button2];
    
    
    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b3 addTarget:self
                action:@selector(aMethod)
      forControlEvents:UIControlEventTouchUpInside];
    [b3 setTitle:@"Show View" forState:UIControlStateNormal];
    b3.frame = CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight);
    /*[b3 setBackgroundImage:[UIImage imageNamed:@"SignIn"]
                       forState:UIControlStateNormal];
     */
    b3.backgroundColor = [UIColor redColor];
    [self.handoutView addSubview:b3];
    
    
    
    
    
    /*
    UIImage *image = [UIImage imageNamed:@"SignIn"];;
    //UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, width, cellHeight*2)];
    //iv.contentMode = UIViewContentModeScaleToFill;
    UIImageView *iv2 = [[UIImageView alloc] initWithFrame:CGRectMake(width*.1, cellHeight,cellWidth, cellHeight*2)];
    UIImageView *iv3 = [[UIImageView alloc] initWithFrame:CGRectMake(width*.1, cellHeight*5, cellWidth, cellHeight*2)];
    //[iv setImage:image];
    [iv2 setImage:image];
    [iv3 setImage:image];
    //[self.handoutView addSubview:iv];
    [self.handoutView addSubview:iv2];
    [self.handoutView addSubview:iv3];
    */
    //SAVEPOINT: FIGURE OUT THE MATH TO SAVE AN IMAGE TO A PARTICULAR LOCATION
    
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
        //NSString *className = NSStringFromClass([[segue destinationViewController] class]);
        //NSLog(@"Answer to this is: %@",className);
        viewController.driveService = self.driveService;
    }
}



- (void)loadDriveFiles {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    //query.q = @"mimeType = 'text/plain'";
    //query.q = @"";
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
            //TESTING: Checking to see if we have the right objects
            GTLDriveFile *file = [self.driveFiles objectAtIndex:0];
            NSLog(@"The first file is, %@",file.title);
            //Link to the File's Thumbnail
            NSLog(@"The thumbnail is %@",file.thumbnailLink);
            //[self getThumbnails:self.driveFiles];
            [self drawHandouts:@[]];
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
@end
