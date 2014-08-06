//
//  ClassGroupsViewController.h
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/29/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLServiceDrive.h"

@interface ClassGroupsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) GTLServiceDrive *driveService;
@property (weak, nonatomic) NSDictionary *userData;
@end
