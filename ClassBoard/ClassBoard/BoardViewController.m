//
//  BoardViewController.m
//  Board
//
//  Created by Akhil Nambiar on 4/3/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "BoardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DrEditUtilities.h"
#import "TestControllerViewController.h"
#import "SplashPageViewController.h"

@interface BoardViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *BottomBoardLayer;
@property (weak, nonatomic) IBOutlet UIImageView *TopBoardLayer;
@property CGPoint lastPoint;
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;
@property CGFloat brush;
@property CGFloat opacity;
@property BOOL mouseSwiped;
@property BOOL toggleShowing;
@property BOOL animationDone;
@property (nonatomic, readwrite) SRWebSocket *warbleSocket;
@property (nonatomic, readwrite) BOOL socketReady;
@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
@property NSData* localdata;
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet SmoothedBIView *smooth;
@property (weak, nonatomic) IBOutlet UIImageView *handoutImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *hideBar;
@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdButton;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

//These properties are for the testboard
@property UIImage* handoutImage;





- (IBAction)saveFile:(id)sender;


/*
@property (weak, nonatomic) IBOutlet UIView *toolBar;
*/
@end

/*
 NOTE: Saving as a PDF will require a backend call/processing most likely
 
 NOTE: we will need to make sure the file is only saved when it is changed. We will introduce a variable for that
 NOTE: LoadFileContent could be made into utilities
 NOTE: We need to make the UIImageView Scrollable
 NOTE: Deprecate the initDrivemethod
 NOTE: While trying to save an image, we should check to see if a change has been made. We can create a boolean to do that
 NOTE: We need to add pinch to zoom
 SOLUTION: we need to change this to a UI Scroll View
 https://developer.apple.com/library/ios/documentation/windowsviews/conceptual/UIScrollView_pg/ZoomZoom/ZoomZoom.html
 
 
 Note: We need to make the toolbar disappear when we take a snapshot and save
 

 */



@implementation BoardViewController

NSString *scopes = @"https://www.googleapis.com/auth/drive.file";
NSString *keychainItemName = @"My App";
NSString *clientId = @"919063903792-k7t7k2tlvsr2g99g10v27a0t9oa2u559.apps.googleusercontent.com";
NSString *clientSecret = @"919063903792-k7t7k2tlvsr2g99g10v27a0t9oa2u559@developer.gserviceaccount.com";

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    self.animationDone = YES;
    self.toggleShowing = YES;
    self.socketReady = NO;
    self.warbleSocket = [[SRWebSocket alloc] initWithURL:[[NSURL alloc] initWithString:@"http://glacial-castle-5433.herokuapp.com"]];
    self.warbleSocket.delegate = self;
    [self.warbleSocket open];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.warbleSocket close];
    self.warbleSocket = nil;
}

- (void)viewDidLoad
{
    //SmoothedBIView *smooth = [[SmoothedBIView alloc] init];
    
    //This method is used to decojuple from the whiteboard only stuff
    self.smooth.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    [self.containerView sendSubviewToBack:self.handoutImageView];
    [self.containerView bringSubviewToFront:self.toolBar];
    if(self.withHandout){
        [self loadFileContent];
    }
    [self.firstButton.titleLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    [self.secondButton.titleLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    [self.thirdButton.titleLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    [self.saveButton.titleLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:20]];
    [self.testButton.titleLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:16]];
    //The following block is mainly for testing purposes. It checks to see if the websocket is working
    /*
    if(self.smooth2){
        NSLog(@"yea");
        NSLog(@"the image %@",self.handoutImage);
        [self.handoutImageView2 setImage:self.handoutImage];
        NSString *url = @"http://glacial-castle-5433.herokuapp.com/paint";
        //This will make a get request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:url]];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;
        
        NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        NSString* response;
        if([responseCode statusCode] != 200){
            NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
            response = @"no hay response";
        }
     
        response = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
        NSLog(@"response is %@",response);
        [self.smooth2 updateLabel:oResponseData];
    }
    */
    //end of testing code block
    
    
    self.navigationController.toolbarHidden = NO; 
    self.red = 0.0/255.0;
    self.green = 0.0/255.0;
    self.blue = 0.0/255.0;
    self.brush = 2.0;
    self.opacity = 1.0;
    self.smooth.delegate =  self;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark SocketRocket
// SRWebSocket handlers
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    /*
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self selector:@selector(timerFireMethod:) userInfo:message repeats:NO];
     */
    [self.smooth updateLabel:message];
}

- (void)timerFireMethod:(NSTimer *)timer
{
    NSLog(@"timer has been fired");
    [self.smooth updateLabel:(NSData*) timer.userInfo];
}

- (void)recivedTouch:(UITouch *)touch fromUIView:(UIView *)uiView andData:(NSData *)incrImage
{
    if (self.socketReady) {
        self.localdata = incrImage;
        [self.warbleSocket send:incrImage];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    self.socketReady = YES;
    self.connectStatus.text = @"Connected";
    self.connectStatus.textColor = [UIColor greenColor];
    NSLog(@"Successfully Connected to Websocket");
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    //[_webSocket closeWithCode:1000 reason:nil];
    self.socketReady = NO;
    self.connectStatus.text = @"Disconnected";
    self.connectStatus.textColor = [UIColor redColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded: touches withEvent: event];
}

- (IBAction)toggleTool:(id)sender {
    if(self.toggleShowing){
        if([self.hideBar.title isEqualToString:@"Hide"]){
            self.hideBar.title=@"Show";
        }
        else{
            self.hideBar.title=@"Hide";
        }
        CGRect newFrame = self.toolBar.frame;
        newFrame.origin.x += -100;    // shift right by 500pts
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.toolBar.frame = newFrame;
                         }];
        self.toggleShowing = NO;
    }
    else{
        CGRect newFrame = self.toolBar.frame;
        newFrame.origin.x += 100;    // shift right by 500pts
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.toolBar.frame = newFrame;
                         }];
        self.toggleShowing = YES;
    }
}

