//
//  SplashPageViewController.h
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/26/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLServiceDrive.h"

@interface SplashPageViewController : UIViewController
extern const NSString *rootURL;
@property (weak, nonatomic) GTLServiceDrive *driveService;
@property (weak, nonatomic) NSDictionary *userData;
@property NSString* userId;
@end
