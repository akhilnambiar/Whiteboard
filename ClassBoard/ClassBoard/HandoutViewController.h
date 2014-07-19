//
//  HandoutViewController.h
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/29/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2Authentication.h"
#import "GTLDrive.h"

@interface HandoutViewController : UIViewController
@property (weak, readwrite) GTLServiceDrive *driveService;
@end
