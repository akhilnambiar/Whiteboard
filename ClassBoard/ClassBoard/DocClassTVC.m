//
//  DocClassTVC.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 3/9/15.
//  Copyright (c) 2015 Akhil Nambiar. All rights reserved.
//

#import "DocClassTVC.h"

@interface DocClassTVC ()
@property NSMutableArray* classes;
@property NSArray* titles;
@end

@implementation DocClassTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@"Period 1",@"Period 2",@"Period 3",@"Period 4",@"Period 5",@"Period 6",];
    self.classes = [[NSMutableArray alloc] init];
    NSMutableArray* class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_1",@"file_2",@"file_3",@"file_4"]];
    [self.classes addObject:class];
    class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_1",@"file_2"]];
    [self.classes addObject:class];
    class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_1c",@"file_2c",@"file_3c"]];
    [self.classes addObject:class];
    class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_1d",@"file_2d",@"file_3d"]];
    [self.classes addObject:class];
    class = [[NSMutableArray alloc] init];
    [class addObjectsFromArray:@[@"file_1e"]];
    [self.classes addObject:class];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.classes count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [(NSMutableArray* )[self.classes objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    GTLDriveFile *file = [self.driveFiles objectAtIndex:indexPath.row];
    NSString *file = [self.classes object]
    static NSString *CellIdentifier = @"TitleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    [cell.textLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:30]];
    cell.textLabel.text = file.title;
    
    return cell;
     SAVEPOINT: Get this working
     http://nscookbook.com/2013/02/ios-programming-recipe-11-using-the-uitableview-part-ii/
     */
    NSString *file = [(NSMutableArray *)[self.classes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"ClassCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    [cell.textLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:30]];
    cell.textLabel.text = file;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.titles objectAtIndex:section];
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
