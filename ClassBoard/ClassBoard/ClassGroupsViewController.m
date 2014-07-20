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
    //NSLog(@"The URL is,%@",classListURL);
    self.jsonClassmates = [self getDataFrom:classListURL];
    //NSLog(@"here is the JSON Response %@",self.jsonClassmates);
    //NSLog(@"First is %@",[self.jsonClassmates objectAtIndex:0]);
    self.classmateList.dataSource = self;
    self.classmateList.delegate = self;
    [self.classmateList reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//RESTKIT could be useful as well.
//REFACTOR: THIS CAN GO IN THE UTILITIES FILE INSTEAD!
- (NSArray *) getDataFrom:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    /*
    NSArray* json_array = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:&error];
     */
    NSArray* json_array = [self groupsFromJSON:oResponseData error:&error];
    return json_array;
    //return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
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
    //UIButton *cellButt = (UIButton*) [cell.contentView viewWithTag:1];
    //[cellButt setTitle:student forState:UIControlStateNormal];
    cell.textLabel.text = student;
    
    return cell;
}

- (NSArray *)groupsFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSArray *class = [parsedObject objectForKey:@"class"];
    NSLog(@"object one is %@",[class objectAtIndex:0]);
    return class;
    /*
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    NSArray *results = [parsedObject valueForKey:@"results"];
    NSLog(@"Count %d", results.count);
    
    for (NSDictionary *groupDic in results) {
        Group *group = [[Group alloc] init];
        
        for (NSString *key in groupDic) {
            if ([group respondsToSelector:NSSelectorFromString(key)]) {
                [group setValue:[groupDic valueForKey:key] forKey:key];
            }
        }
        
        [groups addObject:group];
    }
    */
    //return groups;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    [tableView reloadData];
    
    [cell setBackgroundColor:[UIColor orangeColor]];
    
    UITableViewCell *cell = [self.classmateList dequeueReusableCellWithIdentifier:@"Cell"];
    //TABLEVIEW??
    if(!([self.classmateList cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)){
        [self.selectedMates addObject:cell.textLabel.text];
        [self.classmateList cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }else{
        [self.classmateList cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedMates removeObject:cell.textLabel.text];
    }
    //[self.selectedMates addObject:@"poop"];
    NSLog(@"%@",self.selectedMates);
     */
    
    
    //UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    //if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
    //    oldCell.accessoryType = UITableViewCellAccessoryNone;
    //}
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedMates addObject:newCell.textLabel.text];
        //self.currentCategory = [taskCategories objectAtIndex:indexPath.row];
    }
    else{
        newCell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedMates removeObject:newCell.textLabel.text];
    }
    
    NSLog(@"%@",self.selectedMates);
}

/*
 OLD METHOD
- (IBAction)studentClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSString *className = NSStringFromClass([sender class]);
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview.superview;
    NSString *className2 = NSStringFromClass([cell class]);
    //[self.classmateList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    //[cell setHighlighted:YES];
    NSIndexPath *indexPath = [self.classmateList indexPathForCell:cell];
    NSLog(@"the current color is, %@",cell.backgroundColor);
    //cell.contentView.backgroundColor=[UIColor blueColor];
    

    NSLog(@"our test boolean is, %d",[cell.backgroundColor isEqual:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]]);
    if ( [button.backgroundColor isEqual:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]] ){
        button.backgroundColor = [UIColor colorWithRed:0.082 green:0.6 blue:0.082 alpha:1];
        [self.selectedMates addObject:button.titleLabel.text];
    }
    else{
        button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        [self.selectedMates removeObject:button.titleLabel.text];
    }
    NSLog(@"The list so far:%@",self.selectedMates);
}
*/

-(void)makePostRequest{
    //NSString *post = [NSString stringWithFormat:@"example=test&p=1&test=yourPostMessage&this=isNotReal"];
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
    /*
    NSHTTPURLResponse *responseCode = nil;
    NSError *error = [[NSError alloc] init];
    NSData *oResponseData = [NSURLConnection connectionWithRequest:request delegate:self];
    
    NSArray* json_response = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:&error];
    NSLog(@"%@",json_response);
     */
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    NSString *student = [self.jsonClassmates objectAtIndex:indexPath.row];
    if([self.selectedMates containsObject:student]){
        [self.classmateList cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        [self.classmateList cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
    */
    
    NSString *student = cell.textLabel.text;
    NSLog(@"The row that is being called is,%@ and the BOOL is:%hhd",student,[self.selectedMates containsObject:student]);
    if([self.selectedMates containsObject:student]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        NSLog(@"horseshit");
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (IBAction)confirmInvites:(id)sender {
    [self makePostRequest];
    [self performSegueWithIdentifier:@"groupsToHandout" sender:self];
}

@end
