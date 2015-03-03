//
//  PushFIleTVC.h
//  ClassBoard
//
//  Created by Akhil Nambiar on 3/2/15.
//  Copyright (c) 2015 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"
#import "DrEditUtilities.h"

@interface PushFIleTVC : UITableViewController
@property (weak, nonatomic) GTLServiceDrive *driveService;
@property (weak, nonatomic) NSDictionary *userData;
@end
