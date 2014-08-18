//
//  ClassGroupsViewController.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/29/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "ClassGroupsViewController.h"
#import "SplashPageViewController.h"
#import "HandoutViewController.h"
#import "DrEditUtilities.h"

@interface ClassGroupsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *classmateList;
@property (weak, nonatomic) IBOutlet UIView *recentGroups;
@property(strong, nonatomic) NSMutableArray* jsonClassmates;
@property(strong,nonatomic) NSMutableArray* selectedMates;
@property NSDictionary* jsonResp;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;


@end

@implementation ClassGroupsViewController

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
    [self.groupLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:40]];
    // Do any additional setup after loading the view.
    self.selectedMates = [[NSMutableArray alloc]init];
    const NSString *rU = rootURL;
    NSString *classListURL = [rU stringByAppendingString:@"get_classmates/"];
    NSError *error = [[NSError alloc] init];
    [self getDataFrom:classListURL withKeys:@[@"teacher",@"period"] withValues:@[[self.userData objectForKey:@"teacher"],[self.userData objectForKey:@"period"]] ];
    self.classmateList.dataSource = self;
    self.classmateList.delegate = self;
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
    if ([segue.identifier isEqualToString:@"groupsToHandout"]){
        HandoutViewController *viewController = [segue destinationViewController];
        viewController.driveService = self.driveService;
        viewController.userData = self.userData;
    }
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jsonClassmates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    NSString *student = [self.jsonClassmates objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:30]];
    cell.textLabel.text = student;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Note: Now instead of adding the name, we will add the index
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    NSNumber *t = [NSNumber numberWithInt:indexPath.row];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        //[self.selectedMates addObject:newCell.textLabel.text];
        [self.selectedMates addObject:t];
    }
    else{
        newCell.accessoryType = UITableViewCellAccessoryNone;
        //[self.selectedMates removeObject:newCell.textLabel.text];
        [self.selectedMates removeObject:t];
    }
    
    NSLog(@"%@",self.selectedMates);
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *student = cell.textLabel.text;
    NSLog(@"The row that is being called is,%@ and the BOOL is:%hhd",student,[self.selectedMates containsObject:student]);
    if([self.selectedMates containsObject:student]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (IBAction)confirmInvites:(id)sender {
    NSMutableArray *t = [self finalizeInvites];
    [self makePostRequestwithKeys:@[@"user_id",@"file_name"] withValues:@[t,@"math_worksheet"]];
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
    [self groupsFromJSON:oResponseData forKeys:@[@"first_name",@"errcode",@"user_id",@"last_name"] error:&error];
    return oResponseData;
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
    self.jsonClassmates = [[NSMutableArray alloc] init];
    NSArray* firstNames = [self.jsonResp objectForKey:@"first_name"];
    NSArray* lastNames = [self.jsonResp objectForKey:@"last_name"];
    NSString *holder = @"";
    for (int i=0;i<[firstNames count];i++){
        holder = [NSString stringWithFormat:@"%@ %@",[firstNames objectAtIndex:i],[lastNames objectAtIndex:i]];
        [self.jsonClassmates addObject:holder];
    }
    [self.classmateList reloadData];
    //[self loadDriveFiles];
    
}

-(NSMutableArray*)finalizeInvites{
    NSArray *t = [self.jsonResp objectForKey:@"user_id"];
    NSLog(@"User_ID Array:%@",t);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i=0;i<[self.selectedMates count];i++){
        NSLog(@"%d",i);
        NSNumber* x = (NSNumber *) [self.selectedMates objectAtIndex:i];
        NSLog(@"%@",x);
        NSLog(@"The actual class %@",[[self.selectedMates objectAtIndex:i] class]);
        NSLog(@"Selectedmates: %@",self.selectedMates);
        [result addObject:[t objectAtIndex:[x integerValue]]];
    }
    NSLog (@"The string we will send %@",result);
    return result;
}

-(void)makePostRequestwithKeys:(NSArray *)keys withValues:(NSArray *)values{
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    int i = 0;
    for (NSString *x in keys){
        [dict setObject:[values objectAtIndex:i] forKey:x];
        i++;
    }
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    /*
     WE MIGHT BE ABLE TO TAKE THIS OUT
     NSArray *converted = [[NSArray alloc] initWithArray:userIds];
     NSString *stringOfArray = [[converted valueForKey:@"description"] componentsJoinedByString:@","];
     NSString *post = [NSString stringWithFormat:@"user_id=[%@]", stringOfArray];
     NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
     NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
     */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    const NSString *rU = rootURL;
    NSString *postURL = [rU stringByAppendingString:@"send_invites/"];
    [request setURL:[NSURL URLWithString:postURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //we can maybe take this line out
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    [self performSegueWithIdentifier:@"groupsToHandout" sender:self];
    NSLog(@"Reply: %@", theReply);
}

@end
