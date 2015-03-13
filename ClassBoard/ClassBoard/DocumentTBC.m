//
//  DocumentTBC.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 3/2/15.
//  Copyright (c) 2015 Akhil Nambiar. All rights reserved.
//

#import "DocumentTBC.h"
#import "DocTitleTVC.h"
#import "DocClassTVC.h"
#import "DocAssignTVC.h"
#import "DocGroupTVC.h"
#import "PushFIleTVC.h"

@interface DocumentTBC ()

@end

@implementation DocumentTBC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DocTitleTVC* vc=(DocTitleTVC *)[[self viewControllers] objectAtIndex:0];
    vc.driveService=self.driveService;
    vc.userData=self.userData;
    DocAssignTVC* vc3=(DocAssignTVC *)[[self viewControllers] objectAtIndex:1];
    vc3.driveService=self.driveService;
    vc3.userData=self.userData;
    /*
    DocClassTVC* vc2=(DocClassTVC *)[[self viewControllers] objectAtIndex:2];
    vc2.driveService=self.driveService;
    vc2.userData=self.userData;
    DocGroupTVC* vc4=(DocGroupTVC *)[[self viewControllers] objectAtIndex:3];
    vc4.driveService=self.driveService;
    vc4.userData=self.userData;
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"docToPush"]){
        PushFIleTVC* vc = [segue destinationViewController];
        vc.driveService = self.driveService;
        vc.userData = self.userData;
    }
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
