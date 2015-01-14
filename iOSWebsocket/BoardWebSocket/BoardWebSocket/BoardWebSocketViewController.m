//
//  BoardWebSocketViewController.m
//  BoardWebSocket
//
//  Created by Akhil Nambiar on 4/4/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "BoardWebSocketViewController.h"

@interface BoardWebSocketViewController ()

@property (weak, nonatomic) IBOutlet UITextField *input;
@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
@property (weak, nonatomic) IBOutlet UITextView *serverMessage;

@property (nonatomic, readwrite) SRWebSocket *warbleSocket;
@property (nonatomic, readwrite) BOOL socketReady;

@end

@implementation BoardWebSocketViewController

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
    NSLog(@"this is loaded");
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)textFieldDidChange:(id)sender {
    NSLog(@"called");
    NSLog(@"the socket is ready %hhd", self.socketReady);
    if (self.socketReady) {
        [self.warbleSocket send:self.input.text];
    }
}

/*
- (IBAction)textFieldDidChange2:(id)sender {
    NSLog(@"called");
    NSLog([NSString stringWithFormat:@"%@,%hhd", @"is the socket ready", self.socketReady]);
    if (self.socketReady) {
        [self.warbleSocket send:self.input.text];
    }
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// SRWebSocket handlers
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    self.serverMessage.text = (NSString *)message;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    self.socketReady = YES;
    self.connectStatus.text = @"Connected";
    self.connectStatus.textColor = [UIColor greenColor];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    self.socketReady = NO;
    self.connectStatus.text = @"Disconnected";
    self.connectStatus.textColor = [UIColor redColor];
}

@end
