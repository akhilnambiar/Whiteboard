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
/*
extern NSString const *rootURL;
extern NSString const *kClientSecret;
extern NSString const *kClientId;
extern NSString const *kKeychainItemName;
 */
@property (weak, nonatomic) GTLServiceDrive *driveService;
@property (weak, nonatomic) NSDictionary *userData;
@property NSString* userId;
@end
