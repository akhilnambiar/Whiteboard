//
//  BoardViewController.m
//  Board
//
//  Created by Akhil Nambiar on 4/3/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "BoardViewController.h"

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
@property (strong, nonatomic) IBOutlet SmoothedBIView *smooth2;
@property NSData* localdata;
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (strong, nonatomic) IBOutlet SmoothedBIView *smooth;
/*
@property (weak, nonatomic) IBOutlet UIView *toolBar;
*/
@end




@implementation BoardViewController

NSString *scopes = @"https://www.googleapis.com/auth/drive.file";
NSString *keychainItemName = @"My App";
NSString *clientId = @"919063903792-k7t7k2tlvsr2g99g10v27a0t9oa2u559.apps.googleusercontent.com";
NSString *clientSecret = @"919063903792-k7t7k2tlvsr2g99g10v27a0t9oa2u559@developer.gserviceaccount.com";


- (IBAction)Save:(id)sender {
}

- (IBAction)Reset:(id)sender {
}


- (IBAction)pencilPressed:(id)sender {
}


- (IBAction)eraserPressed:(id)sender {
}

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
    
    
    
    //self.toolbar.transform = CGAffineTransformMakeRotation( ( 90 * M_PI ) / 180 );
    //self.pencilitem.transform = CGAffineTransformMakeRotation( ( 90 * M_PI ) / 180 );
    //self.toolbar.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 270.0/180*M_PI);
    if(self.smooth2){
        NSLog(@"Starting GET request t other person.");
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
    self.navigationController.toolbarHidden = NO; 
    self.red = 0.0/255.0;
    self.green = 0.0/255.0;
    self.blue = 0.0/255.0;
    self.brush = 2.0;
    self.opacity = 1.0;
    self.smooth.delegate =  self;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"this is loaded");
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


// SRWebSocket handlers
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
 
    
}

- (void)recivedTouch:(UITouch *)touch fromUIView:(UIView *)uiView andData:(NSData *)incrImage
{
    //NSLog(@"this is not called");
    /*
    if (uiView == self.someView)
    {
        // do some stuff with uiWebView
    }
     */
    //NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(incrImage)];
    //UIBezierPath *bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:incrImage];
    //NSLog(@"Kanye");
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
    NSLog(@"Touches Began");
    //http://stackoverflow.com/questions/9859496/affecting-uiviewcontroller-from-a-child-uiview
    //http://www.hardcodedstudios.com/home/ryan-newsome/simpledelegatetutorialforiosdevelopment
    //TUTORIALS FOR DELEGATES
    
    //[self logTouches: event];
    [super touchesEnded: touches withEvent: event];
}
- (IBAction)toggleTool:(id)sender {
    if(self.toggleShowing){
        CGRect newFrame = self.toolBar.frame;
        newFrame.origin.x += -100;    // shift right by 500pts
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.toolBar.frame = newFrame;
                         }];
        //[self.toolBar setHidden:YES];
        //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideLabel) userInfo:nil repeats:NO];
        self.toggleShowing = NO;
    }
    else{
        CGRect newFrame = self.toolBar.frame;
        //[self.toolBar setHidden:NO];
        newFrame.origin.x += 100;    // shift right by 500pts
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.toolBar.frame = newFrame;
                         }];
        //[self.toolBar setHidden:YES];
        //[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideLabel) userInfo:nil repeats:NO];
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


@end
