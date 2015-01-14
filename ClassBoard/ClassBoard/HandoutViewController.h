//
//  HandoutViewController.h
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/29/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"

@interface HandoutViewController : UIViewController
@property (weak, readwrite) GTLServiceDrive *driveService;
@property (weak, nonatomic) NSDictionary *userData;
@end
