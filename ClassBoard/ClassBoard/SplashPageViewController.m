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
#import "InvitesViewController.h"
#import "DrEditUtilities.h"

@interface SplashPageViewController ()
@property (weak, nonatomic) IBOutlet UIButton *SingleBoard;
@property (weak, nonatomic) IBOutlet UIButton *ViewDocs;
@property (weak, nonatomic) IBOutlet UIButton *Invites;
@property (weak, nonatomic) IBOutlet UIButton *GroupBoard;
@property NSDictionary* jsonResp;


@end

static NSString *const kKeychainItemName = @"iOSDriveSample: Google Drive";

@implementation SplashPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    //[self getUserInfo:self.driveService];
    //NSError *error = [[NSError alloc] init];
    //NSString *newURL = [NSString stringWithFormat:@"%@%@", rootURL, @"login/"];
    //NSData *resp = [self getDataFrom:newURL withKeys:@[@"username"] withValues:@[[NSString stringWithFormat:@"%d", 1]]];
    //[self groupsFromJSON:resp forKeys:@[@"errcode",@"user_id",@"invites"] error:&error];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
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
    // Get the new view        controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
        if ([segue.identifier isEqualToString:@"splashToHandout"]){
            HandoutViewController *viewController = [segue destinationViewController];
            viewController.driveService = self.driveService;
            viewController.userData = self.userData;
        }
        else if([segue.identifier isEqualToString:@"splashToGroup"]){
            ClassGroupsViewController *viewController = [segue destinationViewController];
            viewController.driveService = self.driveService;
            viewController.userData = self.userData;
        }
        else if([segue.identifier isEqualToString:@"splashToInvites"]){
            InvitesViewController *viewController = [segue destinationViewController];
            viewController.driveService = self.driveService;
            viewController.userData = self.userData;
            viewController.userId = self.userId;
        }
}




- (NSData *) getDataFrom:(NSString *)url withKeys:(NSArray *)keys withValues:(NSArray *)values{
    /*
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
     NSString *inter = @"";
     NSMutableArray *jsonItems = [[NSMutableArray alloc]init];
     int i = 0;
     if (keys!=nil){
     for (NSString *x in keys){
     inter = [NSString stringWithFormat:@"%@=[%@]",x,[values objectAtIndex:i]];
     [jsonItems insertObject:inter atIndex:i];
     }
     NSString *get = [[jsonItems valueForKey:@"description"] componentsJoinedByString:@"&"];
     NSData *getData = [get dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
     NSLog(@"The Get Data is %@",get);
     NSString *getLength = [NSString stringWithFormat:@"%d", [getData length]];
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
     [request setValue:getLength forHTTPHeaderField:@"Content-Length"];
     [request setValue:get forHTTPHeaderField:@"json"];
     [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
     [request setHTTPBody:getData];
     }
     [request setHTTPMethod:@"GET"];
     [request setURL:[NSURL URLWithString:url]];
     */
    // Trying something drastic
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"1" forKey:@"username"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!data) {
        return NO;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    NSURLResponse *urlResponse = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    NSData *response = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONWritingPrettyPrinted error:&error];
    
    
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
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
        //[self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
