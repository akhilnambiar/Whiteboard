//
//  WebUIViewController.m
//  GoogleLogin
//
//  Created by Akhil Nambiar on 6/1/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "WebUIViewController.h"
#import "GoogleLoginViewController.h"

@interface WebUIViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *UIWebInstance;
@property (nonatomic, strong) NSMutableArray *arrProfileInfo;
@property (nonatomic, strong) NSMutableArray *arrProfileInfoLabel;
@property (nonatomic, strong) GoogleOAuth *googleOAuth;

@end

@implementation WebUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    /*
     Client ID for Google Auth:
     919063903792-mq1o9pmi47qdbe2ar1rv72fhohta9unf.apps.googleusercontent.com
     
     Ridirect URL:
     urn:ietf:wg:oauth:2.0:oob
     OR
     http://localhost
     
     Scope Parameter:
     profile
     
     
     
     
     FINAL URL:
     https://accounts.google.com/o/oauth2/auth?
     scope=profile&
     redirect_uri=urn:ietf:wg:oauth:2.0:oob&
     response_type=code&
     client_id=919063903792-k7t7k2tlvsr2g99g10v27a0t9oa2u559.apps.googleusercontent.com
     
     OR
     
     ***WORKING ONE****
     
     https://accounts.google.com/o/oauth2/auth?scope=profile&redirect_uri=http://localhost&response_type=code&client_id=919063903792-mq1o9pmi47qdbe2ar1rv72fhohta9unf.apps.googleusercontent.com
     ******************
     
     OR
     
     https://accounts.google.com/AccountChooser?service=lso&continue=https%3A%2F%2Faccounts.google.com%2Fo%2Foauth2%2Fauth%3Fresponse_type%3Dcode%26scope%3Dprofile%26redirect_uri%3Durn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob%26client_id%3D919063903792-k7t7k2tlvsr2g99g10v27a0t9oa2u559.apps.googleusercontent.com%26hl%3Den%26from_login%3D1%26as%3D648033877254e281&btmpl=authsub&hl=en
     */
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *fullURL = @"https://accounts.google.com/o/oauth2/auth?scope=profile&redirect_uri=http://localhost&response_type=code&client_id=919063903792-mq1o9pmi47qdbe2ar1rv72fhohta9unf.apps.googleusercontent.com";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.UIWebInstance loadRequest:requestObj];
    
    
    self.arrProfileInfo = [[NSMutableArray alloc] init];
    self.arrProfileInfoLabel = [[NSMutableArray alloc] init];
    
    self.googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
    [self.googleOAuth setGOAuthDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)authorizationWasSuccessful{
    [self.googleOAuth callAPI:@"https://www.googleapis.com/oauth2/v1/userinfo"
               withHttpMethod:httpMethod_GET
           postParameterNames:nil postParameterValues:nil];
}

-(void)accessTokenWasRevoked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your access was revoked!"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    if ([responseJSONAsString rangeOfString:@"family_name"].location != NSNotFound) {
        NSError *error;
        NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseJSONAsData
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:&error];
        if (error) {
            NSLog(@"An error occured while converting JSON data to dictionary.");
            return;
        }
        else{
            /*
             if (_arrProfileInfoLabel != nil) {
             _arrProfileInfoLabel = nil;
             _arrProfileInfo = nil;
             _arrProfileInfo = [[NSMutableArray alloc] init];
             }
             
             _arrProfileInfoLabel = [[NSMutableArray alloc] initWithArray:[dictionary allKeys] copyItems:YES];
             for (int i=0; i<[_arrProfileInfoLabel count]; i++) {
             [_arrProfileInfo addObject:[dictionary objectForKey:[_arrProfileInfoLabel objectAtIndex:i]]];
             }
             
             [_table reloadData];
             */
            //Figure out what to do here
            for(NSString *key in [dictionary allKeys]) {
                NSLog(@"%@",[dictionary objectForKey:key]);
            }
        }
    }
}

@end
