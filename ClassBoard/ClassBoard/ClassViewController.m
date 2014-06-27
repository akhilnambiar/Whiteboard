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

@interface ClassViewController ()
@property BOOL isAuthorized;
@property (weak, readonly) GTLServiceDrive *driveService;
@end

@implementation ClassViewController


static NSString *const kKeychainItemName = @"iOSDriveSample: Google Drive";
static NSString *const kClientId = @"919063903792-mq1o9pmi47qdbe2ar1rv72fhohta9unf.apps.googleusercontent.com";
static NSString *const kClientSecret = @"_4RSLRU9KjLFjZZiVXgEpFT5";

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
    NSLog(@"I'm pressing sign in");
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
        [self performSegueWithIdentifier: @"postSignon" sender: self];
        // keychain remembered
        //for testing, we will assume that this is a sign out button
        //[GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        //[[self driveService] setAuthorizer:nil];
        //self.authButton.title = @"Sign in";
        //self.isAuthorized = NO;
        //[self toggleActionButtons:NO];
    }
    
}


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier: @"postSignon" sender: self];
    if (error == nil) {
        [self isAuthorizedWithAuthentication:auth];
    }
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [[self driveService] setAuthorizer:auth];
    //self.authButton.title = @"Sign out";
    self.isAuthorized = YES;
    //[self toggleActionButtons:YES];
    //[self loadDriveFiles];
}

@end
