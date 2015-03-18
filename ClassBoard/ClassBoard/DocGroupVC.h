//
//  DocGroupVC.h
//  ClassBoard
//
//  Created by Akhil Nambiar on 3/18/15.
//  Copyright (c) 2015 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLServiceDrive.h"

@interface DocGroupVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) GTLServiceDrive *driveService;
@property (weak, nonatomic) NSDictionary *userData;
@end
