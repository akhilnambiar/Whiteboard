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
@property(strong, nonatomic) NSArray* jsonClassmates;
@property(strong,nonatomic) NSMutableArray* selectedMates;


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
    // Do any additional setup after loading the view.
    self.selectedMates = [[NSMutableArray alloc]init];
    const NSString *rU = rootURL;
    NSString *classListURL = [rU stringByAppendingString:@"class/classmates"];
    NSError *error = [[NSError alloc] init];
    NSData* jsonData = [DrEditUtilities getDataFrom:classListURL];
    NSMutableArray* temp = [DrEditUtilities groupsFromJSON:jsonData forKeys:@[@"class"] error:&error];
    self.jsonClassmates = [temp objectAtIndex:0];
    self.classmateList.dataSource = self;
    self.classmateList.delegate = self;
    [self.classmateList reloadData];
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
    cell.textLabel.text = student;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedMates addObject:newCell.textLabel.text];
    }
    else{
        newCell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedMates removeObject:newCell.textLabel.text];
    }
    
    NSLog(@"%@",self.selectedMates);
}



-(void)makePostRequest{
    NSArray *converted = [[NSArray alloc] initWithArray:self.selectedMates];
    NSString *stringOfArray = [[converted valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *post = [NSString stringWithFormat:@"students=[%@]", stringOfArray];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    const NSString *rU = rootURL;
    NSString *postURL = [rU stringByAppendingString:@"class/sendInvites"];
    [request setURL:[NSURL URLWithString:postURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    NSLog(@"Reply: %@", theReply);
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
    [self makePostRequest];
    [self performSegueWithIdentifier:@"groupsToHandout" sender:self];
}

@end
