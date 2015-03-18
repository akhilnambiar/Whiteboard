//
//  DocGroupVC.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 3/18/15.
//  Copyright (c) 2015 Akhil Nambiar. All rights reserved.
//

#import "DocGroupVC.h"

@interface DocGroupVC ()
@property (strong, nonatomic) IBOutlet UITableView *groupTable;
@property NSMutableArray* groups;
@property NSArray* group_name;
@end

@implementation DocGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"view is setup");
    self.group_name= @[@"Science Group",@"Math Buddies",@"English Friends",@"Study Hall",@"Geography 5",@"Period 6",];
    self.groups = [[NSMutableArray alloc] init];
    NSMutableArray* class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_2",@"file_3",@"file_4"]];
    [self.groups addObject:class];
    class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_1",@"file_2",@"file_1",@"file_1"]];
    [self.groups addObject:class];
    class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_1c",@"file_2c",@"file_3c",@"maps"]];
    [self.groups addObject:class];
    class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"more money",@"file_1d",@"file_2d",@"file_3d"]];
    [self.groups addObject:class];
    class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_1e",@"adds"]];
    [self.groups addObject:class];
    self.groupTable.dataSource = self;
    self.groupTable.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Savepoint: Get this view controller working
#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray*)[self.groups objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *student = [(NSArray*)[self.groups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:30]];
    cell.textLabel.text = student;
    NSLog(@"the text is : %@",student);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Note: Now instead of adding the name, we will add the index
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    //NSNumber *t = [NSNumber numberWithInt:indexPath.row];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        //[self.selectedMates addObject:newCell.textLabel.text];
        //[self.selectedMates addObject:t];
    }
    else{
        newCell.accessoryType = UITableViewCellAccessoryNone;
        //[self.selectedMates removeObject:newCell.textLabel.text];
        //[self.selectedMates removeObject:t];
    }
    
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    NSString *student = cell.textLabel.text;
    if([self.selectedMates containsObject:student]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
     */
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.group_name objectAtIndex:section];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
