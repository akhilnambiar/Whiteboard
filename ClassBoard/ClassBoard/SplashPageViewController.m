//
//  SplashPageViewController.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/26/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "SplashPageViewController.h"
#import "HandoutViewController.h"
#import "GTMOAuth2Authentication.h"
#import "ClassGroupsViewController.h"

@interface SplashPageViewController ()
@property (weak, nonatomic) IBOutlet UIButton *SingleBoard;
@property (weak, nonatomic) IBOutlet UIButton *ViewDocs;
@property (weak, nonatomic) IBOutlet UIButton *Invites;
@property (weak, nonatomic) IBOutlet UIButton *GroupBoard;


@end

static NSString *const kKeychainItemName = @"iOSDriveSample: Google Drive";
NSString *rootURL=@"http://radiant-dusk-5060.herokuapp.com/";

@implementation SplashPageViewController

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
    /*
     Method to find all the names of the different fonts
     
    NSArray *fontNames = [UIFont familyNames];
    for (NSString *familyName in fontNames) {
        NSLog(@"Font family name = %@", familyName);
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        NSLog(@"Font names = %@", names);
    }
     */
    [self.SingleBoard.titleLabel setFont:[UIFont fontWithName:@"nevis-Bold" size:40]];
    [self.GroupBoard.titleLabel setFont:[UIFont fontWithName:@"nevis-Bold" size:40]];
    [self.ViewDocs.titleLabel setFont:[UIFont fontWithName:@"nevis-Bold" size:40]];
    [self.Invites.titleLabel setFont:[UIFont fontWithName:@"nevis-Bold" size:40]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
        if ([segue.identifier isEqualToString:@"splashToHandout"]){
            HandoutViewController *viewController = [segue destinationViewController];
            viewController.driveService = self.driveService;
        }
        else if([segue.identifier isEqualToString:@"splashToGroup"]){
            ClassGroupsViewController *viewController = [segue destinationViewController];
            viewController.driveService = self.driveService;
        }
}


@end
