//
//  DocumentTBC.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 3/2/15.
//  Copyright (c) 2015 Akhil Nambiar. All rights reserved.
//

#import "DocumentTBC.h"
#import "DocumentVC.h"
#import "PushFIleTVC.h"

@interface DocumentTBC ()

@end

@implementation DocumentTBC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DocumentVC* vc = nil;
    vc=(DocumentVC *)[[self viewControllers] objectAtIndex:0];
    vc.driveService=self.driveService;
    vc.userData=self.userData;
    vc=(DocumentVC *)[[self viewControllers] objectAtIndex:1];
    vc.driveService=self.driveService;
    vc.userData=self.userData;
    vc=(DocumentVC *)[[self viewControllers] objectAtIndex:2];
    vc.driveService=self.driveService;
    vc.userData=self.userData;
    vc=(DocumentVC *)[[self viewControllers] objectAtIndex:3];
    vc.driveService=self.driveService;
    vc.userData=self.userData;
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
