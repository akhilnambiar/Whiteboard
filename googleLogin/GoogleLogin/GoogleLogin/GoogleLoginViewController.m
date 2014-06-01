//
//  GoogleLoginViewController.m
//  GoogleLogin
//
//  Created by Akhil Nambiar on 5/31/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "GoogleLoginViewController.h"

@interface GoogleLoginViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *GoogleWebView;

@end

@implementation GoogleLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *fullURL = @"http://conecode.com";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.GoogleWebView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
