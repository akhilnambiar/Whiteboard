//
//  GoogleLoginViewController.m
//  GoogleLogin
//
//  Created by Akhil Nambiar on 5/31/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "GoogleLoginViewController.h"

@interface GoogleLoginViewController ()
@property (nonatomic, strong) NSMutableArray *arrProfileInfo;
@property (nonatomic, strong) NSMutableArray *arrProfileInfoLabel;
@property (nonatomic, strong) GoogleOAuth *googleOAuth;
@end

@implementation GoogleLoginViewController

- (IBAction)showProfile:(id)sender {
    NSLog(@"I clicked Show my profile");
    /*
    [_googleOAuth authorizeUserWithClienID:@"919063903792-mq1o9pmi47qdbe2ar1rv72fhohta9unf.apps.googleusercontent.com"
                           andClientSecret:@"_4RSLRU9KjLFjZZiVXgEpFT5"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/userinfo.profile", nil]
     ];
    */
    //New Scope for google drive
    //https://www.googleapis.com/auth/drive
    [_googleOAuth authorizeUserWithClienID:@"919063903792-mq1o9pmi47qdbe2ar1rv72fhohta9unf.apps.googleusercontent.com"
                           andClientSecret:@"_4RSLRU9KjLFjZZiVXgEpFT5"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/drive", nil]
     ];
}
- (IBAction)revokeAccess:(id)sender {
    [self.googleOAuth revokeAccessToken];
}

- (void)viewDidLoad
{
    NSLog(@"somebody, anybody");
    _googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
    [_googleOAuth setGOAuthDelegate:self];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)authorizationWasSuccessful{
    /*
    [self.googleOAuth callAPI:@"https://www.googleapis.com/oauth2/v1/userinfo"
               withHttpMethod:httpMethod_GET
           postParameterNames:nil postParameterValues:nil];
    */
    //call for google drive
    
    //https://www.googleapis.com/drive/v2/files
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
            NSLog(@"I'm about to spit out all the items in the dictionary");
            for(NSString *key in [dictionary allKeys]) {
                NSLog(@"%@",[dictionary objectForKey:key]);
            }
        }
    }
}

@end
