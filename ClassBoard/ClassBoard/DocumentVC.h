//
//  DocumentVC.h
//  ClassBoard
//
//  Created by Akhil Nambiar on 2/25/15.
//  Copyright (c) 2015 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"

@interface DocumentVC : UIViewController
@property (weak, nonatomic) GTLServiceDrive *driveService;
@property (weak, nonatomic) NSDictionary *userData;
@end
