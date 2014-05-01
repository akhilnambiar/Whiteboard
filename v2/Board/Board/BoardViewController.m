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
@property (nonatomic, readwrite) SRWebSocket *warbleSocket;
@property (nonatomic, readwrite) BOOL socketReady;
@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
@property (strong, nonatomic) IBOutlet SmoothedBIView *smooth;
@property (strong, nonatomic) IBOutlet SmoothedBIView *smooth2;
@property NSData* localdata;

@end




@implementation BoardViewController

NSString *scopes = @"https://www.googleapis.com/auth/drive.file";
NSString *keychainItemName = @"My App";
NSString *clientId = @"919063903792-k7t7k2tlvsr2g99g10v27a0t9oa2u559.apps.googleusercontent.com";
NSString *clientSecret = @"919063903792-k7t7k2tlvsr2g99g10v27a0t9oa2u559@developer.gserviceaccount.com";
/*
 
 IMPLEMENTATION 1
 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    self.lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.TopBoardLayer.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.TopBoardLayer.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.TopBoardLayer setAlpha:self.opacity];
    UIGraphicsEndImageContext();
    
    self.lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!self.mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.TopBoardLayer.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, self.opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.TopBoardLayer.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.BottomBoardLayer.frame.size);
    [self.BottomBoardLayer.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.TopBoardLayer.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.opacity];
    self.BottomBoardLayer.image = UIGraphicsGetImageFromCurrentImageContext();
    self.TopBoardLayer.image = nil;
    UIGraphicsEndImageContext();
}
*/

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
    //NSLog(@"waka waka");
    //[self.smooth2 updateLabel:self.localdata];
    //self.serverMessage.text = (NSString *)message;
    /*
     CODE USED FOR RENDERING
     [incrementalImage drawAtPoint:CGPointZero];
     [[UIColor blackColor] setStroke];
     [path stroke];
     incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     */
    
    /*
     NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(incrImage)];
     */
    /*
    UIImage *incrementalImage = [UIImage imageWithData:message];
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    //[path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    */
    //UIBezierPath *bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:message];
    //[self.smooth2 updateBoard:message];
    /*
    UIImage *incrementalImage = [UIImage imageWithData:message];
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    //[path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     */
    
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