- (void) hideLabel
{
    [self.toolBar setHidden:YES];  //This assumes that your label is a property of your view controller
}


// Ad hoc fix for the Node.js connection issue
/*
- (void)disconnect
{
    dispatch_async(_workQueue, ^{
        [self _disconnect];
    });
}
 */


- (IBAction)saveFile:(id)sender {
    /*
     Logic:
     
     1) convert UIView into a PDF
     2) Save to google drive
     */
    
    //First we will convert it to NSData
    [self.toolBar setValue:@YES forKeyPath:@"hidden"];
    NSData* boardPNG = [self pngSnapshot];
    [self.toolBar setValue:@NO forKeyPath:@"hidden"];
    GTLUploadParameters *uploadParameters = nil;
    // Only update the file content if different.
    uploadParameters = [GTLUploadParameters uploadParametersWithData:boardPNG MIMEType:@"image/png"];
    self.driveFile.title = self.fileTitle;
    self.driveFile.identifier = nil;
    //Design Decision
    
    GTLQueryDrive *query = nil;
    if (self.driveFile.identifier == nil || self.driveFile.identifier.length == 0) {
        NSLog(@"we have identified that this is new");
        // This is a new file, instantiate an insert query.
        query = [GTLQueryDrive queryForFilesInsertWithObject:self.driveFile
                                            uploadParameters:uploadParameters];
    } else {
        // This file already exists, instantiate an update query.
        query = [GTLQueryDrive queryForFilesUpdateWithObject:self.driveFile
                                                      fileId:self.driveFile.identifier
                                            uploadParameters:uploadParameters];
    }
    UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Saving file"
                                                             delegate:self];
    
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFile *updatedFile,
                                                              NSError *error) {
        NSLog(@"Completion Handler is called");
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil) {
            //This will take them back to the home screen
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Saved" message:@"Would you like to return to the home screen?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            [alert show];
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to save file"
                                               message:[error description]
                                              delegate:self];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && [alertView.title isEqualToString:@"File Saved"]){
        [self performSegueWithIdentifier:@"backToHome" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"backToHome"]){
        SplashPageViewController *viewController = [segue destinationViewController];
        viewController.driveService = self.driveService;
        viewController.userData = self.userData;
    }
    else if ([segue.identifier isEqualToString:@"WebsocketTestSegue"]){
        TestControllerViewController *viewController = [segue destinationViewController];
        viewController.handoutImage = self.handoutImage;
    }

}

-(NSData *) pngSnapshot{
    UIGraphicsBeginImageContextWithOptions(self.containerView.bounds.size, self.containerView.opaque, 0.0);
    [self.containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImagePNGRepresentation(img);
}

- (void)loadFileContent {
    UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading file content"
                                                             delegate:self];
    GTMHTTPFetcher *fetcher =
    [self.driveService.fetcherService fetcherWithURLString:self.driveFile.downloadUrl];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil) {
            UIImage *image = [UIImage imageWithData:data];
            [self.handoutImageView setImage:image];
            self.handoutImage = image;
            NSLog(@"at first the image is: %@",self.handoutImage);
        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load file"
                                               message:[error description]
                                              delegate:self];
        }
    }];
}

- (IBAction)viewClassmate:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"This feature is only used for testing to ensure that the websocket works. The link is to a webpage that has the image of the board."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self performSegueWithIdentifier:@"WebsocketTestSegue" sender:self];
}

@end
