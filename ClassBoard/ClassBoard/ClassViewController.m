//
//  ClassViewController.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/26/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "ClassViewController.h"

#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "SplashPageViewController.h"
#import "DrEditUtilities.h"

@interface ClassViewController ()
@property (weak, nonatomic) IBOutlet UIButton *signup;
@property BOOL isAuthorized;
@property (weak, readonly) GTLServiceDrive *driveService;
@property NSDictionary* jsonResp;
@property NSString* userId;
@property UIAlertView* loginAlert;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation ClassViewController


static NSString *const kKeychainItemName = @"iOSDriveSample: Google Drive";
static NSString *const kClientId = @"919063903792-mq1o9pmi47qdbe2ar1rv72fhohta9unf.apps.googleusercontent.com";
static NSString *const kClientSecret = @"_4RSLRU9KjLFjZZiVXgEpFT5";
NSString *rootURL=@"http://shrouded-ocean-4177.herokuapp.com/";

-(void)viewWillAppear:(BOOL)animated{
    [self.titleLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:80]];
    self.navigationController.navigationBar.hidden=YES;
    self.signup.layer.cornerRadius = 10;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    GTMOAuth2Authentication *auth =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientId
                                                      clientSecret:kClientSecret];
    if ([auth canAuthorize]) {
        [self isAuthorizedWithAuthentication:auth];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signin:(id)sender {
    if (!self.isAuthorized) {
        // Sign in.
        SEL finishedSelector = @selector(viewController:finishedWithAuth:error:);
        GTMOAuth2ViewControllerTouch *authViewController =
        [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                   clientID:kClientId
                                               clientSecret:kClientSecret
                                           keychainItemName:kKeychainItemName
                                                   delegate:self
                                           finishedSelector:finishedSelector];
        [self presentViewController:authViewController
                                animated:YES completion:nil];
    } else {
        [self getUserInfo:self.driveService];
        self.loginAlert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading Classboard"
                                                              delegate:self];
    }
    
}

-(void)showAlert{
    NSLog(@"I reach here");
    self.loginAlert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading Classboard"
                                                          delegate:self];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self getUserInfo:self.driveService];
    if (error == nil) {
        //After they log in, we introduce the alert
        self.loginAlert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading Classboard"
                                                              delegate:self];
        [self isAuthorizedWithAuthentication:auth];
    }
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [[self driveService] setAuthorizer:auth];
    self.isAuthorized = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"postSignon"]){
        SplashPageViewController *vc = [segue destinationViewController];
        vc.driveService = self.driveService;
        vc.userData = self.jsonResp;
        vc.userId = self.userId;
        
    }
}

- (GTLServiceDrive *)driveService {
    static GTLServiceDrive *service = nil;
    
    if (!service) {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}

/*
 *This method will check to see if they look at the local username
 *
 */
-(void)classAuthCheck {
    NSError *error = [[NSError alloc] init];
    NSString *newURL = [NSString stringWithFormat:@"%@%@", rootURL, @"login/"];
    NSData *resp = [self getDataFrom:newURL withKeys:@[@"username"] withValues:@[[NSString stringWithFormat:@"%@",self.userId]]];
    //Need to do something if the username has been taken
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
    [self groupsFromJSON:oResponseData forKeys:@[@"errcode",@"user_id",@"invites",@"teacher",@"period"] error:&error];
    return oResponseData;
    //return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
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
    [self errorCheck];
}

-(void)errorCheck{
    NSString *val =[[self.jsonResp objectForKey:@"errcode"] stringValue];
    if ([val isEqual:@"1"]){
        [self performSegueWithIdentifier: @"postSignon" sender: self];
        [self.loginAlert dismissWithClickedButtonIndex:0 animated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.loginAlert dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom Accounts Unavailable" message:@"Please use the Beta Account Provided" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)getUserInfo:(GTLServiceDrive *)service {
    GTLQueryDrive *query = [GTLQueryDrive queryForAboutGet];
    // queryTicket can be used to track the status of the request.
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, GTLDriveAbout *about,
                            NSError *error) {
            if (error == nil) {
                NSLog(@"Current user name: %@", about.name);
                NSLog(@"Root folder ID: %@", about.rootFolderId);
                NSLog(@"Permission ID: %@", about.permissionId);
                NSLog(@"The User: %@", about.user.displayName);
                self.userId = about.permissionId;
                [self classAuthCheck];
                
            } else {
                NSLog(@"An error occurred: %@", error);
            }
        }];
}
@end
